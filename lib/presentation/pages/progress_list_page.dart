import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/domain/entities/progress.dart';
import 'package:first_app/domain/repositories/progress_repository.dart';
import 'package:first_app/presentation/widgets/learn_progress_indicator.dart';
import 'package:first_app/presentation/widgets/streak/streak_button.dart';
import 'package:flutter/material.dart';

class ProgressListPage extends StatefulWidget {
  const ProgressListPage({super.key});

  @override
  State<ProgressListPage> createState() => _ProgressListPageState();
}

class _ProgressListPageState extends State<ProgressListPage> {
  late Future<List<Progress>> _progressFuture;

  @override
  void initState() {
    super.initState();
    _progressFuture = sl<ProgressRepository>().getWithLearnGreaterThanZero();
  }

  void _reload() {
    setState(() {
      _progressFuture = sl<ProgressRepository>().getWithLearnGreaterThanZero();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: StreakButton(),
          ),
          Expanded(
            child: FutureBuilder<List<Progress>>(
              future: _progressFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Error: ${snapshot.error}'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: _reload,
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  );
                }

                final progressList = snapshot.data ?? [];
                if (progressList.isEmpty) {
                  return const Center(
                    child: Text('Aún no hay progreso registrado'),
                  );
                }

                return ListView.separated(
                  itemCount: progressList.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final progress = progressList[index];
                    return _ProgressRow(progress: progress);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  final Progress progress;

  const _ProgressRow({required this.progress});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              progress.word,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          LearnProgressIndicator(learnValue: progress.learn),
          const SizedBox(width: 8),
          SizedBox(
            width: 44,
            child: Text(
              '${progress.learn} %',
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}
