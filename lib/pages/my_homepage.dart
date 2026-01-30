import 'dart:math' as math;

import 'package:belfort/core/constants/app_colors.dart';
import 'package:belfort/core/constants/mood_options.dart';
import 'package:belfort/data/models/mood_option.dart';
import 'package:belfort/data/models/weekly_task.dart';
import 'package:belfort/pages/breathing_page.dart';
import 'package:belfort/pages/my_profile.dart';
import 'package:belfort/pages/statistics_page.dart';
import 'package:belfort/services/firebase_auth_service.dart';
import 'package:belfort/bloc/save_reaction_bloc.dart';
import 'package:belfort/widgets/home/daily_fact_card.dart';
import 'package:belfort/widgets/home/weekly_task_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;
  late final AnimationController _floatController;
  late final List<WeeklyTask> _weeklyTasks;

  MoodOption? _selectedMood;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);

    _weeklyTasks = [
      WeeklyTask(
        icon: Icons.self_improvement,
        title: '2-minute breathing',
        subtitle: 'Slow inhale and exhale for 2 minutes.',
      ),
      WeeklyTask(
        icon: Icons.directions_walk,
        title: '10-minute walk',
        subtitle: 'Preferably outside or near greenery.',
      ),
      WeeklyTask(
        icon: Icons.water_drop,
        title: 'Hydration check',
        subtitle: 'Drink a glass of water right now.',
      ),
      WeeklyTask(
        icon: Icons.accessibility_new,
        title: 'Stretch break',
        subtitle: '3 minutes of gentle stretching.',
      ),
      WeeklyTask(
        icon: Icons.edit_note,
        title: 'Gratitude note',
        subtitle: 'Write down 3 things you appreciate.',
      ),
    ];
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  String _dailyFunFact() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    final dayOfYear = now.difference(start).inDays + 1;

    const facts = [
      'A short walk (10-15 minutes) can noticeably improve your mood.',
      'Hydration affects focus and wellbeing more than most people expect.',
      'Sleeping less than 7 hours often lowers stress tolerance the next day.',
      'Even one minute of deep breathing can reduce tension.',
      'A consistent morning routine can reduce decision fatigue during the day.',
    ];

    return facts[dayOfYear % facts.length];
  }

  void _showSavedDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF052E16),
          insetPadding: const EdgeInsets.symmetric(horizontal: 22),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Mood saved',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.softTint,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.of(ctx).pop(),
                      icon: Icon(Icons.close, color: AppColors.softTint),
                      tooltip: 'Close',
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedMood == null
                      ? 'Saved.'
                      : 'Saved: ${_selectedMood!.emoji} ${_selectedMood!.label}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.90),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.greenPrimary,
                      foregroundColor: AppColors.greenDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text(
                      'OK',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyTasksCard(BuildContext context) {
    final theme = Theme.of(context);
    final doneCount = _weeklyTasks.where((t) => t.isDone).length;
    final total = _weeklyTasks.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.greenPrimary.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outline),
                ),
                child: const Icon(
                  Icons.sentiment_satisfied_alt,
                  color: AppColors.greenDark,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Tasks for this week',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Text(
                '$doneCount/$total',
                style: theme.textTheme.labelLarge?.copyWith(
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ..._weeklyTasks.asMap().entries.map((entry) {
            final index = entry.key;
            final task = entry.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: WeeklyTaskItem(
                task: task,
                onToggle: (v) => setState(() => _weeklyTasks[index].isDone = v),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = FirebaseAuthService();
    final user = authService.currentUser;

    final userId = user?.uid ?? '';
    final email = user?.email;
    final userName =
        (user?.displayName != null && user!.displayName!.trim().isNotEmpty)
        ? user.displayName!.trim()
        : (email != null && email.contains('@'))
        ? email.split('@').first
        : 'User';

    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shadowColor: Colors.black.withValues(alpha: 0.10),
        centerTitle: true,
        title: Image.asset(
          'lib/assets/leaf.png',
          height: 74,
          fit: BoxFit.contain,
        ),
      ),

      body: IndexedStack(
        index: _navIndex,
        children: [
          _buildMoodTab(context, userId: userId, userName: userName),
          const StatisticsPage(),
          MyProfileView(
            userId: userId,
            userName: userName,
            onGoToDashboard: () => setState(() => _navIndex = 1),
          ),
        ],
      ),

      bottomNavigationBar: Theme(
        data: Theme.of(context).copyWith(
          navigationBarTheme: NavigationBarThemeData(
            backgroundColor: AppColors.surface,
            indicatorColor: AppColors.greenPrimary.withValues(alpha: 0.22),
            labelTextStyle: WidgetStateProperty.all(
              const TextStyle(fontWeight: FontWeight.w600),
            ),
            iconTheme: WidgetStateProperty.resolveWith((states) {
              final selected = states.contains(WidgetState.selected);
              return IconThemeData(
                color: selected ? AppColors.greenMid : AppColors.textMuted,
              );
            }),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _navIndex,
          onDestinationSelected: (i) => setState(() => _navIndex = i),
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.sentiment_satisfied_alt_outlined),
              selectedIcon: Icon(Icons.sentiment_satisfied_alt),
              label: 'Today',
            ),
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodTab(
    BuildContext context, {
    required String userId,
    required String userName,
  }) {
    final theme = Theme.of(context);
    final fact = _dailyFunFact();

    return BlocListener<SaveReactionBloc, SaveReactionState>(
      listener: (context, state) {
        if (state.status == SaveReactionStatus.success) {
          _showSavedDialog(context);
        }
        if (state.status == SaveReactionStatus.failure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Could not save reaction'),
            ),
          );
        }
      },
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Hello, $userName',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: AppColors.greenMid,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    InkWell(
                      borderRadius: BorderRadius.circular(999),
                      onTap: () => setState(() => _navIndex = 2),
                      child: CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.greenPrimary.withValues(
                          alpha: 0.25,
                        ),
                        child: const Icon(
                          Icons.person,
                          color: AppColors.greenDark,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF052E16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How are you feeling today?',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: AppColors.softTint,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 6),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Center(
                  child: AnimatedBuilder(
                    animation: _floatController,
                    builder: (context, child) {
                      final t = _floatController.value;
                      final dy = math.sin(t * math.pi) * 10;
                      final rot = math.sin(t * math.pi) * 0.03;
                      return Transform.translate(
                        offset: Offset(0, -dy),
                        child: Transform.rotate(angle: rot, child: child),
                      );
                    },
                    child: InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const BreathingPage(),
                          ),
                        );
                      },
                      child: Container(
                        width: 320,
                        height: 320,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: AppColors.outline),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 18,
                              color: Colors.black.withValues(alpha: 0.05),
                            ),
                          ],
                        ),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Positioned(
                              top: 16,
                              child: Text(
                                "Start Breathing Exercise",
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: AppColors.textMuted,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(40.0),
                              child: SvgPicture.asset(
                                'lib/assets/main-yoga.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                DailyFactCard(fact: fact),
                const SizedBox(height: 18),

                Text(
                  'Pick an emoji:',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: AppColors.text,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: moodOptions.map((m) {
                    final selected = _selectedMood == m;
                    return ChoiceChip(
                      label: Text('${m.emoji}  ${m.label}'),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedMood = m),
                      selectedColor: AppColors.greenPrimary.withValues(
                        alpha: 0.22,
                      ),
                      backgroundColor: AppColors.surface,
                      side: BorderSide(
                        color: selected
                            ? AppColors.greenPrimary
                            : AppColors.outline,
                      ),
                      labelStyle: theme.textTheme.bodyMedium?.copyWith(
                        color: selected ? AppColors.greenDark : AppColors.text,
                        fontWeight: selected
                            ? FontWeight.w800
                            : FontWeight.w600,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                BlocBuilder<SaveReactionBloc, SaveReactionState>(
                  builder: (context, state) {
                    final isLoading =
                        state.status == SaveReactionStatus.loading;

                    return SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF052E16),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed:
                            (userId.isEmpty ||
                                _selectedMood == null ||
                                isLoading)
                            ? null
                            : () {
                                context.read<SaveReactionBloc>().add(
                                  ReactionSubmitPressed(
                                    userId: userId,
                                    mood: _selectedMood!,
                                  ),
                                );
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Save mood',
                                style: TextStyle(
                                  color: Color(0xFFEAF8E6),
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 18),
                _buildWeeklyTasksCard(context),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
