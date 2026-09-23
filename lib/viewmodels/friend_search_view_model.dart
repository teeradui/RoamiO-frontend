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
      profileImageUrl: null,
      reliabilityScore: 285,
    ),
    const FriendItem(
      userId: '11',
      name: 'Benjamin',
      username: '@ben',
      profileImageUrl: null,
      reliabilityScore: 240,
    ),
    const FriendItem(
      userId: '12',
      name: 'Charlie',
      username: '@charlie',
      profileImageUrl: null,
      reliabilityScore: 310,
    ),
    const FriendItem(
      userId: '13',
      name: 'Emma',
      username: '@emma',
      profileImageUrl: null,
      reliabilityScore: 265,
    ),
    const FriendItem(
      userId: '14',
      name: 'Jane',
      username: '@jane',
      profileImageUrl: null,
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
