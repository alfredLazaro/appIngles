# Plan de implementación — Sync offline-first con Outbox Pattern

## Objetivo

Sincronizar el progreso de aprendizaje (learn count por palabra) entre múltiples dispositivos de un mismo usuario, usando **Transactional Outbox Pattern** con tabla de cola separada.

---

## 1. Esquema de tablas

### 1.1 Outbox (local SQLite)

```sql
CREATE TABLE outbox (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  entity_type TEXT NOT NULL,         -- 'progress'
  entity_id INTEGER NOT NULL,        -- word_id (local)
  operation TEXT NOT NULL DEFAULT 'upsert',
  payload TEXT NOT NULL,             -- JSON: {"learn": N, "updated_at": "ISO8601"}
  status TEXT NOT NULL DEFAULT 'pending',  -- pending | in_flight | failed
  attempts INTEGER NOT NULL DEFAULT 0,
  max_attempts INTEGER NOT NULL DEFAULT 15,
  next_retry_at TEXT,                -- ISO8601, NULL = ready now
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);

CREATE UNIQUE INDEX idx_outbox_pending_entity
  ON outbox(entity_type, entity_id)
  WHERE status = 'pending';
```

**Campos justificados:**
- `entity_type` + `entity_id`: identifican qué registro modificamos — permite colapsar.
- `payload`: snapshot JSON del estado al encolar; si hay colapso se sobreescribe con el último valor.
- `status`: FIFO (`pending` → `in_flight` → deleted (éxito) o `failed` + `next_retry_at`).
- `attempts` / `max_attempts`: control de reintentos; al llegar a `max_attempts` se marca `failed`.
- `next_retry_at`: backoff sin timers — la próxima vez que el worker se dispara, filtra por `next_retry_at <= now()`.
- `created_at`: orden FIFO para selección.
- **Partial unique index**: garantiza que solo haya un `pending` por entidad (colapso). `in_flight` y `failed` pueden coexistir con un nuevo `pending`.

### 1.2 Progress (local)

```sql
CREATE TABLE progress (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  word_id INTEGER NOT NULL UNIQUE,   -- FK implícita a Word.id (sin CASCADE para evitar pérdida accidental)
  learn INTEGER NOT NULL DEFAULT 0,
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  user_id INTEGER,
  synced_at TEXT                    -- última vez que el servidor confirmó este valor
);
```

El `learn` de `Word` se conserva como fuente de verdad local para lecturas existentes. `progress` es la tabla sincronizable.

### 1.3 Users (local — caché de sesión)

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  email TEXT NOT NULL,
  token TEXT,
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now'))
);
```

Solo una fila (el usuario actual). No participa del Outbox.

---

## 2. Escritura transaccional (Dart)

Al guardar progreso (en `batchUpdateLearnCounts` o `updateLearn`):

```dart
await db.transaction((txn) async {
  // 1. Actualizar tabla maestra
  await txn.update('Word', {
    'learn': newLearn,
    'updated_at': now,
  }, where: 'id = ?', whereArgs: [wordId]);

  // 2. Actualizar progress (o insertar)
  await txn.insert('progress', {
    'word_id': wordId,
    'learn': newLearn,
    'updated_at': now,
  }, conflictAlgorithm: ConflictAlgorithm.replace);

  // 3. Encolar en outbox con colapso
  // INSERT OR IGNORE + UPDATE si ya existe pending
  final existing = await txn.query('outbox',
    where: "entity_type = 'progress' AND entity_id = ? AND status = 'pending'",
    whereArgs: [wordId]);
  if (existing.isEmpty) {
    await txn.insert('outbox', {
      'entity_type': 'progress',
      'entity_id': wordId,
      'operation': 'upsert',
      'payload': jsonEncode({'learn': newLearn, 'updated_at': now}),
      'status': 'pending',
      'created_at': now,
      'updated_at': now,
    });
  } else {
    await txn.update('outbox', {
      'payload': jsonEncode({'learn': newLearn, 'updated_at': now}),
      'updated_at': now,
      'attempts': 0,
      'next_retry_at': null,
    }, where: "entity_type = 'progress' AND entity_id = ? AND status = 'pending'",
        whereArgs: [wordId]);
  }
});
```

**Atomicidad:** Si falla cualquier paso, toda la transacción se revierte — nunca hay progreso nuevo sin su outbox ni outbox sin progreso.

---

## 3. Worker de sincronización (SyncService)

### 3.1 Disparo oportunista

Se invoca `SyncService.trySync()` desde:
- `MainNavigationPage.initState()` o un `WidgetsBindingObserver.didChangeAppLifecycleState → resumed`
- Al terminar una práctica exitosa (`PracticeBloc._onFinishPractice` → `sl<SyncService>().trySync()`)

### 3.2 Condiciones para sincronizar

```dart
Future<bool> _shouldSync() async {
  final pendingCount = await _outboxDao.countPending();
  if (pendingCount == 0) return false;
  if (pendingCount >= 10) return true;

  final lastSync = await _preferences.getLastSyncTime();
  if (lastSync == null) return true;
  return DateTime.now().difference(lastSync) >= Duration(hours: 24);
}
```

**Valores por defecto:** lote ≥10 pendientes **o** ≥24h desde último sync. Ajustables.

### 3.3 Selección y marcado in_flight

```dart
final rows = await _outboxDao.selectReadyBatch(
  limit: 50,
  now: DateTime.now().toIso8601String(),
);
if (rows.isEmpty) return;

