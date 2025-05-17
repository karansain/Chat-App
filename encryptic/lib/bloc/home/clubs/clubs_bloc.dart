import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/repositories/home_repository.dart';
import 'clubs_event.dart';
import 'clubs_state.dart';

class ClubsBloc extends Bloc<ClubsEvent, ClubsState> {
  final HomeRepository homeRepository;

  ClubsBloc({required this.homeRepository}) : super(ClubsInitial()) {
    on<FetchClub>(_onFetchClub);
    on<FetchQuestionsForClub>(_onFetchQuestionsForClub);
    on<AddQuestionToClub>(_onAddQuestionToClub); // Added this handler
    on<AddAnswerToClub>(_onAddAnswerToClub);
    on<FetchAnswerForClub>(_onFetchAnswerForClub);
    on<FetchMembersForClub>(_onFetchMembersForClub);
    //FetchAnswerForClub
  }

  Future<void> _onFetchClub(FetchClub event, Emitter<ClubsState> emit) async {
    try {
      emit(ClubsLoading());
      final clubsList = await homeRepository.fetchClubs();
      emit(ClubsLoaded(clubsList));
    } catch (error) {
      emit(ClubsError("Error fetching clubs: ${error.toString()}"));
    }
  }

  Future<void> _onFetchQuestionsForClub(
      FetchQuestionsForClub event, Emitter<ClubsState> emit) async {
    try {
      emit(ClubsQuestionLoading());
      final clubsListQuestions =
          await homeRepository.fetchClubsQuestions(event.clubId);

      // Sort questions by creation time (latest first)
      clubsListQuestions.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(ClubsQuestionLoaded(clubsListQuestions));
    } catch (error) {
      emit(ClubsQuestionError(
          "Error fetching clubs questions: ${error.toString()}"));
    }
  }

  Future<void> _onAddQuestionToClub(
      AddQuestionToClub event, Emitter<ClubsState> emit) async {
    try {
      emit(ClubsQuestionLoading());
      await homeRepository.addQuestion(
          event.clubId, event.content, event.tags, event.userId);

      print("fetching Club Questions again");
      final updatedQuestions =
          await homeRepository.fetchClubsQuestions(event.clubId);
      updatedQuestions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      print("fetching Done");

      emit(ClubsQuestionLoaded(updatedQuestions));
    } catch (error) {
      emit(ClubsQuestionError("Error adding question: ${error.toString()}"));
    }
  }

  Future<void> _onAddAnswerToClub(
      AddAnswerToClub event, Emitter<ClubsState> emit) async {
    try {
      final result = await homeRepository.addAnswer(
          event.questionId, event.content, event.userId);
    } catch (error) {
      emit(ClubsQuestionError("Error adding question: ${error.toString()}"));
    }
  }

  Future<void> _onFetchAnswerForClub(
      FetchAnswerForClub event, Emitter<ClubsState> emit) async {
    try {
      emit(ClubsQuestionLoading());
      final clubsListAnswer =
          await homeRepository.fetchClubsAnswers(event.questionId);

      // Sort questions by creation time (latest first)
      clubsListAnswer.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      emit(ClubsAnswerLoaded(clubsListAnswer));
    } catch (error) {
      emit(ClubsQuestionError(
          "Error fetching clubs questions: ${error.toString()}"));
    }
  }

  FutureOr<void> _onFetchMembersForClub(event, Emitter<ClubsState> emit) async {
    try {
      emit(ClubsMemberLoading());
      final clubsMembers = await homeRepository.fetchClubsMembers(event.clubId);

      // Sort questions by creation time (latest first)
      clubsMembers.sort((a, b) => b.userName.compareTo(a.userName));

      emit(ClubsMemberLoaded(clubsMembers));
    } catch (error) {
      emit(ClubsMemberError(
          "Error fetching clubs questions: ${error.toString()}"));
    }
  }
}
