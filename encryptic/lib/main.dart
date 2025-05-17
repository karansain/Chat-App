import 'package:encryptic/presentation/Theme/themeProvider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart'; // Supabase import
import 'bloc/home/messaging/club/club_message_bloc.dart';
import 'bloc/home/messaging/one_on_one/message_bloc.dart';
import 'data/repositories/message_repository.dart';
import 'data/services/web_socket_service.dart';
import 'presentation/screens/others/splash_screen.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/home/clubs/clubs_bloc.dart';
import 'bloc/home/clubs/clubs_event.dart';
import 'bloc/home/friends/friends_bloc.dart';
import 'bloc/home/friends/friends_event.dart';
import 'data/repositories/auth_repository.dart';
import 'data/repositories/home_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String url = "ws://192.168.29.123:8080/ws";

  // Initialize WebSocketService
  final WebSocketService webSocketService = WebSocketService(url);

  // Initialize Supabase
  try {
    await Supabase.initialize(
      url: 'https://hzcswekjrpilxjplqdnw.supabase.co',
      anonKey:
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh6Y3N3ZWtqcnBpbHhqcGxxZG53Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjYyODkzNjIsImV4cCI6MjA0MTg2NTM2Mn0.-nms71ZJnTH-kIkayUdXS79HCq-_PkiysTvdsFYcWZc',
    );
    print("Supabase initialized successfully");
  } catch (e) {
    print("Supabase initialization failed: $e");
  }

  runApp(MultiProvider(
    providers: [
      // Provide ThemeProvider
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
      ),
      // Provide AuthBloc
      Provider<AuthBloc>(
        create: (context) {
          final authRepository = AuthRepository();
          return AuthBloc(authRepository: authRepository);
        },
      ),
      // Provide WebSocketService globally
      Provider<WebSocketService>(
        create: (_) => webSocketService,
      ),
      // Provide HomeRepository, using WebSocketService as a dependency
      ProxyProvider<WebSocketService, HomeRepository>(
        update: (context, webSocketService, previous) => HomeRepository(webSocketService),
      ),
      // Provide MessagingRepository
      Provider<MessagingRepository>(
        create: (_) => MessagingRepository(webSocketService),
      ),
      // Provide FriendsBloc
      BlocProvider<FriendsBloc>(
        create: (context) => FriendsBloc(homeRepository: context.read<HomeRepository>())
          ..add(FetchFriends('username')), // Fetch friends on app load
      ),
      // Provide ClubsBloc
      BlocProvider<ClubsBloc>(
        create: (context) => ClubsBloc(homeRepository: context.read<HomeRepository>())
          ..add(FetchClub()), // Fetch clubs on app load
      ),
      // Provide MessagingBloc
      BlocProvider<MessagingBloc>(
        create: (context) => MessagingBloc(
          messagingRepository: context.read<MessagingRepository>(),
        ),
      ),
      BlocProvider<ClubMessagingBloc>(
        create: (context) => ClubMessagingBloc(
          messagingRepository: context.read<MessagingRepository>(),
        ),
      ),
      // Provide HomeBloc
      // BlocProvider<HomeBloc>(
      //   create: (context) => HomeBloc(homeRepository: context.read<HomeRepository>()),
      // ),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Encryptic',
      debugShowCheckedModeBanner: false,
      theme: Provider.of<ThemeProvider>(context).themeData,
      home: SplashScreen(),
    );
  }
}
