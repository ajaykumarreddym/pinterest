import 'package:pinterest/core/services/api/api_client.dart';
import 'package:pinterest/core/services/api/api_endpoints.dart';
import 'package:pinterest/features/home/data/models/photo_model.dart';

/// Remote datasource for fetching individual photo details.
abstract class PinDetailRemoteDatasource {
  Future<PhotoModel> getPhotoById({required int id});
}

class PinDetailRemoteDatasourceImpl implements PinDetailRemoteDatasource {
  const PinDetailRemoteDatasourceImpl({required this.apiClient});

  final ApiClient apiClient;

  @override
  Future<PhotoModel> getPhotoById({required int id}) async {
    final response = await apiClient.get<Map<String, dynamic>>(
      '${ApiEndpoints.photoById}/$id',
    );
    return PhotoModel.fromJson(response.data!);
  }
}
