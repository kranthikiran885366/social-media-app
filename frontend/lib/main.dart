import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'core/di/injection_container.dart' as di;
import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';
import 'core/services/api_service.dart';
import 'core/services/websocket_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/service_manager.dart';

import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/feed/presentation/bloc/feed_bloc.dart';
import 'features/feed/data/repositories/feed_repository.dart';
import 'features/search/presentation/bloc/search_bloc.dart';
import 'features/search/data/repositories/search_repository.dart';
import 'features/notifications/presentation/bloc/notifications_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await di.init();
  await ServiceManager.initialize();
  await NotificationService.initialize();
  WebSocketService.connect();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => di.sl<AuthBloc>()),
        BlocProvider(create: (context) => FeedBloc(FeedRepository())),
        BlocProvider(create: (context) => SearchBloc(SearchRepository())),
        BlocProvider(create: (context) => NotificationsBloc()),
      ],
      child: MaterialApp.router(
        title: 'Smart Social Platform',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AppLifecycleObserver extends WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        WebSocketService.connect();
        break;
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        WebSocketService.disconnect();
        break;
      default:
        break;
    }
  }
}