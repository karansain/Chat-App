import 'package:equatable/equatable.dart';

abstract class FriendsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchFriends extends FriendsEvent {
  final String username;

  FetchFriends(this.username);

  @override
  List<Object?> get props => [username];
}

class SearchFriend extends FriendsEvent {
  final String keyword;

  SearchFriend(this.keyword);

  @override
  List<Object?> get props => [keyword];
}