await _outboxDao.markInFlight(rows.map((r) => r.id).toList());
```

`selectReadyBatch`: `SELECT * FROM outbox WHERE status = 'pending' AND (next_retry_at IS NULL OR next_retry_at <= ?) ORDER BY created_at ASC LIMIT ?`

Mientras el batch viaja, nuevas escrituras al mismo word_id generan un nuevo `pending` (que NO interfiere con el `in_flight` — tienen status distinto, el índice parcial no lo cubre).

### 3.4 Armado del batch

```dart
final payload = rows.map((r) => {
  'word_id': r.entityId,
  'learn': r.payload['learn'],
  'updated_at': r.payload['updated_at'],
}).toList();
// PUT /progress con auth token
```

### 3.5 Post-síncrono (éxito)

```dart
await _outboxDao.deleteByIds(ids);
await _preferences.setLastSyncTime(DateTime.now());
// Pull para detectar conflictos perdidos
await _pullAndReconcile();
```

### 3.6 Post-síncrono (fallo)

```dart
await _outboxDao.markForRetry(ids, attempts: attempt + 1, backoffSeconds: _calcBackoff(attempt + 1));
```

`_calcBackoff`:
```
attempt 1: 60s
attempt 2: 120s (2min)
attempt 3: 240s (4min)
attempt 4: 480s (8min)
attempt 5: 960s (16min)
attempt 6: 1920s (32min)
attempt 7: 3840s (64min ≈ 1hr)
attempt 8: 7200s (2hr)
attempt 9+: 14400s (4hr) → cap at 86400s (24hr)
```

Fórmula: `min(60 * pow(2, attempts - 1), 86400)` segundos.

---

## 4. Bootstrap de dispositivo nuevo

Al iniciar sesión:

1. `POST /auth/login` → `{user_id, email, token}`
2. Guardar `users` local (caché)
3. `GET /progress` (con token) → lista `[{word_id, learn, updated_at}]`
4. Para cada `word_id` del servidor:
   - Si no existe `progress` local → insertar con valor del servidor + `synced_at = now`
   - Si existe local → comparar `updated_at`:
     - Servidor más nuevo → actualizar `progress.learn` y `Word.learn` al valor del servidor
     - Local más nuevo → NO tocar (se subirá en el próximo sync)
5. Para cada `progress` local cuyo `word_id` no esté en la respuesta del servidor → encolar en outbox (es progreso nuevo que el servidor no conoce)

**No se genera outbox por valores que vienen del servidor** (ya están allá). Solo los valores locales más nuevos que el servidor generan outbox para subir.

---

## 5. Resolución de conflictos (LWW)

**Servidor Go (no implementado aquí):**
```sql
INSERT INTO progress (user_id, word_id, learn, updated_at)
VALUES (?, ?, ?, ?)
ON CONFLICT(user_id, word_id) DO UPDATE SET
  learn = CASE WHEN excluded.updated_at > updated_at THEN excluded.learn ELSE learn END,
  updated_at = CASE WHEN excluded.updated_at > updated_at THEN excluded.updated_at ELSE updated_at END;
```

**Cliente: detección de conflicto perdido:**
Después de cada `PUT /progress` exitoso, el worker hace `GET /progress`. Si algún valor local difiere del servidor (y el servidor tiene `updated_at` más reciente), el cliente actualiza su copia local. Si el cliente tenía un valor más nuevo que el servidor, ese valor se re-intentará en el próximo ciclo de sync.

**Ejemplo concreto:**
1. Dispositivo A: `word_id=5, learn=10, updated_at=T1`
2. Dispositivo B: `word_id=5, learn=20, updated_at=T2` (T2 > T1)
3. Ambos offline. A sincroniza primero → servidor acepta (T1≤T2, no hay conflicto aún)
4. B sincroniza → servidor compara: T2 > T1 → acepta learn=20
5. A hace GET /progress → descubre learn=20, updated_at=T2
6. A actualiza local: Word.learn=20, progress.learn=20 (sin outbox, el valor ya está en el servidor)
7. A converge.

**Cliente perdedor:** el `GET /progress` post-sync es el mecanismo de convergencia. Si A hubiera hecho otro cambio local a la misma palabra después de T1 pero antes de recibir T2, ese cambio local tendría T3 > T2, y se re-encolaría en outbox en el próximo ciclo.

---

## 6. Diagrama de flujo completo

```
Usuario práctica
       │
       ▼
┌─────────────────────────┐
│  batchUpdateLearnCounts  │
│  (db.transaction)        │
│  ┌───────────────────┐   │
│  │ 1. UPDATE Word    │   │
│  │ 2. UPSERT progress│   │
│  │ 3. UPSERT outbox  │   │
│  │    (collapse)     │   │
│  └───────────────────┘   │
└─────────┬───────────────┘
          │ COMMIT ok
          ▼
┌─────────────────────────┐
│  SyncService.trySync()  │  ← se dispara oportunistamente
│                         │
│  ¿≥10 pending o ≥24h?   │──NO──→ fin
│         │SÍ             │
│         ▼               │
│  SELECT pending batch   │
│  WHERE next_retry_at≤now│
│  ORDER BY created_at    │
│  LIMIT 50               │
│         │               │
│         ▼               │
│  UPDATE → in_flight     │
│         │               │
│         ▼               │
│  PUT /progress (batch)  │
│         │               │
│    ┌────┴────┐          │
│    ▼         ▼          │
│  éxito     fallo        │
│    │         │          │
│    ▼         ▼          │
│  DELETE     UPDATE      │
│  outbox     attempts++, │
│  rows       next_retry  │
│    │         backoff    │
│    ▼                   │
│  GET /progress          │
│  (reconciliación)       │
│    │                    │
│    ▼                    │
│  Actualizar local       │
│  si servidor ganó       │
└─────────────────────────┘
```