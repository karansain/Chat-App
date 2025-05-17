import 'package:equatable/equatable.dart';
import '../../../../data/Models/ClubMessages.dart';
import '../../../../data/Models/Message.dart';

abstract class ClubMessagingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchClubMessages extends ClubMessagingEvent {
final int clubId;

FetchClubMessages(this.clubId);

  @override
  List<Object?> get props => [clubId];
}

class SendMessage extends ClubMessagingEvent {
  final String sender;
  final int receiver;
  final String content;

  SendMessage({
    required this.sender,
    required this.receiver,
    required this.content,
  });

  @override
  List<Object?> get props => [sender, receiver, content];
}

class MessageReceivedEvent extends ClubMessagingEvent {
  final ClubMessage message;

  MessageReceivedEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessageSentEvent extends ClubMessagingEvent {
  final ClubMessage message;

  MessageSentEvent(this.message);

  @override
  List<Object?> get props => [message];
}

class MessagingErrorEvent extends ClubMessagingEvent {
  final String errorMessage;

  MessagingErrorEvent(this.errorMessage);

  @override
  List<Object?> get props => [errorMessage];
}

class StartMessageSending extends ClubMessagingEvent {
  final String sender;
  final int receiver;
  final String content;

  StartMessageSending({
    required this.sender,
    required this.receiver,
    required this.content,
  });

  @override
  List<Object?> get props => [sender, receiver, content];
}
