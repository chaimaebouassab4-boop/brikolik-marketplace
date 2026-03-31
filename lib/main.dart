import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/role_screen.dart';
import 'screens/customer_profile_screen.dart';
import 'screens/worker_profile_screen.dart';
import 'screens/post_job_screen.dart';
import 'screens/job_list_screen.dart';
import 'screens/job_details_screen.dart';
import 'screens/chat_screen.dart';
import 'screens/rating_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const BrikolikApp());
}

class BrikolikApp extends StatelessWidget {
  const BrikolikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brikolik',
      theme: AppTheme.light,
      initialRoute: '/welcome',
      routes: {
        '/welcome':          (context) => const HomeScreen(),
        '/login':            (context) => const LoginScreen(),
        '/role':             (context) => const RoleScreen(),
        '/customer-profile': (context) => const CustomerProfileScreen(),
        '/worker-profile':   (context) => const WorkerProfileScreen(),
        '/post-job':         (context) => const PostJobScreen(),
        '/jobs':             (context) => const JobListScreen(),
        '/job-details':      (context) => const JobDetailsScreen(),
        '/chat':             (context) => const ChatScreen(),
        '/rating':           (context) => const RatingScreen(),
      },
    );
  }
}
