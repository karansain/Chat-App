import 'package:equatable/equatable.dart';

abstract class ClubsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchClub extends ClubsEvent {}

class FetchQuestionsForClub extends ClubsEvent {
  final int clubId;

  FetchQuestionsForClub(this.clubId);

  @override
  List<Object?> get props => [clubId];
}

class AddQuestionToClub extends ClubsEvent {
  final int clubId;
  final String content;
  final List<String> tags;
  final int userId;

  AddQuestionToClub({
    required this.clubId,
    required this.content,
    required this.tags,
    required this.userId,
  });
}

class FetchAnswerForClub extends ClubsEvent {
  final int questionId;

  FetchAnswerForClub(this.questionId);

  @override
  List<Object?> get props => [questionId];
}

class AddAnswerToClub extends ClubsEvent {
  final int questionId;
  final String content;
  final int userId;

  AddAnswerToClub({
    required this.questionId,
    required this.content,
    required this.userId,
  });
}

class FetchMembersForClub extends ClubsEvent {
  final int clubId;

  FetchMembersForClub(this.clubId);

  @override
  List<Object?> get props => [clubId];
}