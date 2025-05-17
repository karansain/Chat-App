import 'dart:convert';

import '../Models/Answer.dart';
import '../Models/ClubMembers.dart';
import '../Models/Message.dart';
import '../Models/Question.dart';
import '../Models/Clubs.dart';
import '../Models/Friends.dart';
import '../services/web_socket_service.dart';
import '../repositories/user_repository.dart';

class HomeRepository {
  final WebSocketService webSocketService;

  HomeRepository(this.webSocketService);

  List<Friends> _friendsList = [];
  List<String> _friendsUsernames = [];
  List<Club> _clubSList = [];
  List<Question> _clubQuestionsList = [];
  List<Answer> _clubAnswerList = [];
  List<ClubMembership> _clubMembers = [];

  dynamic _parseResponse(dynamic response) {
    try {
      return response is String ? jsonDecode(response) : response;
    } catch (e) {
      throw Exception("Error decoding response: $e");
    }
  }

  List<T> _mapToModel<T>(List<dynamic> data, T Function(dynamic) fromJson) {
    return data.map((item) => fromJson(item)).toList();
  }

  Future<List<Friends>> fetchFriends(String username) async {
    try {
      final response = await webSocketService.connectAndSendMessage({
        'type': 'getFriends',
        'data': {'username': username},
      });

      final decodedResponse = _parseResponse(response);
      final friends =
          _mapToModel(decodedResponse, (friend) => Friends.fromJson(friend));
      _friendsList = friends;
      _friendsUsernames = friends.map((f) => f.username).toList();

      UserRepository().saveUserFriends(_friendsUsernames);
      return _friendsList;
    } catch (e) {
      throw Exception("Error fetching friends: $e");
    }
  }

  Future<List<Club>> fetchClubs() async {
    try {
      final response = await webSocketService
          .connectAndSendMessage({"type": "getAllClubs", "data": {}});

      final decodedResponse = _parseResponse(response);
      _clubSList = _mapToModel(decodedResponse, (club) => Club.fromJson(club));
      return _clubSList;
    } catch (e) {
      throw Exception("Error fetching clubs: $e");
    }
  }

  Future<String> JoinClub(int userId, int clubId,
      {String role = "MEMBER"}) async {
    try {
      final response = await webSocketService.connectAndSendMessage({
        "type": "addUserToClub",
        "data": {"userId": userId, "clubId": clubId, "role": role}
      });

      final decodedResponse = _parseResponse(response);
      return decodedResponse['status'] == 'success' ? "Success" : "Failure";
    } catch (e) {
      throw Exception("Error joining club: $e");
    }
  }

  Future<List<ClubMembership>> fetchClubsMembers(int clubId) async {
    try {
      final response = await webSocketService.connectAndSendMessage({
        "type": "getMembersOfClub",
        "data": {"clubId": clubId}
      });
      final decodedResponse = _parseResponse(response);
      _clubMembers =
          _mapToModel(decodedResponse, (m) => ClubMembership.fromJson(m));
      print(_clubMembers);
      return _clubMembers;
    } catch (e) {
      throw Exception("Error fetching club questions: $e");
    }
  }

  Future<bool> IsUserAdmin(int clubId, int userId) async {
    try {
      // Call the WebSocket service
      final response = await webSocketService.connectAndSendMessage({
        "type": "isUserAdmin",
        "data": {"clubId": clubId, "userId": userId}
      });

      // Check the response structure
      if (response['status'] == 'success' && response['message'] == true) {
        return true; // User is an admin
      } else {
        return false; // User is not an admin
      }
    } catch (e) {
      print("Error in IsUserAdmin: $e");
      return false; // Default to not an admin in case of an error
    }
  }

  Future<List<Question>> fetchClubsQuestions(int clubId) async {
    try {
      final response = await webSocketService.connectAndSendMessage({
        "type": "getQuestions",
        "data": {"clubId": clubId}
      });
      final decodedResponse = _parseResponse(response);
      _clubQuestionsList =
          _mapToModel(decodedResponse, (q) => Question.fromJson(q));
      return _clubQuestionsList;
    } catch (e) {
      throw Exception("Error fetching club questions: $e");
    }
  }

  Future<void> addQuestion(
      int clubId, String content, List<String> tags, int userId) async {
    try {
      final response = await webSocketService.connectAndSendMessage({
        "type": "createQuestion",
        "data": {
          "clubId": clubId,
          "content": content,
          "authorId": userId,
          "tags": tags
        }
      });
      final decodedResponse = _parseResponse(response);
    } catch (e) {
      throw Exception("Error fetching club questions: $e");
    }
  }

  Future<List<Answer>> fetchClubsAnswers(int questionId) async {
    try {
      final response = await webSocketService.connectAndSendMessage({
        "type": "getAnswers",
        "data": {"questionId": questionId}
      });
      final decodedResponse = _parseResponse(response);
      _clubAnswerList = _mapToModel(decodedResponse, (a) => Answer.fromJson(a));
      return _clubAnswerList;
    } catch (e) {
      throw Exception("Error fetching club questions: $e");
    }
  }

  Future<void> addAnswer(int questionId, String content, int userId) async {
    try {
      final response = await webSocketService.connectAndSendMessage({
        "type": "addAnswer",
        "data": {
          "questionId": questionId,
          "content": content,
          "authorId": userId
        }
      });
      final decodedResponse = _parseResponse(response);
    } catch (e) {
      throw Exception("Error fetching club questions: $e");
    }
  }




}
