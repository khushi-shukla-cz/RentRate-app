import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/app_config.dart';
import 'providers/auth_provider.dart';
import 'providers/property_provider.dart';
import 'providers/providers.dart';
import 'screens/auth_screens.dart';
import 'screens/dashboard_screens.dart';
import 'screens/property_screens.dart';
import 'screens/other_screens.dart';

void main() {
  runApp(const RentRateApp());
}

class RentRateApp extends StatelessWidget {
  const RentRateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => PropertyProvider()),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => MessageProvider()),
      ],
      child: MaterialApp(
        title: 'RentRate',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        initialRoute: '/',
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    final name = settings.name ?? '/';
    final args = settings.arguments as Map<String, dynamic>?;

    switch (name) {
      case '/':
        return _route(const SplashScreen());
      case '/login':
        return _route(const LoginScreen());
      case '/register':
        return _route(const RegisterScreen());
      case '/tenant':
        return _route(const TenantDashboard());
      case '/owner':
        return _route(const OwnerDashboard());
      case '/about':
        return _route(const AboutScreen());
      case '/contact':
        return _route(const ContactScreen());
      case '/property/add':
        return _route(const AddPropertyScreen());
      default:
        // Dynamic routes
        if (name.startsWith('/property/')) {
          final id = name.replaceFirst('/property/', '');
          return _route(PropertyDetailsScreen(propertyId: id));
        }
        if (name.startsWith('/messages/')) {
          final partnerId = name.replaceFirst('/messages/', '');
          return _route(MessageThreadScreen(
            partnerId: partnerId,
            partnerName: args?['name'] ?? 'User',
            propertyId: args?['propertyId'],
          ));
        }
        if (name == '/review/submit') {
          return _route(SubmitReviewScreen(
            reviewedUserId: args?['reviewedUserId'] ?? '',
            reviewedUserName: args?['reviewedUserName'] ?? 'User',
            propertyId: args?['propertyId'],
            reviewType: args?['reviewType'] ?? 'tenant-to-owner',
          ));
        }
        return _route(const SplashScreen());
    }
  }

  PageRoute _route(Widget page) => MaterialPageRoute(builder: (_) => page);
}
