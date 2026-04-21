import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationService {
  NotificationService._();

  static final _db = FirebaseFirestore.instance;

  static Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String body,
    String? jobId,
    Map<String, dynamic>? data,
  }) async {
    final cleanUserId = userId.trim();
    if (cleanUserId.isEmpty) return;

    await _db.collection('notifications').add({
      'userId': cleanUserId,
      'type': type,
      'title': title,
      'body': body,
      if (jobId != null && jobId.trim().isNotEmpty) 'jobId': jobId.trim(),
      'data': data ?? <String, dynamic>{},
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Future<void> notifyNewOffer({
    required String customerId,
    required String jobId,
    required String workerName,
    required String price,
  }) {
    return createNotification(
      userId: customerId,
      type: 'new_offer',
      title: 'Nouvelle offre',
      body: '$workerName a envoye une offre de $price.',
      jobId: jobId,
      data: {
        'workerName': workerName,
        'price': price,
      },
    );
  }

  static Future<void> notifyMissionAccepted({
    required String workerId,
    required String jobId,
    required String customerName,
  }) {
    return createNotification(
      userId: workerId,
      type: 'mission_accepted',
      title: 'Mission acceptee',
      body: '$customerName a accepte votre offre.',
      jobId: jobId,
      data: {
        'customerName': customerName,
      },
    );
  }

  static Future<void> notifyUrgentActivated({
    required String userId,
    required String jobId,
    required String jobTitle,
  }) {
    return createNotification(
      userId: userId,
      type: 'urgent_activated',
      title: 'Urgent active',
      body: 'Votre demande "$jobTitle" est maintenant prioritaire.',
      jobId: jobId,
    );
  }
}
