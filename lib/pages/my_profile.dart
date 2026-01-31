import 'package:belfort/core/constants/app_colors.dart';
import 'package:belfort/pages/google_login_page.dart';
import 'package:belfort/services/firebase_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:belfort/bloc/points_bloc.dart';

class MyProfilePage extends StatelessWidget {
  final String userId;
  final String userName;

  const MyProfilePage({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text('Profile'),
        titleTextStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
          color: AppColors.text,
          fontWeight: FontWeight.w800,
        ),
        iconTheme: const IconThemeData(color: AppColors.text),
      ),
      body: MyProfileView(userId: userId, userName: userName),
    );
  }
}

class MyProfileView extends StatefulWidget {
  final String userId;
  final String userName;

  final VoidCallback? onGoToDashboard;

  const MyProfileView({
    super.key,
    required this.userId,
    required this.userName,
    this.onGoToDashboard,
  });

  static const Color kGreenPrimary = Color(0xFF6DD057);
  static const Color kGreenDark = Color(0xFF1B5E20);
  static const Color kGreenMid = Color(0xFF2E7D32);
  static const Color kBg = Color(0xFFF6FBF5);
  static const Color kSurface = Color(0xFFFFFFFF);
  static const Color kSoftTint = Color(0xFFEAF8E6);
  static const Color kOutline = Color(0xFFD8E8D3);
  static const Color kText = Color(0xFF111827);
  static const Color kTextMuted = Color(0xFF6B7280);

  static const Color kDanger = Color(0xFFE11D48);

  @override
  State<MyProfileView> createState() => _MyProfileViewState();
}

class _MyProfileViewState extends State<MyProfileView> {
  @override
  void initState() {
    super.initState();
    context.read<PointsBloc>().add(PointsHistoryChanged(userId: widget.userId));
  }

  Future<void> _refresh() async {
    if (mounted) {
      context.read<PointsBloc>().add(
        PointsHistoryChanged(userId: widget.userId),
      );
    }
    await Future<void>.delayed(const Duration(milliseconds: 120));
  }

  Future<void> _signOut() async {
    await FirebaseAuthService().signOut();
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const GoogleLoginScreen()),
      (_) => false,
    );
  }

  void _showPointsInfo(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFF052E16),
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
                        'How to earn points',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppColors.softTint,
                          fontWeight: FontWeight.w900,
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
                _pointsSectionTitle('Daily Activities'),
                _pointsRow('Daily reaction', '5 pts'),
                const SizedBox(height: 12),
                _pointsSectionTitle('Streak Bonuses'),
                _pointsRow('7-day streak', '20 pts'),
                _pointsRow('14-day streak', '50 pts'),
                _pointsRow('30-day streak', '100 pts'),
                const SizedBox(height: 12),
                _pointsSectionTitle('Weekly Tasks'),
                _pointsRow('Each weekly task', '10 pts'),
                _pointsRow('Complete all tasks', '40 pts'),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _pointsSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: TextStyle(
          color: AppColors.greenPrimary.withValues(alpha: 0.85),
          fontWeight: FontWeight.w800,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _pointsRow(String left, String right) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              left,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          Text(
            right,
            style: TextStyle(
              color: AppColors.softTint.withValues(alpha: 0.95),
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _pointsTile({
    required BuildContext context,
    required String totalPoints,
    required String todayPoints,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF052E16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
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
                  Icons.gps_fixed,
                  color: AppColors.softTint,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Your points',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: AppColors.softTint,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              '$totalPoints  (+ $todayPoints today)',
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.softTint,
                side: BorderSide(
                  color: AppColors.greenPrimary.withValues(alpha: 0.75),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onPressed: () => _showPointsInfo(context),
              child: const Text(
                'See how to earn points',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _streakStrip({required String value}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.greenPrimary.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ShaderMask(
            shaderCallback: (Rect bounds) {
              return const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFFFFD54F),
                  Color(0xFFFF7043),
                  Color(0xFFE11D48),
                ],
              ).createShader(bounds);
            },
            child: const Icon(
              Icons.local_fire_department,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 34,
              fontWeight: FontWeight.w900,
              color: AppColors.greenDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Current streak',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: AppColors.greenDark.withValues(alpha: 0.75),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _refresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: AppColors.greenPrimary.withValues(alpha: 0.18),
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outline),
              ),
              child: const Icon(
                Icons.person,
                size: 56,
                color: AppColors.greenDark,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              widget.userName,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppColors.greenMid,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 18),

          BlocBuilder<PointsBloc, PointsState>(
            builder: (context, state) {
              final profileStats = state.profileStats;
              final isLoading = state.status == PointsStatus.loading;

              if (state.status == PointsStatus.failure) {
                return _infoCard(
                  title: 'Stats unavailable',
                  subtitle: 'Pull to refresh or tap to retry',
                  icon: Icons.error_outline,
                  onTap: _refresh,
                );
              }

              final total = profileStats?.total ?? 0;
              final today = profileStats?.today ?? 0;
              final streak = profileStats?.streak ?? 0;

              final totalPoints = profileStats?.totalPoints ?? 0;
              final todayPoints = profileStats?.todayPoints ?? 0;

              return Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _statCard(
                          title: 'Total reactions',
                          value: isLoading ? '…' : '$total',
                          icon: Icons.auto_graph,
                          tint: AppColors.softTint,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _statCard(
                          title: 'Today',
                          value: isLoading ? '…' : '$today',
                          icon: Icons.today,
                          tint: AppColors.greenPrimary.withValues(alpha: 0.14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _streakStrip(value: isLoading ? '…' : '$streak'),
                  const SizedBox(height: 12),
                  _pointsTile(
                    context: context,
                    totalPoints: isLoading ? '…' : '$totalPoints',
                    todayPoints: isLoading ? '…' : '$todayPoints',
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 18),

          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.danger,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onPressed: _signOut,
              icon: const Icon(Icons.logout),
              label: const Text(
                'Log out',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color tint,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 8),
            color: Colors.black.withValues(alpha: 0.05),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: tint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.outline),
            ),
            child: Icon(icon, color: AppColors.greenDark),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.text,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.outline),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.softTint,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.outline),
              ),
              child: Icon(icon, color: AppColors.greenDark),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      color: AppColors.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(color: AppColors.textMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
