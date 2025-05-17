package com.encryptic.api.Services;

import com.encryptic.api.DTOs.MessageDTO;
import com.encryptic.api.Models.Club;
import com.encryptic.api.Models.ClubMessage;
import com.encryptic.api.Models.User;
import com.encryptic.api.Repositories.ClubMessageRepository;
import com.encryptic.api.Repositories.ClubRepository;
import com.encryptic.api.Repositories.UserRepository;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.stream.Collectors;

@Service
public class ClubMessageService {

        @Autowired
        private ClubMessageRepository clubMessageRepository;

        @Autowired
        private ClubRepository clubRepository;

        @Autowired
        private UserRepository userRepository;

        public MessageDTO sendMessageToClub(Long clubId, String content, String senderUsername) {
                Club club = clubRepository.findById(clubId)
                                .orElseThrow(() -> new RuntimeException("Club not found with ID: " + clubId));

                User sender = userRepository.findByUsername(senderUsername)
                                .orElseThrow(() -> new RuntimeException(
                                                "User not found with username: " + senderUsername));

                ClubMessage message = ClubMessage.builder()
                                .club(club)
                                .sender(sender)
                                .content(content)
                                .timestamp(LocalDateTime.now())
                                .build();

                ClubMessage savedMessage = clubMessageRepository.save(message);

                // Return a DTO
                return MessageDTO.builder()
                                .id(savedMessage.getId())
                                .clubId(savedMessage.getClub().getId())
                                .content(savedMessage.getContent())
                                .senderId(savedMessage.getSender().getId())
                                .senderUsername(savedMessage.getSender().getUsername())
                                .sendersImage(savedMessage.getSender().getPhotoUrl())
                                .timestamp(savedMessage.getTimestamp())
                                .build();
        }

        public List<MessageDTO> getClubMessages(Long clubId) {
                List<ClubMessage> messages = clubMessageRepository.findByClubIdOrderByTimestampAsc(clubId);

                return messages.stream()
                                .map(message -> MessageDTO.builder()
                                                .id(message.getId())
                                                .clubId(message.getClub().getId())
                                                .content(message.getContent())
                                                .senderId(message.getSender().getId())
                                                .senderUsername(message.getSender().getUsername())
                                                .sendersImage(message.getSender().getPhotoUrl())
                                                .timestamp(message.getTimestamp())
                                                .build())
                                .collect(Collectors.toList());
        }

        
}