import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/home_repository.dart';
import 'friends_event.dart';
import 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  final HomeRepository homeRepository;

  FriendsBloc({required this.homeRepository}) : super(FriendsInitial()) {
    on<FetchFriends>(_onFetchFriends);
    on<SearchFriend>(_onSearchFriend);
  }

  Future<void> _onFetchFriends(FetchFriends event, Emitter<FriendsState> emit) async {
    emit(FriendsLoading());
    try {
      final friendsList = await homeRepository.fetchFriends(event.username);
      emit(FriendsLoaded(friendsList));
    } catch (error) {
      emit(FriendsError("Error fetching friends: ${error.toString()}"));
    }
  }

  void _onSearchFriend(SearchFriend event, Emitter<FriendsState> emit) {
    final currentState = state;
    if (currentState is FriendsLoaded) {
      if (event.keyword.isEmpty) {
        emit(FriendsLoaded(currentState.friendsList));
      } else {
        final results = currentState.friendsList.where((friend) {
          return friend.username.toLowerCase().contains(event.keyword.toLowerCase());
        }).toList();
        emit(SearchResult(results));
      }
    } else {
      emit(FriendsError("Cannot search friends before they are loaded."));
    }
  }
}
