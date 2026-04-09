import 'dart:convert';

import 'package:pinterest/core/constants/storage_keys.dart';
import 'package:pinterest/core/services/storage/app_storage.dart';
import 'package:pinterest/core/utils/app_logger.dart';
import 'package:pinterest/features/create/domain/entities/board.dart';
import 'package:pinterest/features/create/domain/entities/collage.dart';
import 'package:pinterest/features/create/domain/entities/created_pin.dart';

/// Local datasource for user-created content (pins, boards, collages).
abstract class CreateLocalDatasource {
  List<CreatedPin> getCreatedPins();
  Future<void> saveCreatedPin(CreatedPin pin);
  Future<void> deleteCreatedPin(String id);

  List<Board> getBoards();
  Future<void> saveBoard(Board board);
  Future<void> updateBoard(Board board);
  Future<void> deleteBoard(String id);

  List<Collage> getCollages();
  Future<void> saveCollage(Collage collage);
  Future<void> deleteCollage(String id);
}

class CreateLocalDatasourceImpl implements CreateLocalDatasource {
  const CreateLocalDatasourceImpl({required this.storage});

  final AppStorage storage;

  // ── Created Pins ──

  @override
  List<CreatedPin> getCreatedPins() {
    final jsonList = storage.getStringList(StorageKeys.createdPins);
    if (jsonList == null || jsonList.isEmpty) return [];
    return jsonList.map((e) {
      final map = json.decode(e) as Map<String, dynamic>;
      return CreatedPin.fromJson(map);
    }).toList();
  }

  @override
  Future<void> saveCreatedPin(CreatedPin pin) async {
    final pins = getCreatedPins();
    pins.insert(0, pin);
    await _persistPins(pins);
    AppLogger.info('📌 Created pin saved: ${pin.id}');
  }

  @override
  Future<void> deleteCreatedPin(String id) async {
    final pins = getCreatedPins();
    pins.removeWhere((p) => p.id == id);
    await _persistPins(pins);
    AppLogger.info('🗑️ Created pin deleted: $id');
  }

  Future<void> _persistPins(List<CreatedPin> pins) async {
    final jsonList = pins.map((p) => json.encode(p.toJson())).toList();
    await storage.setStringList(StorageKeys.createdPins, jsonList);
  }

  // ── Boards ──

  @override
  List<Board> getBoards() {
    final jsonList = storage.getStringList(StorageKeys.boards);
    if (jsonList == null || jsonList.isEmpty) return [];
    return jsonList.map((e) {
      final map = json.decode(e) as Map<String, dynamic>;
      return Board.fromJson(map);
    }).toList();
  }

  @override
  Future<void> saveBoard(Board board) async {
    final boards = getBoards();
    boards.insert(0, board);
    await _persistBoards(boards);
    AppLogger.info('📋 Board saved: ${board.name}');
  }

  @override
  Future<void> updateBoard(Board board) async {
    final boards = getBoards();
    final index = boards.indexWhere((b) => b.id == board.id);
    if (index != -1) {
      boards[index] = board;
      await _persistBoards(boards);
      AppLogger.info('📋 Board updated: ${board.name}');
    }
  }

  @override
  Future<void> deleteBoard(String id) async {
    final boards = getBoards();
    boards.removeWhere((b) => b.id == id);
    await _persistBoards(boards);
    AppLogger.info('🗑️ Board deleted: $id');
  }

  Future<void> _persistBoards(List<Board> boards) async {
    final jsonList = boards.map((b) => json.encode(b.toJson())).toList();
    await storage.setStringList(StorageKeys.boards, jsonList);
  }

  // ── Collages ──

  @override
  List<Collage> getCollages() {
    final jsonList = storage.getStringList(StorageKeys.collages);
    if (jsonList == null || jsonList.isEmpty) return [];
    return jsonList.map((e) {
      final map = json.decode(e) as Map<String, dynamic>;
      return Collage.fromJson(map);
    }).toList();
  }

  @override
  Future<void> saveCollage(Collage collage) async {
    final collages = getCollages();
    collages.insert(0, collage);
    await _persistCollages(collages);
    AppLogger.info('🎨 Collage saved: ${collage.id}');
  }

  @override
  Future<void> deleteCollage(String id) async {
    final collages = getCollages();
    collages.removeWhere((c) => c.id == id);
    await _persistCollages(collages);
    AppLogger.info('🗑️ Collage deleted: $id');
  }

  Future<void> _persistCollages(List<Collage> collages) async {
    final jsonList = collages.map((c) => json.encode(c.toJson())).toList();
    await storage.setStringList(StorageKeys.collages, jsonList);
  }
}
