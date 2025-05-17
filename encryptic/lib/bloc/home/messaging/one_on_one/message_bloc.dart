import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../data/repositories/message_repository.dart';
import 'message_event.dart';
import 'message_state.dart';

class MessagingBloc extends Bloc<MessagingEvent, MessagingState> {
  final MessagingRepository messagingRepository;

  MessagingBloc({required this.messagingRepository}) : super(MessagingInitial()) {
    on<FetchMessages>(_onFetchMessages);
    on<SendMessage>(_onSendMessage);
    on<MessageReceivedEvent>(_onMessageReceived);
    on<MessageSentEvent>(_onMessageSent);
    on<MessagingErrorEvent>(_onMessagingError);
    on<StartMessageSending>(_onStartMessageSending);
  }

  // Fetch messages for a specific sender and receiver
  Future<void> _onFetchMessages(FetchMessages event, Emitter<MessagingState> emit) async {
    emit(MessagingLoading());
    try {
      final messages = await messagingRepository.fetchMessages(event.sender, event.receiver);
      emit(MessagingLoaded(messages));
    } catch (error) {
      emit(MessagingError("Error fetching messages: ${error.toString()}"));
    }
  }

  // Handle sending a message
  Future<void> _onSendMessage(SendMessage event, Emitter<MessagingState> emit) async {
    emit(MessagingSending()); // Indicating message is being sent
    try {
      await messagingRepository.sendMessage(
        event.sender,
        event.receiver,
        event.content,
      );
      // Once message is sent, update the state with the new list of messages or a success message
      final messages = await messagingRepository.fetchMessages(event.sender, event.receiver); // Optionally, fetch the updated message list
      emit(MessagingLoaded(messages)); // Update state with the new messages
    } catch (error) {
      emit(MessagingError("Error sending message: ${error.toString()}"));
    }
  }

  // Handle when a new message is received
  void _onMessageReceived(MessageReceivedEvent event, Emitter<MessagingState> emit) {
    final currentState = state;
    if (currentState is MessagingLoaded) {
      emit(MessagingLoaded([...currentState.messages, event.message]));
    } else {
      emit(MessagingError("Error receiving message."));
    }
  }

  // Handle when a message is successfully sent
  void _onMessageSent(MessageSentEvent event, Emitter<MessagingState> emit) {
    final currentState = state;
    if (currentState is MessagingLoaded) {
      emit(MessagingLoaded([...currentState.messages, event.message]));
    } else {
      emit(MessagingError("Error updating message state."));
    }
  }

  // Handle messaging error
  void _onMessagingError(MessagingErrorEvent event, Emitter<MessagingState> emit) {
    emit(MessagingError(event.errorMessage));
  }

  // Handle the start of message sending
  void _onStartMessageSending(StartMessageSending event, Emitter<MessagingState> emit) {
    emit(MessagingSending());
  }
}
