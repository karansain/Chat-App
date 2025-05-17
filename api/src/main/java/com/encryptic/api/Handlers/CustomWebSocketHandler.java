package com.encryptic.api.Handlers;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.nio.charset.StandardCharsets;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.concurrent.ConcurrentHashMap;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.socket.CloseStatus;
import org.springframework.web.socket.TextMessage;
import org.springframework.web.socket.WebSocketSession;
import org.springframework.web.socket.handler.TextWebSocketHandler;

import com.encryptic.api.DTOs.AnswerDTO;
import com.encryptic.api.DTOs.ClubDTO;
import com.encryptic.api.DTOs.ClubMembershipDTO;
import com.encryptic.api.DTOs.FriendDTO;
import com.encryptic.api.DTOs.MessageDTO;
import com.encryptic.api.DTOs.QuestionDTO;
import com.encryptic.api.DTOs.UserDTO;
import com.encryptic.api.Models.Answers;
import com.encryptic.api.Models.Club;
import com.encryptic.api.Models.ClubRole;
import com.encryptic.api.Models.Message;
import com.encryptic.api.Models.Questions;
import com.encryptic.api.Models.User;
import com.encryptic.api.Models.UserStatus;
import com.encryptic.api.Services.AnswerService;
import com.encryptic.api.Services.ClubMessageService;
import com.encryptic.api.Services.ClubService;
import com.encryptic.api.Services.MessageService;
import com.encryptic.api.Services.QuestionService;
import com.encryptic.api.Services.UserService;
import com.encryptic.api.Utils.SessionManager;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

public class CustomWebSocketHandler extends TextWebSocketHandler {

