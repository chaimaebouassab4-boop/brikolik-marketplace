import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class AdminOverviewData {
  const AdminOverviewData({
    required this.totalClients,
    required this.totalWorkers,
    required this.pendingRequests,
    required this.inProgressJobs,
    required this.completedJobs,
    required this.pendingVerifications,
    required this.dayRevenue,
    required this.monthRevenue,
    required this.totalMissionRevenue,
    required this.activeMissionValue,
    required this.averageMissionRevenue,
    required this.verificationRate,
    required this.missionCompletionRate,
    required this.recentSignups,
    required this.recentRequests,
    required this.recentMissions,
    required this.recentComplaints,
    required this.recentActivities,
    required this.requestsWithoutOffers,
    required this.missionsTrend,
    required this.revenueTrend,
  });

  final int totalClients;
  final int totalWorkers;
  final int pendingRequests;
  final int inProgressJobs;
  final int completedJobs;
  final int pendingVerifications;
  final double dayRevenue;
  final double monthRevenue;
  final double totalMissionRevenue;
  final double activeMissionValue;
  final double averageMissionRevenue;
  final double verificationRate;
  final double missionCompletionRate;

  final List<Map<String, dynamic>> recentSignups;
  final List<Map<String, dynamic>> recentRequests;
  final List<Map<String, dynamic>> recentMissions;
  final List<Map<String, dynamic>> recentComplaints;
  final List<Map<String, dynamic>> recentActivities;
  final List<Map<String, dynamic>> requestsWithoutOffers;
  final List<double> missionsTrend;
  final List<double> revenueTrend;
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
    try {
      final usersFuture = _users.get();
      final jobsFuture = _jobs.get();
      final offersFuture = _safeOffers();
      final complaintsFuture = _safeComplaints();

      final usersSnapshot = await usersFuture;
      final jobsSnapshot = await jobsFuture;
      final offers = await offersFuture;
      final complaints = await complaintsFuture;

      final users = usersSnapshot.docs
          .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
          .toList();
      final jobs = jobsSnapshot.docs
          .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
          .toList();
      final acceptedOffersByJob = _acceptedOffersByJob(offers);
      final missionJobs = _decorateMissionJobs(jobs, acceptedOffersByJob);

      final totalClients = _countByRole(users, 'customer');
      final totalWorkers = _countByRole(users, 'worker');
      final verifiedWorkers = users.where((user) {
        final role = (user['role'] as String?)?.trim();
        return role == 'worker' && user['isVerified'] == true;
      }).length;

      final pendingRequests = _countJobsByStatus(jobs, 'open');
      final inProgressJobs = _countJobsByStatus(jobs, 'inprogress');
      final completedJobs = _countJobsByStatus(jobs, 'done');
      final pendingVerifications = users.where((user) {
        final requested = user['verificationRequested'] == true;
        final status = (user['verificationStatus'] as String?)?.trim();
        return requested || status == 'pending';
      }).length;

      final verificationRate = totalWorkers == 0
          ? 0.0
          : (verifiedWorkers / totalWorkers.toDouble()) * 100;

      final dayRevenue = _sumAcceptedOffers(
        offers,
        predicate: (when, now) => _isSameDay(when, now),
      );
      final monthRevenue = _sumAcceptedOffers(
        offers,
        predicate: (when, now) =>
            when.year == now.year && when.month == now.month,
      );
      final totalMissionRevenue = missionJobs.fold<double>(
        0.0,
        (sum, job) => sum + _parseMoney(job['acceptedPrice']),
      );
      final activeMissionValue = missionJobs
          .where((job) => (job['status'] as String?)?.trim() == 'inprogress')
          .fold<double>(
            0.0,
            (sum, job) => sum + _parseMoney(job['acceptedPrice']),
          );
      final averageMissionRevenue = missionJobs.isEmpty
          ? 0.0
          : totalMissionRevenue / missionJobs.length.toDouble();
      final missionCompletionRate = missionJobs.isEmpty
          ? 0.0
          : (completedJobs / missionJobs.length.toDouble()) * 100;

      final recentSignups = _takeRecent(users, recentLimit, 'createdAt');
      final recentRequests = _takeRecent(jobs, recentLimit, 'createdAt');
      final recentMissions = _takeRecent(missionJobs, recentLimit, 'activityAt');
      final recentComplaints =
          _takeRecent(complaints, recentLimit, 'createdAt');
      final requestsWithoutOffers = jobs.where((job) {
        final status = (job['status'] as String?)?.trim() ?? 'open';
        final offersCount = (job['offersCount'] as num?)?.toInt() ?? 0;
        return status == 'open' && offersCount <= 0;
      }).toList()
        ..sort((a, b) => _compareTimestampDesc(a['createdAt'], b['createdAt']));

      final recentActivities = _buildActivities(
        users: users,
        jobs: jobs,
        offers: offers,
        complaints: complaints,
        limit: 8,
      );

      return AdminOverviewData(
        totalClients: totalClients,
        totalWorkers: totalWorkers,
        pendingRequests: pendingRequests,
        inProgressJobs: inProgressJobs,
        completedJobs: completedJobs,
        pendingVerifications: pendingVerifications,
        dayRevenue: dayRevenue,
        monthRevenue: monthRevenue,
        totalMissionRevenue: totalMissionRevenue,
        activeMissionValue: activeMissionValue,
        averageMissionRevenue: averageMissionRevenue,
        verificationRate: verificationRate,
        missionCompletionRate: missionCompletionRate,
        recentSignups: recentSignups,
        recentRequests: recentRequests,
        recentMissions: recentMissions,
        recentComplaints: recentComplaints,
        recentActivities: recentActivities,
        requestsWithoutOffers: requestsWithoutOffers.take(alertLimit).toList(),
        missionsTrend: _buildJobsTrend(jobs, days: 7),
        revenueTrend: _buildRevenueTrend(offers, days: 7),
      );
    } catch (e) {
      debugPrint('loadOverview error: $e');
      return const AdminOverviewData(
        totalClients: 0,
        totalWorkers: 0,
        pendingRequests: 0,
        inProgressJobs: 0,
        completedJobs: 0,
        pendingVerifications: 0,
        dayRevenue: 0,
        monthRevenue: 0,
        totalMissionRevenue: 0,
        activeMissionValue: 0,
        averageMissionRevenue: 0,
        verificationRate: 0,
        missionCompletionRate: 0,
        recentSignups: <Map<String, dynamic>>[],
        recentRequests: <Map<String, dynamic>>[],
        recentMissions: <Map<String, dynamic>>[],
        recentComplaints: <Map<String, dynamic>>[],
        recentActivities: <Map<String, dynamic>>[],
        requestsWithoutOffers: <Map<String, dynamic>>[],
        missionsTrend: <double>[],
        revenueTrend: <double>[],
      );
    }
  }

  Future<List<Map<String, dynamic>>> _safeOffers() async {
    try {
      final snapshot = await _db.collectionGroup('offers').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return <String, dynamic>{
          ...data,
          'id': doc.id,
          'jobId': doc.reference.parent.parent?.id ?? '',
        };
      }).toList();
    } catch (e) {
      debugPrint('offers load error (ignored): $e');
      return const <Map<String, dynamic>>[];
    }
  }

  Future<List<Map<String, dynamic>>> _safeComplaints() async {
    try {
      final snapshot = await _db.collection('complaints').get();
      return snapshot.docs
          .map((doc) => <String, dynamic>{...doc.data(), 'id': doc.id})
          .toList();
    } catch (e) {
      debugPrint('complaints load error (ignored): $e');
      return const <Map<String, dynamic>>[];
    }
  }

  int _countByRole(List<Map<String, dynamic>> users, String role) {
    return users.where((user) {
      return (user['role'] as String?)?.trim() == role;
    }).length;
  }

  int _countJobsByStatus(List<Map<String, dynamic>> jobs, String status) {
    return jobs.where((job) {
      return (job['status'] as String?)?.trim() == status;
    }).length;
  }

  List<Map<String, dynamic>> _takeRecent(
    List<Map<String, dynamic>> items,
    int limit,
    String field,
  ) {
    final copy = List<Map<String, dynamic>>.from(items)
      ..sort((a, b) => _compareTimestampDesc(a[field], b[field]));
    return copy.take(limit).toList();
  }

  List<Map<String, dynamic>> _buildActivities({
    required List<Map<String, dynamic>> users,
    required List<Map<String, dynamic>> jobs,
    required List<Map<String, dynamic>> offers,
    required List<Map<String, dynamic>> complaints,
    required int limit,
  }) {
    final entries = <Map<String, dynamic>>[];

    for (final user in users) {
      entries.add({
        'type': 'signup',
        'title': (user['fullName'] as String?)?.trim().isNotEmpty == true
            ? (user['fullName'] as String).trim()
            : 'Nouvel utilisateur',
        'subtitle': (user['email'] as String?)?.trim() ?? '-',
        'createdAt': user['createdAt'],
        'badge': (user['role'] as String?)?.trim() ?? 'user',
      });
    }

    for (final job in jobs) {
      entries.add({
        'type': 'request',
        'title': (job['title'] as String?)?.trim().isNotEmpty == true
            ? (job['title'] as String).trim()
            : 'Nouvelle demande',
        'subtitle': (job['city'] as String?)?.trim() ?? '-',
        'createdAt': job['createdAt'],
        'badge': (job['status'] as String?)?.trim() ?? 'open',
      });
    }

    for (final offer in offers) {
      entries.add({
        'type': 'offer',
        'title': (offer['workerName'] as String?)?.trim().isNotEmpty == true
            ? 'Offre: ${(offer['workerName'] as String).trim()}'
            : 'Nouvelle offre',
        'subtitle': (offer['price'] as String?)?.trim() ?? '-',
        'createdAt': _offerTimestamp(offer),
        'badge': (offer['status'] as String?)?.trim() ?? 'pending',
      });
    }

    for (final complaint in complaints) {
      entries.add({
        'type': 'complaint',
        'title': (complaint['title'] as String?)?.trim().isNotEmpty == true
            ? (complaint['title'] as String).trim()
            : 'Nouvelle reclamation',
        'subtitle': (complaint['status'] as String?)?.trim() ?? 'open',
        'createdAt': complaint['createdAt'],
        'badge': 'reclamation',
      });
    }

    entries
        .sort((a, b) => _compareTimestampDesc(a['createdAt'], b['createdAt']));
    return entries.take(limit).toList();
  }

  Map<String, Map<String, dynamic>> _acceptedOffersByJob(
    List<Map<String, dynamic>> offers,
  ) {
    final map = <String, Map<String, dynamic>>{};
    for (final offer in offers) {
      final status = (offer['status'] as String?)?.trim();
      final jobId = (offer['jobId'] as String?)?.trim() ?? '';
      if (status != 'accepted' || jobId.isEmpty) continue;

      final current = map[jobId];
      final candidateTs = _offerTimestamp(offer);
      if (current == null ||
          _compareTimestampDesc(candidateTs, _offerTimestamp(current)) < 0) {
        map[jobId] = offer;
      }
    }
    return map;
  }

  List<Map<String, dynamic>> _decorateMissionJobs(
    List<Map<String, dynamic>> jobs,
    Map<String, Map<String, dynamic>> acceptedOffersByJob,
  ) {
    return jobs.where((job) {
      final acceptedWorkerId = (job['acceptedWorkerId'] as String?)?.trim();
      final status = (job['status'] as String?)?.trim();
      return (acceptedWorkerId?.isNotEmpty == true) ||
          status == 'inprogress' ||
          status == 'done';
    }).map((job) {
      final acceptedOffer = acceptedOffersByJob[(job['id'] as String?) ?? ''];
      final acceptedPrice = acceptedOffer?['price'] ??
          job['acceptedPrice'] ??
          job['budgetMax'] ??
          job['budget'];
      return <String, dynamic>{
        ...job,
        'acceptedPrice': acceptedPrice,
        'activityAt':
            job['acceptedAt'] ?? job['updatedAt'] ?? job['createdAt'],
      };
    }).toList();
  }

  double _sumAcceptedOffers(
    List<Map<String, dynamic>> offers, {
    required bool Function(DateTime when, DateTime now) predicate,
  }) {
    final now = DateTime.now();
    var total = 0.0;
    for (final offer in offers) {
      final status = (offer['status'] as String?)?.trim();
      if (status != 'accepted') continue;
      final ts = _offerTimestamp(offer);
      if (ts is! Timestamp) continue;
      final when = ts.toDate();
      if (!predicate(when, now)) continue;
      total += _parseMoney(offer['price']);
    }
    return total;
  }

  List<double> _buildJobsTrend(List<Map<String, dynamic>> jobs,
      {required int days}) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final buckets = List<int>.filled(days, 0);

    for (final job in jobs) {
      final createdAt = job['createdAt'];
      if (createdAt is! Timestamp) continue;
      final when = createdAt.toDate();
      if (when.isBefore(start)) continue;
      final day = DateTime(when.year, when.month, when.day);
      final idx = day.difference(start).inDays;
      if (idx >= 0 && idx < buckets.length) {
        buckets[idx] = buckets[idx] + 1;
      }
    }

    return buckets.map((value) => value.toDouble()).toList();
  }

  List<double> _buildRevenueTrend(
    List<Map<String, dynamic>> offers, {
    required int days,
  }) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    final buckets = List<double>.filled(days, 0);

    for (final offer in offers) {
      final status = (offer['status'] as String?)?.trim();
      if (status != 'accepted') continue;
      final timestamp = _offerTimestamp(offer);
      if (timestamp is! Timestamp) continue;
      final when = timestamp.toDate();
      if (when.isBefore(start)) continue;
      final day = DateTime(when.year, when.month, when.day);
      final idx = day.difference(start).inDays;
      if (idx >= 0 && idx < buckets.length) {
        buckets[idx] = buckets[idx] + _parseMoney(offer['price']);
      }
    }

    return buckets;
  }

  dynamic _offerTimestamp(Map<String, dynamic> offer) {
    return offer['acceptedAt'] ?? offer['updatedAt'] ?? offer['createdAt'];
  }

  double _parseMoney(dynamic raw) {
    final text = (raw ?? '').toString().trim();
    if (text.isEmpty) return 0;

    final normalized = text.replaceAll(',', '.');
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(normalized);
    if (match == null) return 0;
    return double.tryParse(match.group(1) ?? '') ?? 0;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
