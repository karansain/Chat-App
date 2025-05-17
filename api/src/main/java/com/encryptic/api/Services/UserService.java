package com.encryptic.api.Services;

import org.hibernate.Hibernate;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Service;

import com.encryptic.api.DTOs.FriendDTO;
import com.encryptic.api.DTOs.UserDTO;
import com.encryptic.api.Models.User;
import com.encryptic.api.Models.UserStatus;
import com.encryptic.api.Repositories.UserRepository;

import jakarta.transaction.Transactional;

import java.util.Optional;
import java.util.stream.Collectors;
import java.security.SecureRandom;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;

@Service

public class UserService {

    @Autowired
    private UserRepository userRepository;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;

    private static final Logger logger = LoggerFactory.getLogger(UserService.class);

    public List<User> getAllUsers() {
        return userRepository.findAll();
    }

    @Transactional
    public List<UserDTO> getAllUserDTOs() {
        List<User> users = userRepository.findAll();
        return users.stream()
                .map(user -> {
                    UserDTO dto = new UserDTO();
                    dto.setEmail(user.getEmail());
                    dto.setUsername(user.getUsername());
                    dto.setPhotoUrl(user.getPhotoUrl());
                    dto.setStatus(user.getStatus());
                    dto.setBlockedUserIds(user.getBlockedUsers().stream().map(User::getId).collect(Collectors.toSet()));
                    return dto;
                })
                .collect(Collectors.toList());
    }

    // Signup method
    public User register(User user) throws UnsupportedEncodingException {
        if (userRepository.findByUsername(user.getUsername()).isPresent()) {
            throw new RuntimeException("Username already exists");
        }
        if (userRepository.findByEmail(user.getEmail()).isPresent()) {
            throw new RuntimeException("Email already exists");
        }

        String secretKey = SecretKeyGenerator(); // Generate the raw key
        user.setRawPrivateKey(secretKey); // Store the raw key
        user.setPrivateKey(URLEncoder.encode(secretKey, StandardCharsets.UTF_8.toString())); // Store the encoded key

        user.setPassword(passwordEncoder.encode(user.getPassword()));
        user.setStatus(UserStatus.OFFLINE);

        return userRepository.save(user);
    }

    // Login method
    public User joinByEmail(String email, String password) {
        // Find the user by email
        Optional<User> optionalUser = userRepository.findByEmail(email);
        if (optionalUser.isEmpty()) {
            throw new RuntimeException("User not found");
        }

        User user = optionalUser.get();

        // Check if the provided password matches the stored password
        if (!passwordEncoder.matches(password, user.getPassword())) {
            throw new RuntimeException("Invalid credentials");
        }

        // Update user status to ACTIVE and save changes
        user.setStatus(UserStatus.ACTIVE);
        userRepository.save(user);

        return user;
    }


    public User findUser(String email) {
        Optional<User> foundedUser = userRepository.findByEmail(email);
        if (foundedUser.isPresent()) {
            User user = foundedUser.get();
            return user;
        } else {
            throw new RuntimeException("User not found");
        }
    }

    public User findUserById(Long id) {
        Optional<User> foundedUser = userRepository.findById(id);
        if (foundedUser.isPresent()) {
            User user = foundedUser.get();
            return user;
        } else {
            throw new RuntimeException("User not found");
        }
    }

    // Update user details
    public User updateUser(Long userId, User updatedUser) {
        return userRepository.findById(userId).map(user -> {
            user.setEmail(updatedUser.getEmail());
            user.setUsername(updatedUser.getUsername());
            user.setPassword(updatedUser.getPassword());
            user.setPhotoUrl(updatedUser.getPhotoUrl());
            return userRepository.save(user);
        }).orElseThrow(() -> new RuntimeException("User not found"));
    }

    // Delete user
    public void deleteUser(Long userId) {
        if (!userRepository.existsById(userId)) {
            throw new RuntimeException("User not found");
        }
        userRepository.deleteById(userId);
    }

    // Set user status
    public void setUserStatus(Long userId, UserStatus status) {
        userRepository.findById(userId).ifPresent(user -> {
            user.setStatus(status);
            userRepository.save(user);
        });
    }

    // Logout user (set status to offline)
    public void logout(Long userId) {
        setUserStatus(userId, UserStatus.OFFLINE);
    }

