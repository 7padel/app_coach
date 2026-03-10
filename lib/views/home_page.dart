import 'package:flutter/material.dart';
import '../core/base/base_view.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_utils.dart';
import '../models/coaching_session_model.dart';
import '../viewmodels/home_view_model.dart';
import 'session_detail_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      model: HomeViewModel(),
      onModelReady: (vm) => vm.loadSessions(context),
      builder: (context, vm, _) => Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          title: const Text('My Schedule',
              style: TextStyle(fontWeight: FontWeight.w600)),
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () => vm.loadSessions(context, refresh: true),
            ),
          ],
        ),
        body: vm.isLoading && vm.sessions.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => vm.loadSessions(context, refresh: true),
                child: vm.sessions.isEmpty
                    ? _EmptyState()
                    : _SessionList(vm: vm),
              ),
      ),
    );
  }
}

class _SessionList extends StatelessWidget {
  final HomeViewModel vm;
  const _SessionList({required this.vm});

  @override
  Widget build(BuildContext context) {
    final today = vm.todaySessions;
    final upcoming = vm.upcomingSessions;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (today.isNotEmpty) ...[
          _SectionHeader(title: "Today's Sessions", count: today.length),
          const SizedBox(height: 8),
          ...today.map((s) => _SessionCard(session: s, isToday: true)),
          const SizedBox(height: 16),
        ],
        if (upcoming.isNotEmpty) ...[
          _SectionHeader(title: 'Upcoming', count: upcoming.length),
          const SizedBox(height: 8),
          ...upcoming.map((s) => _SessionCard(session: s, isToday: false)),
        ],
        if (vm.hasMore)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: TextButton(
                onPressed: () => vm.loadMore(context),
                child: vm.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Load more'),
              ),
            ),
          ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final int count;
  const _SectionHeader({required this.title, required this.count});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF222222))),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha:0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text('$count',
              style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary)),
        ),
      ],
    );
  }
}

class _SessionCard extends StatelessWidget {
  final CoachingSessionModel session;
  final bool isToday;
  const _SessionCard({required this.session, required this.isToday});

  Color get _statusColor {
    switch (session.status) {
      case 'completed':
        return const Color(0xFF22C55E);
      case 'cancelled':
        return const Color(0xFFEF4444);
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
            builder: (_) => SessionDetailPage(session: session)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: isToday
              ? Border.all(color: AppColors.secondary, width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha:0.06),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              // Date column
              Container(
                width: 48,
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: isToday
                      ? AppColors.secondary
                      : AppColors.primary.withValues(alpha:0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Text(
                      DateHelper.formatDate(date: session.sessionDate, format: 'dd'),
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: isToday ? AppColors.primary : AppColors.primary),
                    ),
                    Text(
                      DateHelper.formatDate(date: session.sessionDate, format: 'MMM'),
                      style: TextStyle(
                          fontSize: 11,
                          color: isToday
                              ? AppColors.primary
                              : AppColors.primary.withValues(alpha:0.7)),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Info column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.coaching?.title ?? 'Session',
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.access_time,
                            size: 13, color: Colors.black45),
                        const SizedBox(width: 3),
                        Text(
                          DateHelper.prettyTimeRange(session.startTime, session.endTime),
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black54),
                        ),
                      ],
                    ),
                    if (session.arenaName != null) ...[
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on,
                              size: 13, color: Colors.black45),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              session.arenaName!,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.black54),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              // Right side
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: _statusColor.withValues(alpha:0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      session.status,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _statusColor),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${session.registeredPlayers.isNotEmpty ? session.registeredPlayers.length : session.registeredCount}/${session.coaching?.maxPlayers ?? '–'}',
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black54),
                  ),
                  const Text('players',
                      style: TextStyle(fontSize: 10, color: Colors.black38)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.25),
        const Icon(Icons.calendar_today_outlined, size: 64, color: Colors.black26),
        const SizedBox(height: 16),
        const Center(
          child: Text('No sessions scheduled',
              style: TextStyle(fontSize: 16, color: Colors.black45)),
        ),
      ],
    );
  }
}
