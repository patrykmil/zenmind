import 'package:belfort/firebase_options.dart';
import 'package:belfort/pages/google_login_page.dart';
import 'package:belfort/pages/my_homepage.dart';

import 'package:belfort/data/datasource/reactions_remote_ds.dart';
import 'package:belfort/data/datasource/weekly_tasks_remote_ds.dart';
import 'package:belfort/data/datasource/points_remote_ds.dart';
import 'package:belfort/data/repositories/reactions_repository.dart';
import 'package:belfort/data/repositories/weekly_tasks_repository.dart';
import 'package:belfort/data/repositories/points_repository.dart';
import 'package:belfort/bloc/save_reaction_bloc.dart';
import 'package:belfort/bloc/weekly_tasks_bloc.dart';
import 'package:belfort/bloc/points_bloc.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final firestore = FirebaseFirestore.instance;

  final reactionsRemote = ReactionsRemoteDataSource(firestore);
  final reactionsRepo = ReactionsRepository(reactionsRemote);

  final weeklyTasksRemote = WeeklyTasksRemoteDataSource(firestore);
  final weeklyTasksRepo = WeeklyTasksRepository(weeklyTasksRemote);

  final pointsRemote = PointsRemoteDataSource(firestore);
  final pointsRepo = PointsRepository(pointsRemote);

  runApp(
    AppRoot(
      reactionsRepo: reactionsRepo,
      weeklyTasksRepo: weeklyTasksRepo,
      pointsRepo: pointsRepo,
    ),
  );
}

class AppRoot extends StatelessWidget {
  const AppRoot({
    super.key,
    required this.reactionsRepo,
    required this.weeklyTasksRepo,
    required this.pointsRepo,
  });

  final ReactionsRepository reactionsRepo;
  final WeeklyTasksRepository weeklyTasksRepo;
  final PointsRepository pointsRepo;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) =>
              SaveReactionBloc(repo: reactionsRepo, pointsRepo: pointsRepo),
        ),
        BlocProvider(
          create: (_) =>
              WeeklyTasksBloc(repo: weeklyTasksRepo, pointsRepo: pointsRepo),
        ),
        BlocProvider(create: (_) => PointsBloc(repo: pointsRepo)),
      ],
      child: const MyApp(),
    );
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mental health',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF6DD057)),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const MyHomePage(title: 'ZenMind');
        }

        return const GoogleLoginScreen();
      },
    );
  }
}
