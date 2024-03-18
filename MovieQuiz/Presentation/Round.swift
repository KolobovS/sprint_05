import UIKit

class Round: QuestionFactoryDelegate {
    weak var delegate: RoundDelegate?
    private lazy var questionFactory: QuestionFactory = {
        let factory = QuestionFactory()
        factory.delegate = self
        factory.requestNextQuestion()
        return factory
    }()
    private var currentQuestion: QuizQuestion?
    private var currentQuestionIndex: Int = 0
    private var correctAnswersCount: Int = 0
    private var questionCount = 10
    private var gameRecord: GameRecord?  // result of round
}

extension Round {
    func checkAnswer(checkTap: Bool) -> Bool {
        guard let currentQuestion = getCurrentQuestion() else {
            return false 
        }
        
        let isCorrect = currentQuestion.correctAnswer == checkTap
        if isCorrect {
            correctAnswersCount += 1
        }
        
        currentQuestionIndex += 1
        
        if isRoundComplete() {
            finishRound()
        } else {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.requestNextQuestion()
            }
        }
        
        return isCorrect
    }
}

extension Round {
    private func finishRound() {
        let newGameRecord = GameRecord(correct: correctAnswersCount, total: questionCount, date: Date())
        gameRecord = newGameRecord
        StatisticServiceImplementation().store(currentRound: self)
        delegate?.roundDidEnd(self, withResult: newGameRecord)
    }
}

extension Round {
    func getGameRecord() -> GameRecord? {
        guard let gameRecord = gameRecord else {
            return nil
        }
        return gameRecord
    }
}

extension Round {
    private func isRoundComplete() -> Bool {
        return currentQuestionIndex >= questionCount
    }
}

extension Round {
    func getCorrectCountAnswer() -> Int {
        correctAnswersCount
    }
}

extension Round {
    func getCountQuestions() -> Int {
        questionCount
    }
}

extension Round {
    func didReceiveNextQuestion(question: QuizQuestion?) {
        if let question = question {
            self.currentQuestion = question
            delegate?.didReceiveNewQuestion(question)
        } else if isRoundComplete() {
            finishRound()
        }
    }
}

extension Round {
    func requestNextQuestion() {
        questionFactory.requestNextQuestion()
    }
}

extension Round {
    func getCurrentQuestion() -> QuizQuestion? {
        if currentQuestionIndex < questionCount {
            return currentQuestion
        }
        return nil
    }
}

extension Round {
    func getNumberCurrentQuestion() -> Int {
        currentQuestionIndex
    }
}
