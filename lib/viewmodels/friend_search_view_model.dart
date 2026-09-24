import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/viewmodels/my_friends_view_model.dart';

enum FriendRequestStatus { none, pending, friends }

class FriendSearchViewModel extends ChangeNotifier {
  String _searchQuery = '';

  String? _errorMessage;

  final Set<String> _friendIds = {'10'};

  final Set<String> _pendingRequestIds = {'12'};

  final Map<String, String> _requestErrorMessages = {};

  FriendRequestStatus getRequestStatus(String userId) {
    if (_friendIds.contains(userId)) {
      return FriendRequestStatus.friends;
    }

    if (_pendingRequestIds.contains(userId)) {
      return FriendRequestStatus.pending;
    }

    return FriendRequestStatus.none;
  }

  String? getRequestError(String userId) {
    return _requestErrorMessages[userId];
  }

  final List<FriendItem> _allUsers = [
    const FriendItem(
      userId: '10',
      name: 'Alice',
      username: '@alice',
      profileImageUrl: 'https://i.pinimg.com/736x/b9/7a/7c/b97a7cdd20f7b616d6b7cb6ae6f2c719.jpg',
      reliabilityScore: 285,
    ),
    const FriendItem(
      userId: '11',
      name: 'Benjamin',
      username: '@ben',
      profileImageUrl: 'https://i.pinimg.com/736x/1c/37/bb/1c37bbd76d9262de9f2518ddd8070945.jpg',
      reliabilityScore: 240,
    ),
    const FriendItem(
      userId: '12',
      name: 'Charlie',
      username: '@charlie',
      profileImageUrl: 'https://i.pinimg.com/1200x/0b/fd/75/0bfd757069e6db2513a6dafbdbfdd7a7.jpg',
      reliabilityScore: 310,
    ),
    const FriendItem(
      userId: '13',
      name: 'Jesica',
      username: '@jesica',
      profileImageUrl: 'https://i.pinimg.com/736x/8c/e3/86/8ce386284f9dcdba366b31fad41215fd.jpg',
      reliabilityScore: 265,
    ),
    const FriendItem(
      userId: '14',
      name: 'Emily',
      username: '@emily',
      profileImageUrl: 'https://i.pinimg.com/1200x/5b/96/b6/5b96b6fdf8238d90da7d376b03aaf776.jpg',
      reliabilityScore: 220,
    ),
  ];

  List<FriendItem> _searchResults = [];

  String get searchQuery => _searchQuery;

  String? get errorMessage => _errorMessage;

  List<FriendItem> get searchResults => List.unmodifiable(_searchResults);

  bool get isSearching => _searchQuery.trim().isNotEmpty;

  void searchUsers(String query) {
    _searchQuery = query;
    _errorMessage = null;

    final keyword = query.trim().toLowerCase();

    if (keyword.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    try {
      _searchResults = _allUsers.where((user) {
        final name = user.name.toLowerCase();
        final username = user.username.toLowerCase();

        return name.contains(keyword) || username.contains(keyword);
      }).toList();

      notifyListeners();
    } catch (e) {
      _errorMessage = 'Unable to search users. Please try again.';
      notifyListeners();
    }
  }

  Future<void> sendFriendRequest(String userId) async {
  _requestErrorMessages.remove(userId);
  notifyListeners();

  // SRS-208
  if (_friendIds.contains(userId)) {
    return;
  }

  // SRS-209
  if (_pendingRequestIds.contains(userId)) {
    return;
  }

  try {
    // Mock backend request
    await Future.delayed(const Duration(milliseconds: 300));

    // SRS-207
    _pendingRequestIds.add(userId);

    notifyListeners();
  } catch (e) {
    // SRS-211
    _requestErrorMessages[userId] =
        'Unable to send friend request. Please try again.';
    notifyListeners();
  }
}

  void clearSearch() {
    _searchQuery = '';
    _searchResults = [];
    _errorMessage = null;
    notifyListeners();
  }

  void setSystemError() {
    _errorMessage = 'Unable to search users. Please try again.';
    notifyListeners();
  }

  void setNetworkError() {
    _errorMessage = 'Request failed. Please check your connection.';
    notifyListeners();
  }

  
}
