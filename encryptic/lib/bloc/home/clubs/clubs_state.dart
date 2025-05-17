import 'package:equatable/equatable.dart';
import '../../../data/Models/Answer.dart';
import '../../../data/Models/ClubMembers.dart';
import '../../../data/Models/Question.dart';
import '../../../data/Models/Clubs.dart';

abstract class ClubsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ClubsInitial extends ClubsState {}

class ClubsLoading extends ClubsState {}

class ClubsLoaded extends ClubsState {
  final List<Club> clubsList;

  ClubsLoaded(this.clubsList);

  @override
  List<Object?> get props => [clubsList];
}

class ClubsError extends ClubsState {
  final String message;

  ClubsError(this.message);

  @override
  List<Object?> get props => [message];
}

class ClubsQuestionInitial extends ClubsState {}

class ClubsQuestionLoading extends ClubsState {}

class ClubsQuestionLoaded extends ClubsState {
  final List<Question> questionsList;

  ClubsQuestionLoaded(this.questionsList);

  @override
  List<Object?> get props => [questionsList];
}

class ClubsQuestionError extends ClubsState {
  final String message;

  ClubsQuestionError(this.message);

  @override
  List<Object?> get props => [message];
}

class ClubsAnswerInitial extends ClubsState {}

class ClubsAnswerLoading extends ClubsState {}

class ClubsAnswerLoaded extends ClubsState {
  final List<Answer> answerList;

  ClubsAnswerLoaded(this.answerList);

  @override
  List<Object?> get props => [answerList];
}

class ClubsAnswerError extends ClubsState {
  final String message;

  ClubsAnswerError(this.message);

  @override
  List<Object?> get props => [message];
}

class ClubsMemberInitial extends ClubsState {}

class ClubsMemberLoading extends ClubsState {}

class ClubsMemberLoaded extends ClubsState {
  final List<ClubMembership> MemberList;

  ClubsMemberLoaded(this.MemberList);

  @override
  List<Object?> get props => [MemberList];
}

class ClubsMemberError extends ClubsState {
  final String message;

  ClubsMemberError(this.message);

  @override
  List<Object?> get props => [message];
}