package com.encryptic.api.Controller;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.encryptic.api.Models.User;
import com.encryptic.api.Services.UserService;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;

@RestController
@RequestMapping("/auth")
public class AuthController {

    @Autowired
    private UserService userService;


    private final ObjectMapper objectMapper = new ObjectMapper()
            .registerModule(new JavaTimeModule()) // Register JavaTimeModule to handle LocalDateTime
            .disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS); // Optional: Use ISO format instead of timestamps

    @PostMapping("/signup")
    public ResponseEntity<?> handleSignup(@RequestBody Map<String, Object> data) {
        try {
            // Convert the incoming payload to a User object
            User user = objectMapper.convertValue(data, User.class);

            // Register the user
            userService.register(user);

            // Return success response
            return ResponseEntity.ok("User registered successfully: " + user.getUsername());
        } catch (RuntimeException e) {
            // Log the error and return an error response
            return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                    .body("Signup error: " + e.getMessage());
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("An unexpected error occurred: " + e.getMessage());
        }
    }

    @PostMapping("/login")
    public ResponseEntity<Map<String, String>> login(@RequestBody Map<String, String> loginRequest) {
        try {
            // Extract email and password from the request
            String email = loginRequest.get("email");
            String password = loginRequest.get("password");

            // Validate input
            if (email == null || password == null) {
                throw new RuntimeException("Email and password must not be null");
            }

            // Authenticate the user
            User loggedInUser = userService.joinByEmail(email, password);

            // Prepare the success response
            Map<String, String> loginResponse = new HashMap<>();
            loginResponse.put("status", "success");
            loginResponse.put("message", "Login successful");
            loginResponse.put("key", loggedInUser.getPrivateKey());
            loginResponse.put("userId", loggedInUser.getId().toString());
            loginResponse.put("username", loggedInUser.getUsername());
            loginResponse.put("imageUrl", loggedInUser.getPhotoUrl());

            return ResponseEntity.ok(loginResponse);
        } catch (RuntimeException e) {
            // Prepare the error response
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", e.getMessage());

            return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(errorResponse);
        } catch (Exception e) {
            Map<String, String> errorResponse = new HashMap<>();
            errorResponse.put("status", "error");
            errorResponse.put("message", "An unexpected error occurred: " + e.getMessage());

            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR).body(errorResponse);
        }
    }

}
