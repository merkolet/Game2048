import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../domain/game/game_models.dart';

class LeaderboardTop {
  const LeaderboardTop({
    required this.modeKey,
    required this.modeLabel,
    required this.topDisplayName,
    required this.topScore,
  });

  final String modeKey;
  final String modeLabel;
  final String topDisplayName;
  final int topScore;
}

class LeaderboardEntry {
  const LeaderboardEntry({
    required this.displayName,
    required this.score,
  });

  final String displayName;
  final int score;
}

class LeaderboardSection {
  const LeaderboardSection({
    required this.modeKey,
    required this.modeLabel,
    required this.entries,
  });

  final String modeKey;
  final String modeLabel;
  final List<LeaderboardEntry> entries;
}

class CloudUserStatsService {
  CloudUserStatsService({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  Future<void> upsertCurrentUserProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userRef = _firestore.collection('users').doc(user.uid);
    final now = FieldValue.serverTimestamp();

    await userRef.set({
      'uid': user.uid,
      'displayName': user.displayName ?? '',
      'email': user.email ?? '',
      'updatedAt': now,
      'createdAt': now,
      'bestScores': <String, dynamic>{},
    }, SetOptions(merge: true));
  }

  Future<void> syncBestScore({
    required BoardSize size,
    required int score,
  }) async {
    if (score <= 0) return;
    final user = _auth.currentUser;
    if (user == null) return;

    final modeKey = _modeKey(size);
    final userRef = _firestore.collection('users').doc(user.uid);
    final modeRef = _firestore.collection('leaderboards').doc(modeKey);
    final entryRef = modeRef.collection('entries').doc(user.uid);
    final now = FieldValue.serverTimestamp();

    await _firestore.runTransaction((tx) async {
      final userSnap = await tx.get(userRef);
      final entrySnap = await tx.get(entryRef);
      final modeSnap = await tx.get(modeRef);

      final currentEntryBest =
          (entrySnap.data()?['score'] as num?)?.toInt() ?? 0;
      final bestForUser = score > currentEntryBest ? score : currentEntryBest;

      final userData = userSnap.data() ?? <String, dynamic>{};
      final oldBestScoresRaw = userData['bestScores'];
      final oldBestScores = oldBestScoresRaw is Map<String, dynamic>
          ? oldBestScoresRaw
          : <String, dynamic>{};
      final cloudUserBest = (oldBestScores[modeKey] as num?)?.toInt() ?? 0;
      final nextUserBest = bestForUser > cloudUserBest ? bestForUser : cloudUserBest;

      tx.set(userRef, {
        'uid': user.uid,
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'updatedAt': now,
        'bestScores': {
          ...oldBestScores,
          modeKey: nextUserBest,
        },
      }, SetOptions(merge: true));

      tx.set(entryRef, {
        'uid': user.uid,
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'score': bestForUser,
        'mode': modeKey,
        'updatedAt': now,
      }, SetOptions(merge: true));

      final topScore = (modeSnap.data()?['topScore'] as num?)?.toInt() ?? 0;
      if (!modeSnap.exists || bestForUser > topScore) {
        tx.set(modeRef, {
          'mode': modeKey,
          'modeLabel': size.label,
          'topScore': bestForUser,
          'topUid': user.uid,
          'topDisplayName': user.displayName ?? '',
          'updatedAt': now,
        }, SetOptions(merge: true));
      }
    });
  }

  Future<List<LeaderboardTop>> fetchLeaderboardTops() async {
    final modes = <String>['3x3', '4x4', '5x5'];
    final fallbackLabels = <String, String>{
      '3x3': '3 × 3',
      '4x4': '4 × 4',
      '5x5': '5 × 5',
    };

    final docs = await Future.wait(
      modes.map((mode) => _firestore.collection('leaderboards').doc(mode).get()),
    );

    return docs.map((doc) {
      final data = doc.data() ?? <String, dynamic>{};
      final modeKey = doc.id;
      return LeaderboardTop(
        modeKey: modeKey,
        modeLabel: (data['modeLabel'] as String?) ??
            fallbackLabels[modeKey] ??
            modeKey,
        topDisplayName: (data['topDisplayName'] as String?)?.trim().isNotEmpty ==
                true
            ? data['topDisplayName'] as String
            : '—',
        topScore: (data['topScore'] as num?)?.toInt() ?? 0,
      );
    }).toList();
  }

  Future<List<LeaderboardSection>> fetchLeaderboardSections({
    int limit = 10,
  }) async {
    final modes = <String>['3x3', '4x4', '5x5'];
    final modeLabels = <String, String>{
      '3x3': '3 × 3',
      '4x4': '4 × 4',
      '5x5': '5 × 5',
    };

    final results = await Future.wait(modes.map((mode) async {
      final snap = await _firestore
          .collection('leaderboards')
          .doc(mode)
          .collection('entries')
          .orderBy('score', descending: true)
          .limit(limit)
          .get();

      final entries = snap.docs.map((doc) {
        final data = doc.data();
        final name = (data['displayName'] as String?)?.trim();
        return LeaderboardEntry(
          displayName: (name != null && name.isNotEmpty) ? name : '—',
          score: (data['score'] as num?)?.toInt() ?? 0,
        );
      }).toList();

      return LeaderboardSection(
        modeKey: mode,
        modeLabel: modeLabels[mode] ?? mode,
        entries: entries,
      );
    }));

    return results;
  }

  String _modeKey(BoardSize size) {
    switch (size) {
      case BoardSize.three:
        return '3x3';
      case BoardSize.four:
        return '4x4';
      case BoardSize.five:
        return '5x5';
    }
  }
}
