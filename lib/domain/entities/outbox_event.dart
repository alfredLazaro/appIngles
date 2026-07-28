enum OutboxStatus { pending, inFlight, failed }

class OutboxEvent {
  final int? id;
  final String entityType;
  final int entityId;
  final String operation;
  final String payload;
  final OutboxStatus status;
  final int attempts;
  final int maxAttempts;
  final DateTime? nextRetryAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const OutboxEvent({
    this.id,
    required this.entityType,
    required this.entityId,
    this.operation = 'upsert',
    required this.payload,
    this.status = OutboxStatus.pending,
    this.attempts = 0,
    this.maxAttempts = 15,
    this.nextRetryAt,
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isExpired => attempts >= maxAttempts;
}