    @Transactional
    public void addFriend(String username, String friendUsername) {
        Optional<User> userOptional = userRepository.findByUsername(username);
        Optional<User> friendOptional = userRepository.findByUsername(friendUsername);

        // Check if both users exist
        if (!userOptional.isPresent() || !friendOptional.isPresent()) {
            throw new IllegalArgumentException("User or friend not found.");
        }

        User user = userOptional.get();
        User friend = friendOptional.get();

        // Initialize blockedUsers collection to avoid lazy initialization exception
        Hibernate.initialize(user.getBlockedUsers());
        Hibernate.initialize(friend.getBlockedUsers());

        // Check if the friend is blocked
        if (user.getBlockedUsers().contains(friend) || friend.getBlockedUsers().contains(user)) {
            throw new IllegalArgumentException("Cannot add a blocked user as a friend.");
        }

        // Check if they are already friends
        if (user.getFriends().contains(friend)) {
            throw new IllegalArgumentException("Users are already friends.");
        }

        // Proceed to add friend
        user.getFriends().add(friend);
        friend.getFriends().add(user);

        userRepository.save(user); // Persist the updated user
        userRepository.save(friend); // Persist the updated friend
    }

    @Transactional
    public int getFriendsCount(String username) {
        // Retrieve the user by their username
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        // Return the count of friends
        return user.getFriends().size();
    }

    public List<FriendDTO> getUserFriendsAsDTO(String username) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found with username: " + username));

        // Convert each User to FriendDTO
        return user.getFriends().stream()
                .map(friend -> new FriendDTO(
                        friend.getId(),
                        friend.getEmail(),
                        friend.getUsername(),
                        friend.getPhotoUrl(),
                        friend.getStatus()))
                .collect(Collectors.toList());
    }

    public void removeFriend(String username, String friendUsername) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        User friend = userRepository.findByUsername(friendUsername)
                .orElseThrow(() -> new RuntimeException("Friend not found"));

        if (user.getFriends().contains(friend)) {
            user.getFriends().remove(friend);
            friend.getFriends().remove(user); // Remove the user from the friend's friend list as well
            userRepository.save(user);
            userRepository.save(friend);
        } else {
            throw new RuntimeException("Friend not found in your friend list");
        }
    }

    public void blockFriend(String username, String friendUsername) {
        User user = userRepository.findByUsername(username)
                .orElseThrow(() -> new RuntimeException("User not found"));

        User friend = userRepository.findByUsername(friendUsername)
                .orElseThrow(() -> new RuntimeException("Friend not found"));

        if (!user.getBlockedUsers().contains(friend)) {
            user.getBlockedUsers().add(friend);
            userRepository.save(user);
        } else {
            throw new RuntimeException("Friend is already blocked");
        }
    }

    public void setUserStatusByUsername(String username, UserStatus status) {
        userRepository.findByUsername(username).ifPresent(user -> {
            user.setStatus(status);
            userRepository.save(user); // Save the updated status to the database
        });
    }

    public void connect(String email) {
        System.out.println("Connect called");

        Optional<User> optionalUser = userRepository.findByEmail(email);
        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            user.setStatus(UserStatus.ACTIVE); // Set user status to ACTIVE
            userRepository.save(user); // Save status update to the database
            logger.info("User connected: " + email);
        }
    }

    public void disconnect(String email) {
        System.out.println("Disconnect in user service called");

        Optional<User> optionalUser = userRepository.findByEmail(email);
        if (optionalUser.isPresent()) {
            User user = optionalUser.get();
            user.setStatus(UserStatus.OFFLINE); // Set user status to OFFLINE
            userRepository.save(user); // Save status update to the database
            logger.info("User disconnected: " + email);
        }
    }

    public String SecretKeyGenerator() {
        String CHARACTERS = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789!@#$%^&*()-_=+[]{}|;:<>,.?";

        int keyLength = 64; // Desired key length

        SecureRandom secureRandom = new SecureRandom();
        StringBuilder keyBuilder = new StringBuilder();

        for (int i = 0; i < keyLength; i++) {
            int randomIndex = secureRandom.nextInt(CHARACTERS.length());
            keyBuilder.append(CHARACTERS.charAt(randomIndex));
        }

        return keyBuilder.toString();

    }

    public Long getUserIdByKey(String key) throws UnsupportedEncodingException {
        // Decode the key and look for the raw key
        String decodedKey = URLDecoder.decode(key, StandardCharsets.UTF_8.toString());

        Optional<User> user = userRepository.findUserByRawPrivateKey(decodedKey); // Lookup by raw key
        if (user.isPresent()) {
            return user.get().getId();
        } else {
            throw new RuntimeException("User not found");
        }
    }

}
