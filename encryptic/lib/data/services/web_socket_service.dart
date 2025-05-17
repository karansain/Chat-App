import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  final String uri;
  WebSocketChannel? _channel;

  WebSocketService(this.uri);

  Future<dynamic> connectAndSendMessage(Map<String, dynamic> request) async {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(uri));

      print("WebSocket connected: $uri"); // Debugging line

      // Send the message
      _channel?.sink.add(jsonEncode(request));
      print("Request sent: $request"); // Debugging line

      // Wait for the response (with increased timeout)
      final response = await _channel!.stream.first.timeout(Duration(seconds: 20));

      print("Response received: $response"); // Debugging line

      // Try to decode the response as JSON first
      try {
        final decodedResponse = jsonDecode(response); // Attempt to parse as JSON
        print("Decoded response: $decodedResponse"); // Debugging line

        // If the response is a list (friends list), return it
        if (decodedResponse is List) {
          print("This is a List");
          return decodedResponse; // List of friends (no need for extra wrapping)
        } else {
          print("not List");
          // Handle JSON response (like user data or error messages)
          return decodedResponse;
        }
      } catch (e) {
        print("Response is not JSON, handling as plain text: $e");

        // Handle plain text response (like success/error messages)
        return {
          'status': 'success',
          'message': response, // Treat the response as a plain text message
        };
      }
    } catch (e) {
      // Close the socket if there is an error
      await _channel?.sink.close();
      print("WebSocket Error: $e"); // Debugging line
      throw Exception('WebSocket Error: $e');
    }
  }
}
