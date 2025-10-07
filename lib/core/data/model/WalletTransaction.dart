import 'dart:convert';

class WalletTransaction {
  final String uuid;
  final String walletUuid;
  final int userId;
  final String type;
  final double amount;
  final String currency;
  final double balanceBefore;
  final double balanceAfter;
  final String? referenceType;
  final int? referenceId;
  final String status;
  final String? note;
  final Map<String, dynamic>? meta;
  final DateTime createdAt;

  WalletTransaction({
    required this.uuid,
    required this.walletUuid,
    required this.userId,
    required this.type,
    required this.amount,
    required this.currency,
    required this.balanceBefore,
    required this.balanceAfter,
    this.referenceType,
    this.referenceId,
    required this.status,
    this.note,
    this.meta,
    required this.createdAt,
  });

  /// Helper to safely parse the `meta` field which may be:
  /// - a JSON string -> decode it
  /// - a Map already -> convert to Map<String,dynamic>
  /// - null or invalid -> return null
  static Map<String, dynamic>? parseMeta(dynamic raw) {
    if (raw == null) return null;

    try {
      if (raw is String) {
        raw = raw.trim();
        if (raw.isEmpty) return null;

        // Some APIs may return an already-encoded JSON string.
        // Try decode; if fails, return null.
        final decoded = json.decode(raw);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        } else {
          return null;
        }
      } else if (raw is Map) {
        return Map<String, dynamic>.from(raw);
      } else {
        // other unexpected types
        return null;
      }
    } catch (e) {
      // parsing failed (malformed JSON) -> ignore and return null
      // Optionally: log the error where you can
      return null;
    }
  }

  factory WalletTransaction.fromJson(Map<String, dynamic> jsonMap) {
    // parse created_at safely
    DateTime created;
    try {
      created = DateTime.parse(jsonMap['created_at']?.toString() ?? DateTime.now().toIso8601String());
    } catch (_) {
      created = DateTime.now();
    }

    return WalletTransaction(
      uuid: jsonMap['uuid']?.toString() ?? '',
      walletUuid: jsonMap['wallet_uuid']?.toString() ?? '',
      userId: (jsonMap['user_id'] is int) ? jsonMap['user_id'] : int.tryParse(jsonMap['user_id']?.toString() ?? '') ?? 0,
      type: jsonMap['type']?.toString() ?? '',
      amount: jsonMap['amount'] != null ? double.tryParse(jsonMap['amount'].toString()) ?? 0.0 : 0.0,
      currency: jsonMap['currency']?.toString() ?? '',
      balanceBefore: jsonMap['balance_before'] != null ? double.tryParse(jsonMap['balance_before'].toString()) ?? 0.0 : 0.0,
      balanceAfter: jsonMap['balance_after'] != null ? double.tryParse(jsonMap['balance_after'].toString()) ?? 0.0 : 0.0,
      referenceType: jsonMap['reference_type']?.toString(),
      referenceId: (jsonMap['reference_id'] is int) ? jsonMap['reference_id'] : int.tryParse(jsonMap['reference_id']?.toString() ?? ''),
      status: jsonMap['status']?.toString() ?? '',
      note: jsonMap['note']?.toString(),
      meta: parseMeta(jsonMap['meta']),
      createdAt: created,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'wallet_uuid': walletUuid,
      'user_id': userId,
      'type': type,
      'amount': amount,
      'currency': currency,
      'balance_before': balanceBefore,
      'balance_after': balanceAfter,
      'reference_type': referenceType,
      'reference_id': referenceId,
      'status': status,
      'note': note,
      // Keep meta as a map (if present). If you need to send as string, wrap with json.encode(meta)
      'meta': meta,
      'created_at': createdAt.toIso8601String(),
    };
  }

  WalletTransaction copyWith({
    String? uuid,
    String? walletUuid,
    int? userId,
    String? type,
    double? amount,
    String? currency,
    double? balanceBefore,
    double? balanceAfter,
    String? referenceType,
    int? referenceId,
    String? status,
    String? note,
    Map<String, dynamic>? meta,
    DateTime? createdAt,
  }) {
    return WalletTransaction(
      uuid: uuid ?? this.uuid,
      walletUuid: walletUuid ?? this.walletUuid,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      balanceBefore: balanceBefore ?? this.balanceBefore,
      balanceAfter: balanceAfter ?? this.balanceAfter,
      referenceType: referenceType ?? this.referenceType,
      referenceId: referenceId ?? this.referenceId,
      status: status ?? this.status,
      note: note ?? this.note,
      meta: meta ?? this.meta,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
