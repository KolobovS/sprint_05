import UIKit

final class MovieQuizViewController: UIViewController {
    // MARK: - Properties
    private let alertPresenter = AlertPresenter()
    private var currentRound: Round?
    private var statisticService: StatisticService?
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var counterLabel: UILabel!
    @IBOutlet private weak var textLabel: UILabel!
    @IBOutlet private weak var noButton: UIButton!
    @IBOutlet private weak var yesButton: UIButton!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        alertPresenter.delegate = self
        startNewRound()
    }
    
    @IBAction private func noButtonClicked(_ sender: UIButton) {
        setAnswerButtonsEnabled(false)
        let isCorrect = currentRound?.checkAnswer(checkTap: false) ?? false
        showQuestionAnswerResult(isCorrect: isCorrect)
    }
    
    @IBAction private func yesButtonClicked(_ sender: UIButton) {
        setAnswerButtonsEnabled(false)
        let isCorrect = currentRound?.checkAnswer(checkTap: true) ?? false
        showQuestionAnswerResult(isCorrect: isCorrect)
    }
}

extension MovieQuizViewController {
    private func setupImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.borderWidth = 8
        imageView.layer.cornerRadius = 20
    }
}

extension MovieQuizViewController {
    fileprivate func remove() {
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
    }
}

extension MovieQuizViewController: RoundDelegate {
    func didReceiveNewQuestion(_ question: QuizQuestion?) {
        guard let question = question else {
            return
        }
        showQuestion(quiz: convert(model: question))
        setAnswerButtonsEnabled(true)
    }
    
    func roundDidEnd(_ round: Round, withResult gameRecord: GameRecord) {
        statisticService = StatisticServiceImplementation()
        showQuizResults()
    }
}

extension MovieQuizViewController {
    private func startNewRound() {
        setAnswerButtonsEnabled(true)
        currentRound = Round()
        currentRound?.delegate = self
        currentRound?.requestNextQuestion()
    }
}

extension MovieQuizViewController {
    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        let questionNumber = currentRound?.getNumberCurrentQuestion() ?? 0
        let totalQuestions = currentRound?.getCountQuestions() ?? 0
        let displayNumber = questionNumber + 1
        
        return QuizStepViewModel(
            image: UIImage(named: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(displayNumber) / \(totalQuestions)"
        )
    }
}

extension MovieQuizViewController {
    private func convert1(model: StatisticService?) -> AlertModel {
        guard let bestGame = model?.bestGame else {
            return AlertModel(title: "Ошибка", message: "Данные не доступны!", buttonText: "ОК")
        }
        
        let gamesCount = model?.gamesCount ?? 0
        let gamesAccuracy = model?.totalAccuracy ?? 0.0
        
        let correctAnswers = currentRound?.getCorrectCountAnswer() ?? 0
        let totalQuestions = currentRound?.getCountQuestions() ?? 0
        
        let recordCorrect = bestGame.correct
        let recordTotal = bestGame.total
        let recordDate = bestGame.date
        
        let alertModel = AlertModel(
            title: "Этот раунд окончен!",
            message: """
            Ваш результат: \(correctAnswers) / \(totalQuestions)
            Количество сыгранных квизов: \(gamesCount)
            Рекорд: \(recordCorrect) / \(recordTotal) (\(recordDate.dateTimeString))
            Средняя точность: \(gamesAccuracy)%
            """,
            buttonText: "Сыграть еще раз"
        )
        
        return alertModel
    }
}

extension MovieQuizViewController {
    private func showQuestionAnswerResult(isCorrect: Bool) {
        UIView.animate(withDuration: 0.5, animations: { [weak self] in
            self?.imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor
        })
    }
}

extension MovieQuizViewController {
    
    private func showQuizResults() {
        let model1 = statisticService
        let alertModel1 = convert1(model: model1)
        alertPresenter.present(alertModel: alertModel1, on: self)
    }
    
    
}

extension MovieQuizViewController {
    private func showQuestion(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        counterLabel.text = step.questionNumber
        textLabel.text = step.question
        imageView.layer.borderColor = UIColor.clear.cgColor
    }
}

extension MovieQuizViewController: AlertPresenterDelegate {
    func alertDidDismiss() {
        startNewRound()
    }
}

extension MovieQuizViewController {
    private func setAnswerButtonsEnabled(_ enabled: Bool) {
        noButton.isEnabled = enabled
        yesButton.isEnabled = enabled
    }
}
