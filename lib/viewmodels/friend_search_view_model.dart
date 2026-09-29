import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:roamio_frontend/viewmodels/my_friends_view_model.dart';
import 'package:roamio_frontend/models/services/trip_friend_service.dart';
import 'package:roamio_frontend/models/services/auth_service.dart';
import 'package:roamio_frontend/models/trip_friend_model.dart';

enum FriendRequestStatus { none, pending, friends }

class FriendSearchViewModel extends ChangeNotifier {
  FriendSearchViewModel({TripFriendService? tripFriendService})
      : _tripFriendService = tripFriendService ?? TripFriendService();

  final TripFriendService _tripFriendService;

  Timer? _searchDebounce;

  String _searchQuery = '';
  String? _errorMessage;
  String? _currentUserId;

  final Set<String> _friendIds = {};
  final Set<String> _pendingRequestIds = {};
  final Map<String, String> _requestErrorMessages = {};

  List<FriendItem> _searchResults = [];

  String get searchQuery => _searchQuery;
  String? get errorMessage => _errorMessage;
  List<FriendItem> get searchResults => List.unmodifiable(_searchResults);
  bool get isSearching => _searchQuery.trim().isNotEmpty;

  FriendRequestStatus getRequestStatus(String userId) {
    if (_friendIds.contains(userId)) return FriendRequestStatus.friends;
    if (_pendingRequestIds.contains(userId)) return FriendRequestStatus.pending;
    return FriendRequestStatus.none;
  }

  String? getRequestError(String userId) => _requestErrorMessages[userId];

  /// Loads the current user's existing friends/pending requests once, so
  /// getRequestStatus reflects real state rather than nothing at all.
  Future<void> _loadRelationships() async {
    try {
      _currentUserId ??= await AuthService.instance.getCurrentUserId();

      final results = await Future.wait([
        _tripFriendService.getAllFriends(),
        _tripFriendService.getAllRequests(),
      ]);

      final friends = results[0] as List<TripFriend>;
      final requests = results[1] as List<TripFriendRequest>;

      _friendIds
        ..clear()
        ..addAll(
          friends
              .where((f) => f.friendStatus == FriendStatus.friend)
              .map((f) => f.userId == _currentUserId ? f.friendUserId : f.userId),
        );

      _pendingRequestIds
        ..clear()
        ..addAll(
          requests
              .where((r) =>
                  r.senderId == _currentUserId &&
                  r.requestStatus == RequestStatus.undecided)
              .map((r) => r.receiverId),
        );
    } catch (error, stackTrace) {
      debugPrint('LOAD FRIEND RELATIONSHIPS ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);
      // Non-fatal — search still works, just without accurate status badges.
    }
  }

  void searchUsers(String query) {
    _searchDebounce?.cancel();

    _searchQuery = query;
    _errorMessage = null;

    final keyword = query.trim();

    if (keyword.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    notifyListeners();

    _searchDebounce = Timer(const Duration(milliseconds: 400), () async {
      try {
        await _loadRelationships();

        final results = await _tripFriendService.searchUsers(keyword);

        _searchResults = results
            .map(
              (r) => FriendItem(
                userId: r.userId,
                name: '${r.firstName} ${r.lastName}'.trim(),
                username: '@${r.username}',
                profileImageUrl: r.profilePicture,
                reliabilityScore: 0, // WIP: search results don't include a score
              ),
            )
            .toList();

        notifyListeners();
      } catch (error, stackTrace) {
        debugPrint('SEARCH USERS ERROR: $error');
        debugPrintStack(stackTrace: stackTrace);

        final message = error.toString().toLowerCase();
        if (message.contains('socketexception') ||
            message.contains('connection refused') ||
            message.contains('failed host lookup') ||
            message.contains('network is unreachable') ||
            message.contains('timed out')) {
          _errorMessage = 'Request failed. Please check your connection.';
        } else {
          _errorMessage = 'Unable to search users. Please try again.';
        }

        notifyListeners();
      }
    });
  }

  Future<void> sendFriendRequest(String userId) async {
    _requestErrorMessages.remove(userId);
    notifyListeners();

    if (_friendIds.contains(userId)) return;
    if (_pendingRequestIds.contains(userId)) return;

    try {
      await _tripFriendService.sendRequest(userId);

      _pendingRequestIds.add(userId);
      notifyListeners();
    } catch (error, stackTrace) {
      debugPrint('SEND FRIEND REQUEST ERROR: $error');
      debugPrintStack(stackTrace: stackTrace);

      _requestErrorMessages[userId] = 'Unable to send friend request. Please try again.';
      notifyListeners();
    }
  }

  void clearSearch() {
    _searchDebounce?.cancel();
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

  @override
  void dispose() {
    _searchDebounce?.cancel();
    super.dispose();
  }
}