import 'dart:convert';
import 'package:first_app/domain/entities/outbox_event.dart';

class OutboxEventModel {
  final int? id;
  final String entityType;
  final int entityId;
  final String operation;
  final String payload;
  final String status;
  final int attempts;
  final int maxAttempts;
  final String? nextRetryAt;
  final String createdAt;
  final String updatedAt;

  OutboxEventModel({
    this.id,
    required this.entityType,
    required this.entityId,
    this.operation = 'upsert',
    required this.payload,
    this.status = 'pending',
    this.attempts = 0,
    this.maxAttempts = 15,
    this.nextRetryAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OutboxEventModel.fromMap(Map<String, dynamic> map) {
    return OutboxEventModel(
      id: map['id'] as int?,
      entityType: map['entity_type'] as String,
      entityId: map['entity_id'] as int,
      operation: map['operation'] as String? ?? 'upsert',
      payload: map['payload'] as String,
      status: map['status'] as String? ?? 'pending',
      attempts: map['attempts'] as int? ?? 0,
      maxAttempts: map['max_attempts'] as int? ?? 15,
      nextRetryAt: map['next_retry_at'] as String?,
      createdAt: map['created_at'] as String,
      updatedAt: map['updated_at'] as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'entity_type': entityType,
      'entity_id': entityId,
      'operation': operation,
      'payload': payload,
      'status': status,
      'attempts': attempts,
      'max_attempts': maxAttempts,
      'next_retry_at': nextRetryAt,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  OutboxEvent toEntity() {
    return OutboxEvent(
      id: id,
      entityType: entityType,
      entityId: entityId,
      operation: operation,
      payload: payload,
      status: _parseStatus(status),
      attempts: attempts,
      maxAttempts: maxAttempts,
      nextRetryAt: nextRetryAt != null ? DateTime.parse(nextRetryAt!) : null,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  static OutboxStatus _parseStatus(String s) {
    switch (s) {
      case 'in_flight':
        return OutboxStatus.inFlight;
      case 'failed':
        return OutboxStatus.failed;
      default:
        return OutboxStatus.pending;
    }
  }

  Map<String, dynamic> get payloadAsMap =>
      jsonDecode(payload) as Map<String, dynamic>;
}