import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/identity_verification_screen.dart';
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
  usePathUrlStrategy();
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
      routes: {
        '/': (context) => const HomeScreen(),
        '/welcome': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/identity-verification': (context) =>
            const IdentityVerificationScreen(),
        '/role': (context) => const RoleScreen(),
        '/customer-profile': (context) => const CustomerProfileScreen(),
        '/worker-profile': (context) => const WorkerProfileScreen(),
        '/post-job': (context) => const PostJobScreen(),
        '/jobs': (context) => const JobListScreen(),
        '/job-details': (context) => const JobDetailsScreen(),
        '/chat': (context) => const ChatScreen(),
        '/rating': (context) => const RatingScreen(),
      },
      onUnknownRoute: (_) => MaterialPageRoute<void>(
        builder: (_) => const HomeScreen(),
      ),
    );
  }
}
