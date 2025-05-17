package com.encryptic.api.DTOs;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import java.time.LocalDateTime;

@Data
@AllArgsConstructor
@Builder
public class MessageDTO {
    private Long id;
    private Long clubId;
    private String content;
    private Long senderId;
    private String senderUsername;  // Optional, for convenience on the client side
    private String sendersImage;
    private LocalDateTime timestamp;
}