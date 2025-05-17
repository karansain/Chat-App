import 'package:equatable/equatable.dart';
import '../../../data/Models/Friends.dart';

abstract class FriendsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class FriendsInitial extends FriendsState {}

class FriendsLoading extends FriendsState {}

class FriendsLoaded extends FriendsState {
  final List<Friends> friendsList;

  FriendsLoaded(this.friendsList);

  @override
  List<Object?> get props => [friendsList];
}

class SearchResult extends FriendsState {
  final List<Friends> searchResults;

  SearchResult(this.searchResults);

  @override
  List<Object?> get props => [searchResults];
}

class FriendsError extends FriendsState {
  final String message;

  FriendsError(this.message);

  @override
  List<Object?> get props => [message];
}

