import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/date_utils.dart';
import '../models/coaching_session_model.dart';

class SessionDetailPage extends StatelessWidget {
  final CoachingSessionModel session;
  const SessionDetailPage({super.key, required this.session});

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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        title: const Text('Session Details',
            style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            _InfoCard(children: [
              _DetailRow(
                icon: Icons.sports_tennis,
                label: 'Title',
                value: session.coaching?.title ?? 'Session',
              ),
              _DetailRow(
                icon: Icons.category_outlined,
                label: 'Type',
                value: session.coaching?.coachingType ?? '–',
              ),
              _DetailRow(
                icon: Icons.circle,
                label: 'Status',
                valueWidget: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    session.status,
                    style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: _statusColor),
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 12),
            // Date & Time card
            _InfoCard(children: [
              _DetailRow(
                icon: Icons.calendar_today,
                label: 'Date',
                value: DateHelper.fullDate(session.sessionDate),
              ),
              _DetailRow(
                icon: Icons.access_time,
                label: 'Time',
                value: DateHelper.prettyTimeRange(session.startTime, session.endTime),
              ),
            ]),
            const SizedBox(height: 12),
            // Venue & Players card
            _InfoCard(children: [
              if (session.arenaName != null)
                _DetailRow(
                  icon: Icons.location_on_outlined,
                  label: 'Arena',
                  value: session.arenaName!,
                ),
              _DetailRow(
                icon: Icons.people_outline,
                label: 'Players',
                value:
                    '${session.registeredPlayers.isNotEmpty ? session.registeredPlayers.length : session.registeredCount} / ${session.coaching?.maxPlayers ?? '–'} registered',
              ),
            ]),
            if (session.registeredPlayers.isNotEmpty) ...[
              const SizedBox(height: 12),
              _PlayersCard(players: session.registeredPlayers),
            ],
          ],
        ),
      ),
    );
  }

}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  const _InfoCard({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        children: children
            .expand((w) => [w, const Divider(height: 1)])
            .toList()
          ..removeLast(),
      ),
    );
  }
}

class _PlayersCard extends StatelessWidget {
  final List<SessionPlayer> players;
  const _PlayersCard({required this.players});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Row(
              children: [
                Icon(Icons.people, size: 16, color: AppColors.primary),
                const SizedBox(width: 8),
                Text('Registered Players',
                    style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1A1A1A))),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text('${players.length}',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary)),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: players.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 16),
            itemBuilder: (_, i) {
              final p = players[i];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                      child: Text(
                        (p.name?.isNotEmpty == true) ? p.name![0].toUpperCase() : '?',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.name ?? 'Player',
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFF1A1A1A))),
                          if (p.phone != null)
                            Text(p.phone!,
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.black45)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? value;
  final Widget? valueWidget;

  const _DetailRow({
    required this.icon,
    required this.label,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: 12),
          Text(label,
              style: const TextStyle(fontSize: 13, color: Colors.black54)),
          const Spacer(),
          valueWidget ??
              Text(
                value ?? '–',
                style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A)),
              ),
        ],
      ),
    );
  }
}
