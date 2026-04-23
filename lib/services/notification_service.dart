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

  static Future<void> notifyRequestUpdated({
    required String userId,
    required String jobId,
    required String jobTitle,
    required String updateLabel,
  }) {
    return createNotification(
      userId: userId,
      type: 'request_updated',
      title: 'Demande mise a jour',
      body: '$updateLabel: "$jobTitle".',
      jobId: jobId,
      data: {
        'jobTitle': jobTitle,
        'updateLabel': updateLabel,
      },
    );
  }

  static Future<void> notifyWorkerProfileApproved({
    required String workerId,
  }) {
    return createNotification(
      userId: workerId,
      type: 'worker_profile_approved',
      title: 'Profil artisan approuve',
      body:
          'Votre profil est valide. Vous pouvez recevoir des demandes et envoyer des offres.',
    );
  }

  static Future<void> notifyNearbyRequestForWorkers({
    required String jobId,
    required String customerId,
    required String jobTitle,
    required String category,
    required String city,
  }) async {
    final cleanCategory = category.trim();
    final cleanCity = city.trim().toLowerCase();

    final workersSnapshot = await _db
        .collection('users')
        .where('role', isEqualTo: 'worker')
        .limit(40)
        .get();

    final notifications = <Future<void>>[];
    for (final doc in workersSnapshot.docs) {
      if (doc.id == customerId) continue;

      final data = doc.data();
      if (data['isVerified'] != true) continue;

      final workerCity = (data['city'] as String? ?? '').trim().toLowerCase();
      if (cleanCity.isNotEmpty &&
          workerCity.isNotEmpty &&
          workerCity != cleanCity) {
        continue;
      }

      final services = data['services'];
      if (cleanCategory.isNotEmpty &&
          services is List &&
          services.isNotEmpty &&
          !services
              .map((service) => service.toString())
              .contains(cleanCategory)) {
        continue;
      }

      notifications.add(
        createNotification(
          userId: doc.id,
          type: 'nearby_request',
          title: 'Nouvelle demande proche',
          body: cleanCity.isEmpty
              ? 'Une demande "$jobTitle" correspond a vos services.'
              : 'Une demande "$jobTitle" est disponible pres de chez vous.',
          jobId: jobId,
          data: {
            'jobTitle': jobTitle,
            'category': cleanCategory,
            'city': city.trim(),
          },
        ),
      );
    }

    await Future.wait(notifications);
  }
}
