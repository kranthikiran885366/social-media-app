import '../../../../core/services/api_service.dart';

class SearchRepository {
  Future<Map<String, dynamic>> searchContent(String query, {int page = 1}) async {
    return await ApiService.searchContent(query);
  }
  
  Future<Map<String, dynamic>> searchUsers(String query, {int page = 1}) async {
    return await ApiService.searchUsers(query);
  }
  
  Future<Map<String, dynamic>> getTrending() async {
    return await ApiService.getTrending();
  }
}