import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminOverviewData {
  const AdminOverviewData({
    required this.totalClients,
    required this.totalWorkers,
    required this.openRequests,
    required this.completedJobs,
    required this.pendingVerifications,
    required this.recentSignups,
    required this.recentRequests,
    required this.recentComplaints,
    required this.requestsWithoutOffers,
  });

  final int totalClients;
  final int totalWorkers;
  final int openRequests;
  final int completedJobs;
  final int pendingVerifications;

  final List<Map<String, dynamic>> recentSignups;
  final List<Map<String, dynamic>> recentRequests;
  final List<Map<String, dynamic>> recentComplaints;
  final List<Map<String, dynamic>> requestsWithoutOffers;
}

class AdminFirestoreService {
  AdminFirestoreService({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  CollectionReference<Map<String, dynamic>> get _jobs => _db.collection('jobs');

  Future<AdminOverviewData> loadOverview({
    int recentLimit = 6,
    int alertLimit = 6,
  }) async {
    final results = await Future.wait([
      _countUsersByRole('customer'),
      _countUsersByRole('worker'),
      _countJobsByStatus('open'),
      _countJobsByStatus('done'),
      _countPendingVerifications(),
      _recentUsers(limit: recentLimit),
      _recentJobs(limit: recentLimit),
      _recentComplaints(limit: recentLimit),
      _requestsWithoutOffers(limit: alertLimit),
    ]);

    return AdminOverviewData(
      totalClients: results[0] as int,
      totalWorkers: results[1] as int,
      openRequests: results[2] as int,
      completedJobs: results[3] as int,
      pendingVerifications: results[4] as int,
      recentSignups: results[5] as List<Map<String, dynamic>>,
      recentRequests: results[6] as List<Map<String, dynamic>>,
      recentComplaints: results[7] as List<Map<String, dynamic>>,
      requestsWithoutOffers: results[8] as List<Map<String, dynamic>>,
    );
  }

  Future<int> _countUsersByRole(String role) async {
    try {
      final snapshot = await _users.get();
      var count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if ((data['role'] as String?)?.trim() == role) count++;
      }
      return count;
    } catch (e) {
      debugPrint('countUsersByRole($role) error: $e');
      return 0;
    }
  }

  Future<int> _countJobsByStatus(String status) async {
    try {
      final snapshot = await _jobs.get();
      var count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if ((data['status'] as String?)?.trim() == status) count++;
      }
      return count;
    } catch (e) {
      debugPrint('countJobsByStatus($status) error: $e');
      return 0;
    }
  }

  Future<int> _countPendingVerifications() async {
    try {
      final snapshot = await _users.get();
      var count = 0;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        if (data['verificationRequested'] == true) count++;
      }
      return count;
    } catch (e) {
      debugPrint('countPendingVerifications error: $e');
      return 0;
    }
  }

  Future<List<Map<String, dynamic>>> _recentUsers({required int limit}) async {
    try {
      final snapshot = await _users.get();
      final users = snapshot.docs.map((d) {
        final data = d.data();
        return <String, dynamic>{...data, 'id': d.id};
      }).toList();

      users.sort((a, b) => _compareTimestampDesc(a['createdAt'], b['createdAt']));
      return users.take(limit).toList();
    } catch (e) {
      debugPrint('recentUsers error: $e');
      return const <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> _recentJobs({required int limit}) async {
    try {
      final snapshot = await _jobs.get();
      final jobs = snapshot.docs.map((d) {
        final data = d.data();
        return <String, dynamic>{...data, 'id': d.id};
      }).toList();

      jobs.sort((a, b) => _compareTimestampDesc(a['createdAt'], b['createdAt']));
      return jobs.take(limit).toList();
    } catch (e) {
      debugPrint('recentJobs error: $e');
      return const <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> _recentComplaints({
    required int limit,
  }) async {
    // Optional collection, safe to ignore if not present/authorized.
    try {
      final snapshot = await _db.collection('complaints').get();
      final complaints = snapshot.docs.map((d) {
        final data = d.data();
        return <String, dynamic>{...data, 'id': d.id};
      }).toList();
      complaints.sort(
        (a, b) => _compareTimestampDesc(a['createdAt'], b['createdAt']),
      );
      return complaints.take(limit).toList();
    } catch (e) {
      debugPrint('recentComplaints error (ignored): $e');
      return const <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> _requestsWithoutOffers({
    required int limit,
  }) async {
    try {
      final snapshot = await _jobs.get();
      final jobs = snapshot.docs
          .map((d) => <String, dynamic>{...d.data(), 'id': d.id})
          .where((j) {
        final status = (j['status'] as String?)?.trim() ?? 'open';
        final offersCount = (j['offersCount'] as num?)?.toInt() ?? 0;
        return status == 'open' && offersCount <= 0;
      }).toList();

      jobs.sort((a, b) => _compareTimestampDesc(a['createdAt'], b['createdAt']));
      return jobs.take(limit).toList();
    } catch (e) {
      debugPrint('requestsWithoutOffers error: $e');
      return const <Map<String, dynamic>>[];
    }
  }

  static int _compareTimestampDesc(dynamic a, dynamic b) {
    final aMillis = _tsMillis(a);
    final bMillis = _tsMillis(b);
    return bMillis.compareTo(aMillis);
  }

  static int _tsMillis(dynamic value) {
    if (value is Timestamp) return value.millisecondsSinceEpoch;
    return 0;
  }
}

