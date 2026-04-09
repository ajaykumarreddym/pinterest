import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:pinterest/core/di/injection.dart';
import 'package:pinterest/features/home/data/datasources/saved_pins_local_datasource.dart';
import 'package:pinterest/features/home/data/repositories/saved_pins_repository_impl.dart';
import 'package:pinterest/features/home/domain/entities/photo.dart';
import 'package:pinterest/features/home/domain/repositories/saved_pins_repository.dart';
import 'package:pinterest/features/home/presentation/providers/saved_pins_notifier.dart';

// Datasource
final savedPinsLocalDatasourceProvider =
    Provider<SavedPinsLocalDatasource>((ref) {
  return SavedPinsLocalDatasourceImpl(storage: ref.read(appStorageProvider));
});

// Repository
final savedPinsRepositoryProvider = Provider<SavedPinsRepository>((ref) {
  return SavedPinsRepositoryImpl(
    localDatasource: ref.read(savedPinsLocalDatasourceProvider),
  );
});

// Notifier
final savedPinsProvider =
    AsyncNotifierProvider<SavedPinsNotifier, List<Photo>>(
  SavedPinsNotifier.new,
);

/// Quick check if a specific pin is saved (synchronous read from storage).
final isPinSavedProvider = Provider.family<bool, int>((ref, photoId) {
  final repo = ref.read(savedPinsRepositoryProvider);
  // Watch the savedPinsProvider to re-evaluate when pins change.
  ref.watch(savedPinsProvider);
  return repo.isPinSaved(photoId);
});
