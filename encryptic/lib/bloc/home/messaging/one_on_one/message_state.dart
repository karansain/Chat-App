import 'package:equatable/equatable.dart';

import '../../../../data/Models/Message.dart';

abstract class MessagingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MessagingInitial extends MessagingState {}

class MessagingLoading extends MessagingState {}

class MessagingSending extends MessagingState {} // Add this state

class MessagingLoaded extends MessagingState {
  final List<Message> messages;

  MessagingLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageSent extends MessagingState {
  final Message sentMessage;

  MessageSent(this.sentMessage);

  @override
  List<Object?> get props => [sentMessage];
}

class MessageReceived extends MessagingState {
  final Message receivedMessage;

  MessageReceived(this.receivedMessage);

  @override
  List<Object?> get props => [receivedMessage];
}

class MessagingError extends MessagingState {
  final String errorMessage;

  MessagingError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class MessageSending extends MessagingState {}
