import 'package:flutter/material.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:easy_localization/easy_localization.dart';
import 'theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/identity_verification_screen.dart';
import 'screens/admin_verification_dashboard_screen.dart';
import 'screens/admin/admin_dashboard_screen.dart';
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
  await EasyLocalization.ensureInitialized();
  usePathUrlStrategy();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('fr'), Locale('ar')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const BrikolikApp(),
    ),
  );
}

class BrikolikApp extends StatelessWidget {
  const BrikolikApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Brikolik',
      theme: AppTheme.light,
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      routes: {
        '/': (context) => const HomeScreen(),
        '/welcome': (context) => const HomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/identity-verification': (context) =>
            const IdentityVerificationScreen(),
        '/admin': (context) => const AdminDashboardScreen(),
        '/admin-verifications': (context) =>
            const AdminVerificationDashboardScreen(),
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
