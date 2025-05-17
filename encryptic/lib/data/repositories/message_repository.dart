import 'dart:convert';
import '../Models/ClubMessages.dart';
import '../Models/Message.dart';
import '../services/web_socket_service.dart';

class MessagingRepository {
  final WebSocketService webSocketService;

  MessagingRepository(this.webSocketService);

  // Helper method to parse the response
  dynamic _parseResponse(dynamic response) {
    try {
      return response is String ? jsonDecode(response) : response;
    } catch (e) {
      throw Exception("Error decoding response: $e");
    }
  }

  // Fetch messages between a sender and a receiver
  Future<List<Message>> fetchMessages(String sender, String receiver) async {
    try {
      final response = await webSocketService.connectAndSendMessage({
        "type": "getMessages",
        "data": {
          "sender": sender,
          "receiver": receiver
        }
      });

      final decodedResponse = _parseResponse(response);

      if (decodedResponse is List) {
        List<Message> messages = decodedResponse.map((messageJson) {
          return Message.fromJson(messageJson as Map<String, dynamic>);
        }).toList();

        return messages;
      } else {
        throw Exception("Unexpected response format for messages.");
      }
    } catch (e) {
      throw Exception("Error fetching messages: $e");
    }
  }

  // Send a message from a sender to a receiver
  Future<void> sendMessage(String sender, String receiver, String content) async {
    try {
      final timestamp = DateTime.now().toIso8601String();

      final response = await webSocketService.connectAndSendMessage({
        "type": "sendMessage",
        "data": {
          "sender": sender,
          "receiver": receiver,
          "content": content,
          "timestamp": timestamp,
        }
      });

      // You can handle the response here if needed (e.g., confirmation of successful message sent)
      final decodedResponse = _parseResponse(response);
      // Optionally, process the response further

    } catch (e) {
      throw Exception("Error sending message: $e");
    }
  }

  // Send a message from a sender to a receiver
  Future<void> sendMessageToClub(String sender, int receiver, String content) async {
    try {
      final timestamp = DateTime.now().toIso8601String();

      final response = await webSocketService.connectAndSendMessage({
        "type": "sendMessageToClub",
        "data": {
          "clubId": receiver,
          "content": content,
          "senderName": sender
        }
      });

      // You can handle the response here if needed (e.g., confirmation of successful message sent)
      final decodedResponse = _parseResponse(response);
      // Optionally, process the response further

    } catch (e) {
      throw Exception("Error sending message: $e");
    }
  }

  // Fetch messages between a sender and a receiver
  Future<List<ClubMessage>> fetchMessagesOfClub(int clubId) async {
    try {
      final response = await webSocketService.connectAndSendMessage({
        "type": "getMessagesOfClub",
        "data": {
          "clubId": clubId
        }
      });

      final decodedResponse = _parseResponse(response);

      if (decodedResponse is List) {
        List<ClubMessage> messages = decodedResponse.map((messageJson) {
          return ClubMessage.fromJson(messageJson as Map<String, dynamic>);
        }).toList();

        return messages;
      } else {
        throw Exception("Unexpected response format for messages.");
      }
    } catch (e) {
      throw Exception("Error fetching messages: $e");
    }
  }

  // Helper method to decode and map data to a model
  List<T> _mapToModel<T>(List<dynamic> data, T Function(dynamic) fromJson) {
    return data.map((item) => fromJson(item)).toList();
  }
}
