import 'package:equatable/equatable.dart';
import '../../../../data/Models/Message.dart';

abstract class MessagingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchMessages extends MessagingEvent {
  final String sender;
  final String receiver;

  FetchMessages(this.sender, this.receiver);

  @override
  List<Object?> get props => [sender, receiver];
}

class SendMessage extends MessagingEvent {
  final String sender;
  final String receiver;
  final String content;

  SendMessage({
    required this.sender,
    required this.receiver,
    required this.content,
  });

  @override
  List<Object?> get props => [sender, receiver, content];
}

class MessageReceivedEvent extends MessagingEvent {
  final Message message;

  MessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageSentEvent extends MessagingEvent {
  final Message message;

  MessageSentEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessagingErrorEvent extends MessagingEvent {
  final String errorMessage;

  MessagingErrorEvent(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class StartMessageSending extends MessagingEvent {
  final String sender;
  final String receiver;
  final String content;

  StartMessageSending({
    required this.sender,
    required this.receiver,
    required this.content,
  });

  @override
  List<Object?> get props => [sender, receiver, content];
}
