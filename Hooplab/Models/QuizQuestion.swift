import Foundation

public struct QuizQuestion: Identifiable, Codable, Hashable {
    public let id: Int
    public let questionRu: String
    public let questionEn: String
    public let optionsRu: [String]
    public let optionsEn: [String]
    public let correctIndex: Int
    public let explanationRu: String
    public let explanationEn: String

    public func localizedQuestion(isEn: Bool) -> String {
        isEn ? questionEn : questionRu
    }

    public func localizedOptions(isEn: Bool) -> [String] {
        isEn ? optionsEn : optionsRu
    }

    public func localizedExplanation(isEn: Bool) -> String {
        isEn ? explanationEn : explanationRu
    }
}

public struct BasketballQuizData {
    public static let allQuestions: [QuizQuestion] = [
        QuizQuestion(
            id: 1,
            questionRu: "Сколько секунд даётся команде на атаку по правилам FIBA и NBA?",
            questionEn: "How many seconds does a team have for a shot clock in FIBA/NBA?",
            optionsRu: ["20 секунд", "24 секунды", "30 секунд", "35 секунд"],
            optionsEn: ["20 seconds", "24 seconds", "30 seconds", "35 seconds"],
            correctIndex: 1,
            explanationRu: "По правилам FIBA и NBA на атаку отводится ровно 24 секунды.",
            explanationEn: "FIBA and NBA rules allocate exactly 24 seconds for the shot clock."
        ),
        QuizQuestion(
            id: 2,
            questionRu: "Что фиксирует судья, если игрок после завершения ведения мяча снова начал дриблинг?",
            questionEn: "What violation is called when a player stops dribbling and starts dribbling again?",
            optionsRu: ["Пробежка", "Двойное ведение", "Фол в нападении", "Нарушение зоны"],
            optionsEn: ["Travel", "Double dribble", "Offensive foul", "Backcourt violation"],
            correctIndex: 1,
            explanationRu: "Если игрок взял мяч двумя руками, он обязан сделать пас или бросок. Повторное ведение — двойное ведение.",
            explanationEn: "Once a player gathers the ball with both hands, they must pass or shoot."
        ),
        QuizQuestion(
            id: 3,
            questionRu: "Какая баскетбольная позиция обозначается как PG (Point Guard)?",
            questionEn: "Which basketball position is abbreviated as PG?",
            optionsRu: ["Атакующий защитник", "Лёгкий форвард", "Разыгрывающий защитник", "Центровой"],
            optionsEn: ["Shooting Guard", "Small Forward", "Point Guard", "Center"],
            correctIndex: 2,
            explanationRu: "PG (Point Guard) — разыгрывающий защитник, 'плеймейкер' и диспетчер команды.",
            explanationEn: "Point Guard (PG) is the floor general and primary ball handler of the team."
        ),
        QuizQuestion(
            id: 4,
            questionRu: "Какова официальная высота баскетбольного кольца от пола?",
            questionEn: "What is the official height of a basketball rim from the floor?",
            optionsRu: ["2.95 метра", "3.00 метра", "3.05 метра", "3.15 метра"],
            optionsEn: ["2.95 m", "3.00 m", "3.05 m (10 ft)", "3.15 m"],
            correctIndex: 2,
            explanationRu: "Официальная высота кольца по стандартам FIBA и NBA — 3.05 метра (10 футов).",
            explanationEn: "The official rim height according to FIBA and NBA standards is 3.05 meters (10 feet)."
        ),
        QuizQuestion(
            id: 5,
            questionRu: "Что такое Pick-and-Roll (пик-н-ролл) в баскетболе?",
            questionEn: "What is a Pick-and-Roll in basketball?",
            optionsRu: [
                "Бросок крюком из-под кольца",
                "Заслон игроку с мячом с последующим открыванием заслоняющего к кольцу",
                "Перехват мяча в воздухе",
                "Защита зонным прессингом"
            ],
            optionsEn: [
                "A hook shot under the basket",
                "A screen set for the ball handler followed by the screener rolling to the rim",
                "An interception in mid-air",
                "A zone full-court press"
            ],
            correctIndex: 1,
            explanationRu: "Пик-н-ролл — базовая атакующая связка: заслон («пик») и резкое открывание к кольцу («ролл»).",
            explanationEn: "The pick-and-roll involves setting a screen and rolling towards the basket."
        ),
        QuizQuestion(
            id: 6,
            questionRu: "Сколько персональных фолов допустимо получить игроку в NBA до удаления с площадки?",
            questionEn: "How many personal fouls can a player commit in the NBA before fouling out?",
            optionsRu: ["4 фола", "5 фолов", "6 фолов", "7 фолов"],
            optionsEn: ["4 fouls", "5 fouls", "6 fouls", "7 fouls"],
            correctIndex: 2,
            explanationRu: "В NBA лимит фолов — 6 (в FIBA — 5 фолов).",
            explanationEn: "In the NBA, the limit is 6 fouls (in FIBA it is 5 fouls)."
        ),
        QuizQuestion(
            id: 7,
            questionRu: "Сколько секунд игрок команды нападения может непрерывно находиться в 'краске' (трёхсекундной зоне) соперника?",
            questionEn: "How many seconds can an offensive player stay continuously in the key?",
            optionsRu: ["3 секунды", "5 секунд", "8 секунд", "Без ограничений"],
            optionsEn: ["3 seconds", "5 seconds", "8 seconds", "Unlimited"],
            correctIndex: 0,
            explanationRu: "Правило 3 секунд запрещает атакующему игроку оставаться в ограниченной зоне дольше 3 секунд без мяча.",
            explanationEn: "The 3-second rule prohibits an offensive player from remaining in the key for over 3 seconds."
        ),
        QuizQuestion(
            id: 8,
            questionRu: "Что означает термин 'Box Out' (бокс-аут) при борьбе за подбор?",
            questionEn: "What does the term 'Box Out' mean during rebounding?",
            optionsRu: [
                "Прыжок одной рукой выше соперника",
                "Блокировка соперника спиной и корпусом для занятия выгодной позиции у кольца",
                "Фол при толчке в спину",
                "Выбивание мяча в аут"
            ],
            optionsEn: [
                "Jumping with one hand higher than the opponent",
                "Positioning one's body between the opponent and the basket to secure the rebound",
                "Pushing foul from behind",
                "Tapping the ball out of bounds"
            ],
            correctIndex: 1,
            explanationRu: "Бокс-аут (отсечение) — игрок занимает позицию между соперником и кольцом, блокируя его движение спиной.",
            explanationEn: "Boxing out means establishing position between the opponent and the basket."
        ),
        QuizQuestion(
            id: 9,
            questionRu: "Сколько секунд даётся команде на вывод мяча со своей половины площадки (из тыловой зоны)?",
            questionEn: "How many seconds does a team have to advance the ball past the half-court line?",
            optionsRu: ["5 секунд", "8 секунд", "10 секунд", "12 секунд"],
            optionsEn: ["5 seconds", "8 seconds", "10 seconds", "12 seconds"],
            correctIndex: 1,
            explanationRu: "По правилам FIBA и NBA команда обязана перевести мяч через центральную линию за 8 секунд.",
            explanationEn: "Both FIBA and NBA enforce an 8-second backcourt rule."
        ),
        QuizQuestion(
            id: 10,
            questionRu: "С какого расстояния проводится бросок из-за дуги (трёхочковый) по стандартам FIBA?",
            questionEn: "What is the distance of the FIBA three-point line?",
            optionsRu: ["6.25 метра", "6.75 метра", "7.24 метра", "6.50 метра"],
            optionsEn: ["6.25 m", "6.75 m", "7.24 m", "6.50 m"],
            correctIndex: 1,
            explanationRu: "По правилам FIBA трёхочковая дуга находится на расстоянии 6.75 м (в NBA — 7.24 м в вершине).",
            explanationEn: "FIBA's three-point line is 6.75 meters (in the NBA it is 7.24 meters at the top of the arc)."
        )
    ]
}
