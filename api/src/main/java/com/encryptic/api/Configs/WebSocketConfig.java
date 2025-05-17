package com.encryptic.api.Configs;

import org.springframework.beans.factory.annotation.Autowired;

// package com.api.encryptic.Configs;

import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.web.socket.config.annotation.EnableWebSocket;
import org.springframework.web.socket.config.annotation.WebSocketConfigurer;
import org.springframework.web.socket.config.annotation.WebSocketHandlerRegistry;

import com.encryptic.api.Handlers.CustomWebSocketHandler;
import com.encryptic.api.Services.AnswerService;
import com.encryptic.api.Services.ClubMessageService;
import com.encryptic.api.Services.ClubService;
import com.encryptic.api.Services.MessageService;
import com.encryptic.api.Services.QuestionService;
import com.encryptic.api.Services.UserService;
// import com.encryptic.api.Utils.JwtUtil;
import com.encryptic.api.Utils.SessionManager;

@Configuration
@EnableWebSocket
public class WebSocketConfig implements WebSocketConfigurer {

    @Autowired
    private UserService userService;

    @Autowired
    private MessageService messageService;

    @Autowired
    private BCryptPasswordEncoder passwordEncoder;


    @Autowired
    private ClubService clubService;

    @Autowired
    private QuestionService questionService;

    @Autowired
    private AnswerService answerService;

    @Autowired
    private ClubMessageService clubMessageService;

    @Autowired
    private SessionManager sessionManager;

    @SuppressWarnings("null")
    @Override
    public void registerWebSocketHandlers(WebSocketHandlerRegistry registry) {
        registry.addHandler(new CustomWebSocketHandler(userService, messageService, passwordEncoder,
                clubService, questionService, answerService, clubMessageService, sessionManager), "/ws")
                .setAllowedOrigins("*"); // Allow all origins for WebSocket connections
    }
}
