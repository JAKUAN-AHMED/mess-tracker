import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/member.dart';
import 'db_provider.dart';

final memberListProvider = FutureProvider<List<Member>>((ref) async {
  final db = ref.watch(dbHelperProvider);
  return db.getMembers(activeOnly: false);
});

final activeMemberListProvider = FutureProvider<List<Member>>((ref) async {
  final db = ref.watch(dbHelperProvider);
  return db.getMembers(activeOnly: true);
});

class MemberNotifier extends Notifier<AsyncValue<List<Member>>> {
  @override
  AsyncValue<List<Member>> build() {
    _load();
    return const AsyncValue.loading();
  }

  Future<void> _load() async {
    state = const AsyncValue.loading();
    try {
      final db = ref.read(dbHelperProvider);
      final members = await db.getMembers(activeOnly: false);
      state = AsyncValue.data(members);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> addMember(Member member) async {
    final db = ref.read(dbHelperProvider);
    await db.insertMember(member);
    await _load();
  }

  Future<void> updateMember(Member member) async {
    final db = ref.read(dbHelperProvider);
    await db.updateMember(member);
    await _load();
  }

  Future<void> deactivateMember(int id) async {
    final db = ref.read(dbHelperProvider);
    await db.deleteMember(id);
    await _load();
  }

  Future<void> refresh() => _load();
}

final memberNotifierProvider =
    NotifierProvider<MemberNotifier, AsyncValue<List<Member>>>(
        MemberNotifier.new);
