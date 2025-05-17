import 'package:equatable/equatable.dart';

import '../../../../data/Models/ClubMessages.dart';
import '../../../../data/Models/Message.dart';

abstract class ClubMessagingState extends Equatable {
  @override
  List<Object?> get props => [];
}

class MessagingInitial extends ClubMessagingState {}

class MessagingLoading extends ClubMessagingState {}

class MessagingSending extends ClubMessagingState {} // Add this state

class MessagingLoaded extends ClubMessagingState {
  final List<ClubMessage> messages;

  MessagingLoaded(this.messages);

  @override
  List<Object?> get props => [messages];
}

class MessageSent extends ClubMessagingState {
  final ClubMessage sentMessage;

  MessageSent(this.sentMessage);

  @override
  List<Object?> get props => [sentMessage];
}

class MessageReceived extends ClubMessagingState {
  final ClubMessage receivedMessage;

  MessageReceived(this.receivedMessage);

  @override
  List<Object?> get props => [receivedMessage];
}

class MessagingError extends ClubMessagingState {
  final String errorMessage;

  MessagingError(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class MessageSending extends ClubMessagingState {}
