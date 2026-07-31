import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/domain/repositories/sync_repository.dart';
import 'package:first_app/presentation/bloc/auth/auth_bloc.dart';
import 'package:first_app/presentation/bloc/auth/auth_event.dart';
import 'package:first_app/presentation/bloc/auth/auth_state.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_bloc.dart';
import 'package:first_app/presentation/bloc/word_list/word_list_event.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  String? _selectedCategory;
  bool _isLoading = false;

  static const _categories = [
    /* 'Principiante',
    'Intermedio',
    'Avanzado', */
    'verb',
    'phrasal_verb',
  ];

  Future<void> _downloadWords(String category) async {
    setState(() => _isLoading = true);
    try {
      await sl<SyncRepository>().pullWordsByCategory(category);
      if (mounted) {
        context.read<WordListBloc>().add(const RefreshWordsEvent());
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Palabras descargadas correctamente')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final loggedIn = state is AuthSuccess;
        final email = loggedIn ? state.session.email : null;

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    const Icon(Icons.account_circle, size: 64, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      email ?? 'Invitado',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ),
              if (!loggedIn)
                ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('Iniciar sesión'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/auth');
                  },
                ),
              if (loggedIn) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: DropdownButtonFormField<String>(
                    initialValue: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Categoría',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    items: _categories.map((cat) {
                      return DropdownMenuItem(value: cat, child: Text(cat));
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedCategory = val),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ElevatedButton.icon(
                    onPressed: _selectedCategory != null && !_isLoading
                        ? () => _downloadWords(_selectedCategory!)
                        : null,
                    icon: _isLoading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.download),
                    label: Text(_isLoading ? 'Descargando...' : 'Descargar palabras'),
                  ),
                ),
                const Divider(),
              ],
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Configuración'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Acerca de'),
                onTap: () {
                  Navigator.pop(context);
                },
              ),
              if (loggedIn) ...[
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text('Cerrar sesión', style: TextStyle(color: Colors.red)),
                  onTap: () {
                    context.read<AuthBloc>().add(const LogoutRequested());
                    Navigator.pop(context);
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}
