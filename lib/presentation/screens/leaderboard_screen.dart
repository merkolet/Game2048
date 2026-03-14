import 'package:flutter/material.dart';

import '../../core/app_scope.dart';
import '../../core/services/cloud_user_stats_service.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final CloudUserStatsService _cloud;
  late Future<List<LeaderboardSection>> _future;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initialized) return;
    _cloud = AppScope.of(context).di.cloudUserStatsService;
    _future = _cloud.fetchLeaderboardSections();
    _initialized = true;
  }

  Future<void> _reload() async {
    final newFuture = _cloud.fetchLeaderboardSections();
    setState(() {
      _future = newFuture;
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text('Лидерборд'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Обновить',
          ),
        ],
      ),
      body: FutureBuilder<List<LeaderboardSection>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFFEDC22E)),
            );
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Не удалось загрузить лидерборд.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFBBADA0)),
                ),
              ),
            );
          }

          final sections = snapshot.data ?? const [];
          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final section in sections) ...[
                  _SectionCard(section: section),
                  const SizedBox(height: 16),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final LeaderboardSection section;

  @override
  Widget build(BuildContext context) {
    final entries = section.entries;
    final top3 = entries.take(3).toList();
    final rest = entries.length > 3 ? entries.sublist(3) : const <LeaderboardEntry>[];

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF16213E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF2A2A4A)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Row(
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEDC22E).withValues(alpha:0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    section.modeLabel,
                    style: const TextStyle(
                      color: Color(0xFFEDC22E),
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${entries.length} игроков',
                  style: const TextStyle(
                    color: Color(0xFF776E65),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Топ-3 подиум
          if (top3.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: _PodiumRow(top3: top3),
            ),

          if (top3.isNotEmpty) const SizedBox(height: 12),

          // Остальные позиции
          if (rest.isNotEmpty) ...[
            const Divider(color: Color(0xFF2A2A4A), height: 1),
            for (var i = 0; i < rest.length; i++)
              _ListEntry(
                rank: i + 4,
                entry: rest[i],
                isLast: i == rest.length - 1,
              ),
          ],

          if (entries.isEmpty)
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Пока никто не играл в этом режиме',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF776E65), fontSize: 14),
              ),
            ),

          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _PodiumRow extends StatelessWidget {
  const _PodiumRow({required this.top3});

  final List<LeaderboardEntry> top3;

  @override
  Widget build(BuildContext context) {
    // Порядок отображения: 2-й, 1-й, 3-й (классический подиум)
    final first = top3[0];
    final second = top3.length > 1 ? top3[1] : null;
    final third = top3.length > 2 ? top3[2] : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (second != null)
          Expanded(child: _PodiumItem(rank: 2, entry: second)),
        if (second != null) const SizedBox(width: 8),
        Expanded(child: _PodiumItem(rank: 1, entry: first, isFirst: true)),
        if (third != null) const SizedBox(width: 8),
        if (third != null)
          Expanded(child: _PodiumItem(rank: 3, entry: third)),
        if (second == null) const Expanded(child: SizedBox()),
        if (third == null) const Expanded(child: SizedBox()),
      ],
    );
  }
}

class _PodiumItem extends StatelessWidget {
  const _PodiumItem({
    required this.rank,
    required this.entry,
    this.isFirst = false,
  });

  final int rank;
  final LeaderboardEntry entry;
  final bool isFirst;

  static const _rankColors = {
    1: Color(0xFFEDC22E),
    2: Color(0xFFB0BEC5),
    3: Color(0xFFCD7F32),
  };

  static const _rankEmojis = {1: '🥇', 2: '🥈', 3: '🥉'};

  @override
  Widget build(BuildContext context) {
    final color = _rankColors[rank] ?? Colors.white;
    final emoji = _rankEmojis[rank] ?? '';
    final baseHeight = isFirst ? 130.0 : 104.0;

    return Container(
      height: baseHeight,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha:0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha:0.35), width: 1.5),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: TextStyle(fontSize: isFirst ? 28 : 22)),
          const SizedBox(height: 4),
          Text(
            entry.displayName,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: isFirst ? 15 : 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${entry.score}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w900,
              fontSize: isFirst ? 20 : 16,
            ),
          ),
        ],
      ),
    );
  }
}

class _ListEntry extends StatelessWidget {
  const _ListEntry({
    required this.rank,
    required this.entry,
    required this.isLast,
  });

  final int rank;
  final LeaderboardEntry entry;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: isLast
            ? null
            : const Border(
                bottom: BorderSide(color: Color(0xFF2A2A4A)),
              ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text(
              '$rank',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Color(0xFF776E65),
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              entry.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
          Text(
            '${entry.score}',
            style: const TextStyle(
              color: Color(0xFFEDC22E),
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }
}
