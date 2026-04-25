

import '../../../core/Models/subscriberModel.dart';
import '../../../core/supabase/SubscriberService.dart';

class SubscriberRepository {
  final SubscriberService _service;

  SubscriberRepository(this._service);

  Future<List<SubscriberModel>> getSubscribers({
    required String institutionId,
    String? searchQuery,
    int page = 1,
    int pageSize = 10,
  }) async {
    return _service.getSubscribers(
      institutionId: institutionId,
      searchQuery: searchQuery,
      page: page,
      pageSize: pageSize,
    );
  }

  Future<int> getSubscriberCount({required String institutionId}) async {
    return _service.getSubscriberCount(institutionId: institutionId);
  }

  Future<String?> getCurrentInstitutionId() async {
    return _service.getCurrentInstitutionId();
  }
}