    private static final Logger logger = LoggerFactory.getLogger(CustomWebSocketHandler.class);
    private final UserService userService;
    private final ClubService clubService;
    private final QuestionService questionService;
    private final AnswerService answerService;
    private final ClubMessageService clubMessageService;
    private final MessageService messageService; // Add MessageService for handling chat messages
    // private final BCryptPasswordEncoder passwordEncoder;
    private final SessionManager sessionManager;
    private final ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule()) // Register JavaTimeModule to handle LocalDateTime
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS); // Optional: Use ISO format instead of timestamps

    private final Map<WebSocketSession, String> userSessions = new HashMap<>();

    // Map to store active users and their WebSocket sessions
    private Map<String, WebSocketSession> activeUsers = new ConcurrentHashMap<>();
    // private JwtUtil jwtUtil;

    @SuppressWarnings("null")
    @Override
    public void afterConnectionEstablished(WebSocketSession session) throws Exception {
        System.out.println("connect called");

        // Extract token from query parameters
        String key = session.getUri().getQuery();

        if (key != null && key.startsWith("key=")) {
            key = key.substring("key=".length()); // Remove the 'key=' prefix

            try {
                key = URLDecoder.decode(key, StandardCharsets.UTF_8.name()); // Decode the URL-encoded key
            } catch (UnsupportedEncodingException e) {
                logger.error("Error decoding key", e);
                return;
            }
        }

        if (key != null) {
            Long userId = userService.getUserIdByKey(key);
            User loggedInUser = userService.findUserById(userId);

            String email = loggedInUser.getEmail();

            // Update user status to ACTIVE if not already connected
            if (!activeUsers.containsKey(loggedInUser.getUsername())) { // Negated condition to add only if not already
                                                                        // connected
                System.out.println("User not connected, proceeding to connect");
                userService.connect(email); // Set user status to ACTIVE
                activeUsers.put(loggedInUser.getUsername(), session); // Add user session to active users map
                notifyStatusUpdate(loggedInUser.getUsername(), UserStatus.ACTIVE.toString()); // Notify other users
            } else {
                System.out.println("User already connected");
            }

            // Store the user's email in session attributes for reference
            session.getAttributes().put("email", email);
        } else {
            // Handle case where token is invalid or missing
            logger.warn("Invalid or missing token: {}", key);
            // Optionally, close the connection if token is invalid
        }

        super.afterConnectionEstablished(session);
    }

    @SuppressWarnings("null")
    @Override
    public void afterConnectionClosed(WebSocketSession session, CloseStatus status) throws Exception {
        System.out.println("Disconnect called");
        String email = (String) session.getAttributes().get("email");
        if (email != null) {
            userService.disconnect(email); // Set user status to OFFLINE
            activeUsers.values().remove(session); // Remove session from active users
            notifyStatusUpdate(email, UserStatus.OFFLINE.toString()); // Notify others
        } else {
            logger.warn("Email was not found in session attributes.");
        }

        super.afterConnectionClosed(session, status);
    }

    private void notifyStatusUpdate(String username, String status) {
        Map<String, String> statusUpdate = new HashMap<>();
        statusUpdate.put("username", username);
        statusUpdate.put("status", status);

        String statusJson;
        try {
            statusJson = objectMapper.writeValueAsString(statusUpdate);

            for (WebSocketSession session : activeUsers.values()) { // Send status update to all active sessions
                if (session.isOpen()) {
                    session.sendMessage(new TextMessage(statusJson));
                }
            }

        } catch (IOException e) {
            logger.error("Failed to send status update", e);
        }
    }

    public CustomWebSocketHandler(UserService userService, MessageService messageService,
            BCryptPasswordEncoder passwordEncoder, ClubService clubService,
            QuestionService questionService, AnswerService answerService, ClubMessageService clubMessageService,
            SessionManager sessionManager) {
        this.userService = userService;
        this.messageService = messageService; // Initialize MessageService
        this.clubService = clubService;
        this.questionService = questionService;
        this.answerService = answerService;
        this.clubMessageService = clubMessageService;
        this.sessionManager = sessionManager;
    }

    @SuppressWarnings({ "unchecked", "null" })
    @Override
    public void handleTextMessage(WebSocketSession session, TextMessage message) throws IOException {
        String payload = message.getPayload();
        logger.info("Received message: {}", payload);

        try {
            Map<String, Object> jsonMessage = objectMapper.readValue(payload, Map.class);
            String type = (String) jsonMessage.get("type");
            Object data = jsonMessage.get("data");

            logger.info("Message type: {}", type);
            logger.info("Message data: {}", data);

            switch (type) {

                case "update":
                    handleUpdate(session, data);
                    break;
                case "delete":
                    handleDelete(session, data);
                    break;
                case "logout":
                    handleLogout(session, data);
                    break;
                case "getAllUsers":
                    handleGetAllUsers(session);
                    break;
                case "addFriend":
                    handleAddFriend(session, data);
                    break;
                case "getFriends":
                    handleGetFriends(session, data);
                    break;
                case "getFriendsCount":
                    handleGetFriendsCount(session, data);
                    break;
                case "removeFriend":
                    handleRemoveFriend(session, data);
                    break;
                case "blockFriend":
                    handleBlockFriend(session, data);
                    break;
                case "sendMessage":
                    handleSendMessage(session, data); // Handle sending a message
                    break;
                case "getMessages":
                    handleGetMessages(session, data); // Handle fetching chat messages
                    break;
                case "getAllClubs":
                    handleGetAllClubs(session); // Handle fetching clubs handleGetQuestionsDTO
                    break;
                case "addUserToClub":
                    handleAddUserToClub(session, data);
                    break;
                case "removeUserFromClub":
                    handleRemoveUserFromClub(session, data);
                    break;
                case "isUserAdmin":
                    handleIsUserAdmin(session, data);
                    break;
                case "getMembersOfClub":
                    handleGetMembersOfClub(session, data);
                    break;
                case "sendMessageToClub":
                    handleSendMessageToClub(session, data);
                    break;
                case "getMessagesOfClub":
                    handleGetMessagesOfClub(session, data);// Handle fetching chat messages
                    break;
                case "createQuestion":
                    handleCreateQuestion(session, data);
                    break;
                case "getQuestions":
                    handleGetQuestionsDTO(session, data);
                    break;
                case "addAnswer":
                    handleAddAnswer(session, data);
                    break;
                case "getAnswers":
                    handleGetAnswerDTO(session, data);
                    break;
                case "verifyAnswer":
                    handleVerifyAnswer(session, data);
                    break;
                default:
                    session.sendMessage(new TextMessage("Unknown message type: " + type));
            }
        } catch (IOException e) {
            logger.error("Error parsing message: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Error processing message: " + e.getMessage()));
        } catch (Exception e) {
            logger.error("Unhandled exception: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Internal server error: " + e.getMessage()));
        }
    }

    @SuppressWarnings("unchecked")
    private void handleSendMessage(WebSocketSession session, Object data) throws IOException {
        try {
            Map<String, String> messageData = objectMapper.convertValue(data, Map.class);
            String sender = messageData.get("sender");
            String receiver = messageData.get("receiver");
            String content = messageData.get("content");

            Message chatMessage = new Message();
            chatMessage.setSender(sender);
            chatMessage.setReceiver(receiver);
            chatMessage.setContent(content);

            messageService.saveMessage(chatMessage);
            session.sendMessage(new TextMessage("Message sent successfully to " + receiver));
        } catch (Exception e) {
            logger.error("Error sending message: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Error sending message: " + e.getMessage()));
        }
    }

    @SuppressWarnings("unchecked")
    private void handleGetMessages(WebSocketSession session, Object data) throws IOException {
        try {
            // Parsing the received JSON data
            Map<String, String> requestData = objectMapper.convertValue(data, Map.class);
            String sender = requestData.get("sender");
            String receiver = requestData.get("receiver");

            // Retrieve chat messages between the sender and receiver (both directions)
            List<Message> messages = messageService.getChatMessages(sender, receiver);

            // Convert the list of messages to JSON
            String messagesJson = objectMapper.writeValueAsString(messages);

            // Send the messages back to the client as JSON
            session.sendMessage(new TextMessage(messagesJson));
        } catch (Exception e) {
            logger.error("Error retrieving messages: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Error retrieving messages: " + e.getMessage()));
        }
    }

    private void handleGetAllUsers(WebSocketSession session) throws IOException {
        List<UserDTO> users = userService.getAllUserDTOs();
        String response = new ObjectMapper().writeValueAsString(users);
        session.sendMessage(new TextMessage(response));
    }

    private void handleGetAllClubs(WebSocketSession session) throws IOException {
        List<ClubDTO> clubs = clubService.getAllClubs();
        String response = new ObjectMapper().writeValueAsString(clubs);
        session.sendMessage(new TextMessage(response));
    }

    private void handleUpdate(WebSocketSession session, Object data) throws IOException {
        try {
            User user = parseUser(data);
            User updatedUser = userService.updateUser(user.getId(), user);
            session.sendMessage(new TextMessage("User updated successfully: " + updatedUser.getUsername()));
        } catch (RuntimeException e) {
            logger.error("Update error: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Update error: " + e.getMessage()));
        }
    }

    private void handleDelete(WebSocketSession session, Object data) throws IOException {
        try {
            User user = parseUser(data);
            userService.deleteUser(user.getId());
            session.sendMessage(new TextMessage("User deleted successfully: " + user.getUsername()));
        } catch (RuntimeException e) {
            logger.error("Delete error: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Delete error: " + e.getMessage()));
        }
    }

    @SuppressWarnings("unchecked")
    private void handleAddFriend(WebSocketSession session, Object data) throws IOException {
        try {
            Map<String, String> friendData = objectMapper.convertValue(data, Map.class);
            String username = friendData.get("username");
            String friendUsername = friendData.get("friendUsername");

            // Ensure the service layer method initializes collections
            userService.addFriend(username, friendUsername);

            session.sendMessage(new TextMessage("Friend added successfully: " + friendUsername));
        } catch (Exception e) {
            logger.error("Error adding friend: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Error adding friend: " + e.getMessage()));
        }
    }

    @SuppressWarnings("unchecked")
    private void handleGetFriends(WebSocketSession session, Object data) throws IOException {
        try {
            Map<String, String> requestData = objectMapper.convertValue(data, Map.class);
            String username = requestData.get("username");

            // Fetch friends as FriendDTO
            List<FriendDTO> friendDTOs = userService.getUserFriendsAsDTO(username);

            // Serialize FriendDTO list into JSON
            String friendsJson = objectMapper.writeValueAsString(friendDTOs);

            // Send the response back to the client
            session.sendMessage(new TextMessage(friendsJson));
        } catch (RuntimeException e) {
            logger.error("Error retrieving friends: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Error retrieving friends: " + e.getMessage()));
        }
    }

    @SuppressWarnings("unchecked")
    private void handleGetFriendsCount(WebSocketSession session, Object data) throws IOException {
        try {
            Map<String, Object> dataMap = objectMapper.convertValue(data, Map.class);
            String username = (String) dataMap.get("username");
            int friendsCount = userService.getFriendsCount(username);
            session.sendMessage(new TextMessage("Friends count for user: " + username + " is " + friendsCount));
        } catch (RuntimeException e) {
            logger.error("Error getting friends count: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Error getting friends count: " + e.getMessage()));
        }
    }

    @SuppressWarnings("unchecked")
    private void handleRemoveFriend(WebSocketSession session, Object data) throws IOException {
        try {
            Map<String, String> requestData = objectMapper.convertValue(data, Map.class);
            String username = requestData.get("username");
            String friendUsername = requestData.get("friendUsername");

            userService.removeFriend(username, friendUsername);
            session.sendMessage(new TextMessage("Friend removed successfully: " + friendUsername));
        } catch (Exception e) {
            logger.error("Error removing friend: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Error removing friend: " + e.getMessage()));
        }
    }

    @SuppressWarnings("unchecked")
    private void handleBlockFriend(WebSocketSession session, Object data) throws IOException {
        try {
            Map<String, String> requestData = objectMapper.convertValue(data, Map.class);
            String username = requestData.get("username");
            String friendUsername = requestData.get("friendUsername");

            userService.blockFriend(username, friendUsername);
            session.sendMessage(new TextMessage("Friend blocked successfully: " + friendUsername));
        } catch (Exception e) {
            logger.error("Error blocking friend: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Error blocking friend: " + e.getMessage()));
        }
    }

    // Handle adding a user to a club
    @SuppressWarnings("unchecked")
    private void handleAddUserToClub(WebSocketSession session, Object data) throws IOException {
        try {
            Map<String, Object> requestData = objectMapper.convertValue(data, Map.class);
            Long userId = ((Number) requestData.get("userId")).longValue();
            Long clubId = ((Number) requestData.get("clubId")).longValue();
            String role = (String) requestData.get("role");

            User user = clubService.findUserById(userId);
            Club club = clubService.findClubById(clubId);

            clubService.addUserToClub(user, club, ClubRole.valueOf(role.toUpperCase()));

            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "User added to club successfully");
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
        } catch (Exception e) {
            logger.error("Error adding user to club: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Error adding user to club: " + e.getMessage()));
        }
    }

    // Handle removing a user from a club
    @SuppressWarnings("unchecked")
    private void handleRemoveUserFromClub(WebSocketSession session, Object data) throws IOException {
        try {
            Map<String, Object> requestData = objectMapper.convertValue(data, Map.class);
            Long userId = ((Number) requestData.get("userId")).longValue();
            Long clubId = ((Number) requestData.get("clubId")).longValue();

            User user = clubService.findUserById(userId);
            Club club = clubService.findClubById(clubId);

            clubService.removeUserFromClub(user, club);

            Map<String, Object> response = new HashMap<>();
            response.put("status", "success");
            response.put("message", "User removed from club successfully");
            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
        } catch (Exception e) {
            logger.error("Error removing user from club: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Error removing user from club: " + e.getMessage()));
        }
    }

    // Handle checking if a user is an admin of a club
    @SuppressWarnings("unchecked")
    private void handleIsUserAdmin(WebSocketSession session, Object data) throws IOException {
        try {
            Map<String, Object> requestData = objectMapper.convertValue(data, Map.class);
            Long userId = ((Number) requestData.get("userId")).longValue();
            Long clubId = ((Number) requestData.get("clubId")).longValue();

            User user = clubService.findUserById(userId);
            Club club = clubService.findClubById(clubId);

            boolean isAdmin = clubService.isUserAdmin(user, club);

            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(isAdmin)));
        } catch (Exception e) {
            logger.error("Error checking if user is admin: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Error checking if user is admin: " + e.getMessage()));
        }
    }

    // Handle getting members of a club
    @SuppressWarnings("unchecked")
    private void handleGetMembersOfClub(WebSocketSession session, Object data) throws IOException {
        try {
            Map<String, Object> requestData = objectMapper.convertValue(data, Map.class);
            Long clubId = ((Number) requestData.get("clubId")).longValue();

            Club club = clubService.findClubById(clubId);
            List<ClubMembershipDTO> members = clubService.getMembersOfClubDTO(club);

            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(members)));
        } catch (Exception e) {
            logger.error("Error fetching members of club: {}", e.getMessage(), e);
            session.sendMessage(new TextMessage("Error fetching members of club: " + e.getMessage()));
        }
    }

    @SuppressWarnings("unchecked")
    public void handleSendMessageToClub(WebSocketSession session, Object data) throws IOException {
        try {
            Map<String, Object> requestData = objectMapper.convertValue(data, Map.class);
            Long clubId = ((Number) requestData.get("clubId")).longValue();
            String content = (String) requestData.get("content");
            String senderName = (String) requestData.get("senderName");

            if (clubMessageService == null) {
                logger.error("clubMessageService is null!");
                sendErrorMessage(session, "Internal server error: Message service is not available.");
                return;
            }

            MessageDTO messageDTO;
            try {
                messageDTO = clubMessageService.sendMessageToClub(clubId, content, senderName);
            } catch (Exception e) {
                logger.error("Error in sendMessageToClub: {}", e.getMessage(), e);
                sendErrorMessage(session, "Error processing message: " + e.getMessage());
                return;
            }

            // Broadcast the message to all members of the club
            broadcastToClubMembers(clubId, messageDTO);
            session.sendMessage(new TextMessage("Message sent successfully to Club:" + "Club Id -" + clubId));

        } catch (RuntimeException e) {
            logger.error("Error sending message: {}", e.getMessage(), e);
            sendErrorMessage(session, "Error sending message: " + e.getMessage());
        }
    }

    private void broadcastToClubMembers(Long clubId, MessageDTO messageDTO) {
        Club club;
        try {
            club = clubService.findClubById(clubId);
        } catch (Exception e) {
            logger.error("Error fetching club with ID {}: {}", clubId, e.getMessage(), e);
            return;
        }

        if (club == null) {
            logger.error("Club with ID {} not found", clubId);
            return;
        }

        List<ClubMembershipDTO> clubMembers;
        try {
            clubMembers = clubService.getMembersOfClubDTO(club);
        } catch (Exception e) {
            logger.error("Error fetching members for club ID {}: {}", clubId, e.getMessage(), e);
            return;
        }

        if (clubMembers.isEmpty()) {
            logger.warn("No members found for club ID {}", clubId);
            return;
        }

        String messageJson;
        try {
            messageJson = objectMapper.writeValueAsString(messageDTO);
        } catch (JsonProcessingException e) {
            logger.error("Error converting MessageDTO to JSON", e);
            return;
        }

        for (ClubMembershipDTO member : clubMembers) {
            WebSocketSession memberSession = sessionManager.getSessionForUser(member.getId());
            if (memberSession == null) {
                logger.warn("No session found for user ID {}", member.getId());
                continue;
            }

            if (!memberSession.isOpen()) {
                logger.warn("Session for user ID {} is not open", member.getId());
                continue;
            }

            try {
                // Send the original message to the member
                memberSession.sendMessage(new TextMessage(messageJson));
                logger.info("Message successfully sent to user ID {}", member.getId());

                // Send the success response as a separate message after the original message
                String successResponse = "{\"status\":\"success\",\"message\":\"Message sent to " + member.getUserName()
                        + "\"}";
                memberSession.sendMessage(new TextMessage(successResponse));
                logger.info("Success message sent to user ID {}", member.getId());

            } catch (IOException e) {
                logger.error("Error broadcasting message to user {}: {}", member.getUserName(), e.getMessage(), e);
            }
        }
    }

    private void sendErrorMessage(WebSocketSession session, String errorMessage) throws IOException {
        String errorJson = objectMapper.writeValueAsString(Map.of(
                "type", "error",
                "data", Map.of("message", errorMessage)));
        session.sendMessage(new TextMessage(errorJson));
    }

    @SuppressWarnings("unchecked")
    private void handleGetMessagesOfClub(WebSocketSession session, Object data) throws IOException {
        try {
            Map<String, Object> requestData = objectMapper.convertValue(data, Map.class);
            Long clubId = ((Number) requestData.get("clubId")).longValue();
            List<MessageDTO> messages = clubMessageService.getClubMessages(clubId);

            session.sendMessage(new TextMessage(objectMapper.writeValueAsString(messages)));
        } catch (RuntimeException e) {
            logger.error("Error retrieving messages: {}", e.getMessage(), e);
            session.sendMessage(
                    new TextMessage("{\"type\": \"error\", \"data\": {\"message\": \"Error retrieving messages: "
                            + e.getMessage() + "\"}}"));
        }
    }

    @SuppressWarnings("unchecked")
    private void handleCreateQuestion(WebSocketSession session, Object data) throws IOException {
        Map<String, Object> request = (Map<String, Object>) data;
        Long clubId = Long.valueOf((Integer) request.get("clubId"));
        String content = (String) request.get("content");
        List<String> tags = (List<String>) request.get("tags");
        Long authorId = Long.valueOf((Integer) request.get("authorId"));

        User author = clubService.findUserById(authorId);
        Club club = clubService.findClubById(clubId);

        Questions question = questionService.createQuestion(clubId, content, author, club, tags);

        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");
        response.put("question", question);

        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
    }

    @SuppressWarnings("unchecked")
    private void handleGetQuestionsDTO(WebSocketSession session, Object data) throws IOException {
        // Extracting the request data
        Map<String, Object> request = (Map<String, Object>) data;
        Long clubId = Long.valueOf((Integer) request.get("clubId"));

        // Fetching QuestionDTO list by club ID from the service
        List<QuestionDTO> questionDTOs = questionService.getQuestionsByClubDTO(clubId);

        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(questionDTOs)));
    }

    @SuppressWarnings("unchecked")
    private void handleAddAnswer(WebSocketSession session, Object data) throws IOException {
        Map<String, Object> request = (Map<String, Object>) data;
        Long questionId = Long.valueOf((Integer) request.get("questionId"));
        String content = (String) request.get("content");
        Long authorId = Long.valueOf((Integer) request.get("authorId"));

        User author = clubService.findUserById(authorId);
        Answers answer = answerService.createAnswer(questionId, content, author);
        answer.getAuthor().toString();
        Map<String, Object> response = new HashMap<>();
        response.put("status", "success");

        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
    }

    @SuppressWarnings("unchecked")
    private void handleGetAnswerDTO(WebSocketSession session, Object data) throws IOException {
        // Extracting the request data
        Map<String, Object> request = (Map<String, Object>) data;
        Long questionId = Long.valueOf((Integer) request.get("questionId"));

        // Fetching QuestionDTO list by club ID from the service
        List<AnswerDTO> answerDTO = answerService.getAnswersDtoByQuestion(questionId);

        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(answerDTO)));
    }

    @SuppressWarnings("unchecked")
    private void handleVerifyAnswer(WebSocketSession session, Object data) throws IOException {
        Map<String, Object> request = (Map<String, Object>) data;
        Long answerId = Long.valueOf((Integer) request.get("answerId"));

        Optional<Answers> verifiedAnswer = answerService.verifyAnswer(answerId);

        Map<String, Object> response = new HashMap<>();
        if (verifiedAnswer.isPresent()) {
            response.put("status", "success");
            response.put("verifiedAnswer", verifiedAnswer.get());
        } else {
            response.put("status", "error");
            response.put("message", "Answer not found");
        }

        session.sendMessage(new TextMessage(objectMapper.writeValueAsString(response)));
    }

    private void handleLogout(WebSocketSession session, Object data) throws IOException {
        String username = objectMapper.convertValue(data, Map.class).get("username").toString();
        userSessions.remove(session);
        session.sendMessage(new TextMessage("Logged out successfully: " + username));
    }

    private User parseUser(Object data) {
        return objectMapper.convertValue(data, User.class);
    }

}
