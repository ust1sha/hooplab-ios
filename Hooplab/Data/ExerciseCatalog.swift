import Foundation
import Combine

public class ExerciseCatalog {
    public static func loadExercises() -> [Exercise] {
        if let url = Bundle.main.url(forResource: "exercises", withExtension: "json") {
            do {
                let data = try Data(contentsOf: url)
                let decoded = try JSONDecoder().decode(ExerciseCatalogResponse.self, from: data)
                return decoded.exercises
            } catch {
                print("Error loading exercises.json: \(error)")
            }
        }
        
        // Return default seed if file not in main bundle
        return defaultFallbackExercises
    }

    public static let defaultFallbackExercises: [Exercise] = [
        Exercise(
            id: 1,
            title: LocalizedField(ru: "Бросок в прыжке", en: "Jump Shot"),
            description: LocalizedField(
                ru: "Базовая техника броска в прыжке. Учимся правильно отталкиваться и выпускать мяч в высшей точке.",
                en: "Basic jump shot technique. Learn to push off correctly and release the ball at the peak."
            ),
            level: LocalizedField(ru: "Средний", en: "Intermediate"),
            category: LocalizedField(ru: "Броски", en: "Shots"),
            imageName: "ic_shot",
            steps: LocalizedField(
                ru: "Встаньте лицом к кольцу, ноги на ширине плеч\nДержите мяч на уровне груди\nОттолкнитесь вертикально вверх\nВыпустите мяч в высшей точке лёгким щелчком кисти\nПриземлитесь на обе ноги",
                en: "Face the hoop, feet shoulder-width apart\nHold ball at chest level\nJump vertically\nRelease ball at peak with wrist flick\nLand on both feet"
            ),
            muscles: LocalizedField(ru: "Плечевой пояс, трицепс, мышцы кора, икроножные", en: "Shoulders, triceps, core, calves"),
            sets: LocalizedField(ru: "3 подхода × 10 повторений", en: "3 sets × 10 reps"),
            rest: LocalizedField(ru: "45–60 сек", en: "45–60 sec"),
            tips: LocalizedField(ru: "Следите за обратным вращением мяча с кончиков пальцев.", en: "Ensure backspin off your fingertips."),
            mistakes: LocalizedField(ru: "Выпуск мяча после прохождения пика прыжка\nЛокти разведены в стороны", en: "Releasing ball past the peak\nElbows flaring out")
        ),
        Exercise(
            id: 2,
            title: LocalizedField(ru: "Дриблинг", en: "Dribbling"),
            description: LocalizedField(
                ru: "Основы ведения мяча. Контроль мяча на месте и в движении.",
                en: "Ball handling basics. Dribbling in place and on the move."
            ),
            level: LocalizedField(ru: "Начальный", en: "Beginner"),
            category: LocalizedField(ru: "Техника", en: "Technique"),
            imageName: "ic_technique",
            steps: LocalizedField(
                ru: "Ноги на ширине плеч, колени согнуты\nВедите мяч подушечками пальцев\nОтбивайте мяч сбоку на уровне пояса\nСмотрите вперёд, сканируя площадку",
                en: "Feet shoulder-width apart, knees bent\nDribble with fingertips\nBounce at waist level\nKeep your eyes up"
            ),
            muscles: LocalizedField(ru: "Предплечья, кисти, мышцы кора", en: "Forearms, wrists, core"),
            sets: LocalizedField(ru: "4 подхода × 60 сек", en: "4 sets × 60 sec"),
            rest: LocalizedField(ru: "30 сек", en: "30 sec"),
            tips: LocalizedField(ru: "Толкайте мяч вниз кистью, не бейте ладонью.", en: "Push ball down with wrist, don't slap."),
            mistakes: LocalizedField(ru: "Удары ладонью\nВзгляд в пол на мяч", en: "Slapping with palm\nLooking down at ball")
        ),
        Exercise(
            id: 3,
            title: LocalizedField(ru: "Защитная стойка", en: "Defensive Stance"),
            description: LocalizedField(
                ru: "Правильная позиция в защите. Работа ног и баланс тела.",
                en: "Correct defensive stance. Footwork and body balance."
            ),
            level: LocalizedField(ru: "Продвинутый", en: "Advanced"),
            category: LocalizedField(ru: "Защита", en: "Defense"),
            imageName: "ic_defense",
            steps: LocalizedField(
                ru: "Ноги шире плеч, колени согнуты, вес на носках\nСпина прямая, корпус наклонён вперёд\nРуки разведены в стороны, ладони раскрыты\nДвигайтесь короткими приставными шагами",
                en: "Feet wide, knees bent, weight on balls of feet\nStraight back, torso leaned forward\nArms wide, palms open\nMove with quick slide steps"
            ),
            muscles: LocalizedField(ru: "Квадрицепсы, ягодицы, икры, кор", en: "Quads, glutes, calves, core"),
            sets: LocalizedField(ru: "3 подхода × 45 сек", en: "3 sets × 45 sec"),
            rest: LocalizedField(ru: "30 сек", en: "30 sec"),
            tips: LocalizedField(ru: "Не скрещивайте ноги при перемещении.", en: "Never cross your feet while sliding."),
            mistakes: LocalizedField(ru: "Прямые колени\nОпущенные руки", en: "Straight knees\nDropped arms")
        )
    ]
}
