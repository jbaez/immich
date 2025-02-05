import 'package:collection/collection.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:immich_mobile/modules/search/models/search_result_page_state.model.dart';

import 'package:immich_mobile/modules/search/services/search.service.dart';
import 'package:immich_mobile/shared/models/immich_asset.model.dart';
import 'package:intl/intl.dart';

class SearchResultPageNotifier extends StateNotifier<SearchResultPageState> {
  SearchResultPageNotifier()
      : super(SearchResultPageState(searchResult: [], isError: false, isLoading: true, isSuccess: false));

  final SearchService _searchService = SearchService();

  void search(String searchTerm) async {
    state = state.copyWith(searchResult: [], isError: false, isLoading: true, isSuccess: false);

    List<ImmichAsset>? assets = await _searchService.searchAsset(searchTerm);

    if (assets != null) {
      state = state.copyWith(searchResult: assets, isError: false, isLoading: false, isSuccess: true);
    } else {
      state = state.copyWith(searchResult: [], isError: true, isLoading: false, isSuccess: false);
    }
  }
}

final searchResultPageProvider = StateNotifierProvider<SearchResultPageNotifier, SearchResultPageState>((ref) {
  return SearchResultPageNotifier();
});

final searchResultGroupByDateTimeProvider = StateProvider((ref) {
  var assets = ref.watch(searchResultPageProvider).searchResult;

  assets.sortByCompare<DateTime>((e) => DateTime.parse(e.createdAt), (a, b) => b.compareTo(a));
  return assets.groupListsBy((element) => DateFormat('y-MM-dd').format(DateTime.parse(element.createdAt)));
});
