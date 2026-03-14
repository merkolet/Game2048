import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'leaderboard_screen.dart';
import 'mode_selection_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.userChanges(),
        builder: (context, snapshot) {
          final user = snapshot.data ?? FirebaseAuth.instance.currentUser;
          final nickname = (user?.displayName ?? '').trim();
          final displayName = nickname.isNotEmpty ? nickname : 'Игрок';

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _WelcomeCard(
                    displayName: displayName,
                    onLogout: () async {
                      await FirebaseAuth.instance.signOut();
                    },
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Stack(
                          children: [
                            const Align(
                              alignment: Alignment(0, -0.35),
                              child: _Logo(),
                            ),
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: constraints.maxHeight * 0.10,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _HomeButton(
                                    label: 'Играть',
                                    icon: Icons.play_arrow_rounded,
                                    primary: true,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ModeSelectionScreen(),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  _HomeButton(
                                    label: 'Лидерборд',
                                    icon: Icons.emoji_events_outlined,
                                    primary: false,
                                    accentColor: const Color(0xFF4FC3F7),
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const LeaderboardScreen(),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 14),
                                _HomeButton(
                                    label: 'Статистика и задания',
                                    icon: Icons.bar_chart_rounded,
                                    primary: false,
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const StatsScreen(),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.displayName,
    required this.onLogout,
  });

  final String displayName;
  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF20254A),
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.24),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Добро пожаловать,',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFFBBADA0),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF2A315F),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF4A4F77), width: 1.2),
            ),
            child: Text(
              displayName.substring(0, 1).toUpperCase(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Выйти',
            onPressed: onLogout,
            icon: const Icon(Icons.logout_rounded, color: Color(0xFFEDC22E)),
          ),
        ],
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFEDC22E), Color(0xFFF65E3B)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(28),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEDC22E).withOpacity(0.4),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Center(
            child: Text(
              '2048',
              style: TextStyle(
                fontSize: 38,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: -1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          '2048 Pro Game',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFFEDC22E),
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

class _HomeButton extends StatelessWidget {
  const _HomeButton({
    required this.label,
    required this.icon,
    required this.primary,
    required this.onTap,
    this.accentColor,
  });

  final String label;
  final IconData icon;
  final bool primary;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final foreground = accentColor ?? const Color(0xFFBBADA0);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: primary
              ? const LinearGradient(
                  colors: [Color(0xFFEDC22E), Color(0xFFF59563)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                )
              : null,
          color: primary ? null : const Color(0xFF16213E),
          borderRadius: BorderRadius.circular(16),
          border: primary
              ? null
              : Border.all(
                  color: accentColor ?? const Color(0xFF776E65), width: 1.5),
          boxShadow: primary
              ? [
                  BoxShadow(
                    color: const Color(0xFFEDC22E).withOpacity(0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: primary ? Colors.white : foreground,
              size: 22,
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: primary ? Colors.white : foreground,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
