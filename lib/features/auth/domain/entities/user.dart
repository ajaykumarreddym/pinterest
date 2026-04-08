import 'package:freezed_annotation/freezed_annotation.dart';

part 'user.freezed.dart';

/// Domain entity for an authenticated user.
@freezed
class User with _$User {
  const factory User({
    required String id,
    required String email,
    String? displayName,
    String? avatarUrl,
  }) = _User;
}
