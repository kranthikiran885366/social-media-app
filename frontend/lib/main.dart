import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'core/di/injection_container.dart';
import 'core/theme/app_theme.dart';
import 'core/routes/app_router.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/feed/presentation/bloc/feed_bloc.dart';
import 'features/ai_moderation/presentation/bloc/ai_moderation_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase - Temporarily disabled
  // await Firebase.initializeApp();
  
  // Initialize dependencies
  await initializeDependencies();
  
  // Set system UI overlay style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  runApp(const SmartSocialApp());
}

class SmartSocialApp extends StatelessWidget {
  const SmartSocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => getIt<AuthBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<FeedBloc>(),
        ),
        BlocProvider(
          create: (_) => getIt<AiModerationBloc>(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Smart Social Platform',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        themeMode: ThemeMode.light,
        routerConfig: AppRouter.router,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaleFactor: 1.0, // Prevent text scaling
            ),
            child: child!,
          );
        },
      ),
    );
  }
}

// Add missing auth event
class CheckAuthStatus extends AuthEvent {
  @override
  List<Object> get props => [];
}