package com.encryptic.api.Services;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import com.encryptic.api.DTOs.AnswerDTO;
import com.encryptic.api.Models.Answers;
import com.encryptic.api.Models.Questions;
import com.encryptic.api.Models.User;
import com.encryptic.api.Repositories.AnswerRepository;
import com.encryptic.api.Repositories.QuestionRepository;

import lombok.RequiredArgsConstructor;

@Service
@RequiredArgsConstructor
public class AnswerService {

    @Autowired
    private AnswerRepository answerRepository;

    @Autowired
    private QuestionRepository questionRepository;

    public Answers createAnswer(Long questionId, String content, User author) {
        Optional<Questions> questionOpt = questionRepository.findById(questionId);
        if (questionOpt.isEmpty()) {
            throw new IllegalArgumentException("Question not found");
        }

        Answers answer = new Answers();
        answer.setContent(content);
        answer.setAuthor(author);
        answer.setQuestion(questionOpt.get());
        return answerRepository.save(answer);
    }

    public List<Answers> getAnswersByQuestion(Long questionId) {
        return answerRepository.findByQuestion_Id(questionId);
    }

    public List<AnswerDTO> getAnswersDtoByQuestion(Long questionId) {
        List<Answers> answers = answerRepository.findByQuestion_Id(questionId);

        return answers.stream()
        .map(answer -> new AnswerDTO(
            answer.getId(),
            answer.getContent(),
            answer.getCreatedAt(),
            answer.getAuthor().getId(),
            answer.getAuthor().getUsername(),
            answer.getAuthor().getPhotoUrl(),
            answer.getQuestion().getId(),
            answer.isVerified()
        ))
        .collect(Collectors.toList());
    }

    public Optional<Answers> verifyAnswer(Long answerId) {
        return answerRepository.findById(answerId).map(answer -> {
            answer.setVerified(true);
            return answerRepository.save(answer);
        });
    }

    public void deleteAnswer(Long answerId) {
        answerRepository.deleteById(answerId);
    }
}
