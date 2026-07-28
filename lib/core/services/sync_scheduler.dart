import 'package:flutter/material.dart';
import 'package:first_app/core/services/sync_service.dart';

class SyncScheduler extends StatefulWidget {
  final Widget child;
  final SyncService syncService;

  const SyncScheduler({
    super.key,
    required this.child,
    required this.syncService,
  });

  @override
  State<SyncScheduler> createState() => _SyncSchedulerState();
}

class _SyncSchedulerState extends State<SyncScheduler>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    widget.syncService.trySync();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      widget.syncService.onAppResumed();
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}