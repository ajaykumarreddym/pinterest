import 'package:freezed_annotation/freezed_annotation.dart';

part 'user_profile.freezed.dart';
part 'user_profile.g.dart';

/// Local user profile captured during signup.
///
/// Stores preferences used to personalise the home feed and other
/// experiences.  Persisted to [AppStorage] as JSON.
@freezed
class UserProfile with _$UserProfile {
  const factory UserProfile({
    String? name,
    String? email,
    String? dateOfBirth,
    String? gender,
    @Default([]) List<String> selectedTopics,
  }) = _UserProfile;

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);
}
