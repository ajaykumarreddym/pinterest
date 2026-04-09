import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/di/injection.dart';
import 'package:pinterest/features/create/data/datasources/create_local_datasource.dart';
import 'package:pinterest/features/create/domain/entities/board.dart';
import 'package:pinterest/features/create/domain/entities/collage.dart';
import 'package:pinterest/features/create/domain/entities/created_pin.dart';

// ── Datasource ──

final createLocalDatasourceProvider = Provider<CreateLocalDatasource>((ref) {
  return CreateLocalDatasourceImpl(storage: ref.read(appStorageProvider));
});

// ── Created Pins ──

class CreatedPinsNotifier extends Notifier<List<CreatedPin>> {
  @override
  List<CreatedPin> build() {
    return ref.read(createLocalDatasourceProvider).getCreatedPins();
  }

  Future<void> addPin(CreatedPin pin) async {
    await ref.read(createLocalDatasourceProvider).saveCreatedPin(pin);
    state = ref.read(createLocalDatasourceProvider).getCreatedPins();
  }

  Future<void> removePin(String id) async {
    await ref.read(createLocalDatasourceProvider).deleteCreatedPin(id);
    state = ref.read(createLocalDatasourceProvider).getCreatedPins();
  }
}

final createdPinsProvider =
    NotifierProvider<CreatedPinsNotifier, List<CreatedPin>>(
  CreatedPinsNotifier.new,
);

// ── Boards ──

class BoardsNotifier extends Notifier<List<Board>> {
  @override
  List<Board> build() {
    return ref.read(createLocalDatasourceProvider).getBoards();
  }

  Future<void> addBoard(Board board) async {
    await ref.read(createLocalDatasourceProvider).saveBoard(board);
    state = ref.read(createLocalDatasourceProvider).getBoards();
  }

  Future<void> updateBoard(Board board) async {
    await ref.read(createLocalDatasourceProvider).updateBoard(board);
    state = ref.read(createLocalDatasourceProvider).getBoards();
  }

  Future<void> removeBoard(String id) async {
    await ref.read(createLocalDatasourceProvider).deleteBoard(id);
    state = ref.read(createLocalDatasourceProvider).getBoards();
  }

  Future<void> addPinToBoard(String boardId, String pinId) async {
    final boards = state;
    final index = boards.indexWhere((b) => b.id == boardId);
    if (index == -1) return;
    final board = boards[index];
    if (board.pinIds.contains(pinId)) return;
    final updated = board.copyWith(pinIds: [...board.pinIds, pinId]);
    await ref.read(createLocalDatasourceProvider).updateBoard(updated);
    state = ref.read(createLocalDatasourceProvider).getBoards();
  }
}

final boardsProvider = NotifierProvider<BoardsNotifier, List<Board>>(
  BoardsNotifier.new,
);

// ── Collages ──

class CollagesNotifier extends Notifier<List<Collage>> {
  @override
  List<Collage> build() {
    return ref.read(createLocalDatasourceProvider).getCollages();
  }

  Future<void> addCollage(Collage collage) async {
    await ref.read(createLocalDatasourceProvider).saveCollage(collage);
    state = ref.read(createLocalDatasourceProvider).getCollages();
  }

  Future<void> removeCollage(String id) async {
    await ref.read(createLocalDatasourceProvider).deleteCollage(id);
    state = ref.read(createLocalDatasourceProvider).getCollages();
  }
}

final collagesProvider = NotifierProvider<CollagesNotifier, List<Collage>>(
  CollagesNotifier.new,
);
