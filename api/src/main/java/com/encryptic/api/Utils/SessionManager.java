package com.encryptic.api.Utils;

import org.springframework.stereotype.Component;
import org.springframework.web.socket.WebSocketSession;

import java.util.concurrent.ConcurrentHashMap;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Component
public class SessionManager {

    private final ConcurrentHashMap<Long, WebSocketSession> userSessions = new ConcurrentHashMap<>();
    private static final Logger logger = LoggerFactory.getLogger(SessionManager.class);

    public void addSession(Long userId, WebSocketSession session) {
        userSessions.put(userId, session);
        logger.info("Session added for userId: {}", userId);
    }

    public WebSocketSession getSessionForUser(Long userId) {
        WebSocketSession session = userSessions.get(userId);
        if (session != null && session.isOpen()) {
            logger.info("Session found and open for userId: {}", userId);
            return session;
        } else {
            logger.warn("No open session found for userId: {}", userId);
            return null;
        }
    }

    public void removeSession(Long userId) {
        userSessions.remove(userId);
        logger.info("Session removed for userId: {}", userId);
    }
}
