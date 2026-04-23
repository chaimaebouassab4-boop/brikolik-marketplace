// ─── DATA MODELS (local, no backend yet) ───────────────────────────────────

class AppUser {
  final String id;
  final String name;
  final String phone;
  final String city;
  final String role; // 'customer' | 'worker'

  AppUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.city,
    required this.role,
  });
}

class Job {
  final String id;
  final String title;
  final String description;
  final String category;
  final String city;
  final String customerId;
  String status; // 'open' | 'in_progress' | 'done'

  Job({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.city,
    required this.customerId,
    this.status = 'open',
  });
}

class JobApplication {
  final String id;
  final String jobId;
  final String workerId;
  String status; // 'pending' | 'accepted' | 'rejected'

  JobApplication({
    required this.id,
    required this.jobId,
    required this.workerId,
    this.status = 'pending',
  });
}

class Review {
  final String id;
  final String jobId;
  final int rating; // 1–5
  final String comment;

  Review({
    required this.id,
    required this.jobId,
    required this.rating,
    required this.comment,
  });
}
