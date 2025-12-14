import '../../../../core/services/api_service.dart';

class FeedRepository {
  Future<Map<String, dynamic>> getPersonalizedFeed({int page = 1}) async {
    return await ApiService.getPersonalizedFeed(page: page);
  }
  
  Future<Map<String, dynamic>> getPosts({int page = 1, int limit = 20}) async {
    return await ApiService.getPosts(page: page, limit: limit);
  }
  
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
    return await ApiService.createPost(postData);
  }
}