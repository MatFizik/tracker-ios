import XCTest

// Временный тест для проверки перед сдачей. Будет удалён после проверки.
final class VerifySubmissionUITests: XCTestCase {
    private let shotsDir = "/private/tmp/claude-501/-Users-adilkhan-Dev-practicum-Tracker/30d983a5-bb1e-4320-91c8-6dd9eb4c7a31/scratchpad/"

    private func shot(_ name: String) {
        try? XCUIScreen.main.screenshot().pngRepresentation.write(to: URL(fileURLWithPath: shotsDir + name + ".png"))
    }

    private func nameField(_ app: XCUIApplication) -> XCUIElement {
        app.textFields.matching(NSPredicate(format: "placeholderValue == %@", "Введите название трекера")).firstMatch
    }

    private func pickDay(_ app: XCUIApplication, _ label: String) {
        app.navigationBars.buttons["Date Picker"].tap()
        let day = app.buttons[label]
        XCTAssertTrue(day.waitForExistence(timeout: 3), "В календаре есть \(label)")
        day.tap()
        sleep(1)
    }

    func testSubmissionChecks() throws {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Что будем отслеживать?"].waitForExistence(timeout: 5))

        // Клавиатура не закрывает кнопки
        app.navigationBars.buttons["add"].tap()
        XCTAssertTrue(app.staticTexts["Новая привычка"].waitForExistence(timeout: 3))
        let field = nameField(app)
        field.tap()
        field.typeText("Отмена")
        XCTAssertTrue(app.keyboards.firstMatch.exists, "Клавиатура открыта")
        XCTAssertTrue(app.buttons["Отменить"].isHittable, "«Отменить» видна над клавиатурой")
        XCTAssertTrue(app.buttons["Создать"].isHittable, "«Создать» видна над клавиатурой")
        shot("ui_keyboard_buttons")
        app.buttons["Отменить"].tap()
        XCTAssertTrue(app.staticTexts["Новая привычка"].waitForNonExistence(timeout: 3), "Отмена с открытой клавиатурой закрывает экран")
        XCTAssertTrue(app.staticTexts["Что будем отслеживать?"].exists, "Ничего не добавилось")

        // Привычка на каждый день
        app.navigationBars.buttons["add"].tap()
        XCTAssertTrue(app.staticTexts["Новая привычка"].waitForExistence(timeout: 3))
        let field2 = nameField(app)
        field2.tap()
        field2.typeText("Зарядка\n")
        app.staticTexts["Расписание"].tap()
        XCTAssertTrue(app.staticTexts["Понедельник"].waitForExistence(timeout: 3))
        for index in 0..<7 {
            app.switches.element(boundBy: index).coordinate(withNormalizedOffset: CGVector(dx: 0.8, dy: 0.5)).tap()
        }
        app.buttons["Готово"].tap()
        XCTAssertTrue(app.staticTexts["Каждый день"].waitForExistence(timeout: 3))
        app.buttons["Создать"].tap()

        let cell = app.collectionViews.firstMatch.cells.containing(.staticText, identifier: "Зарядка").firstMatch
        XCTAssertTrue(cell.waitForExistence(timeout: 3))

        // Set: отметка и снятие сегодня (сб)
        cell.buttons.firstMatch.tap()
        XCTAssertTrue(cell.staticTexts["1 день"].waitForExistence(timeout: 2), "Отметка сегодня")
        cell.buttons.firstMatch.tap()
        XCTAssertTrue(cell.staticTexts["0 дней"].waitForExistence(timeout: 2), "Снятие отметки сегодня")
        cell.buttons.firstMatch.tap()
        XCTAssertTrue(cell.staticTexts["1 день"].waitForExistence(timeout: 2))

        // Вчера: отдельная запись, счётчик за всю историю = 2
        pickDay(app, "Friday, 6 November")
        XCTAssertTrue(cell.staticTexts["1 день"].waitForExistence(timeout: 2), "Вчера ещё не отмечено, всего 1")
        cell.buttons.firstMatch.tap()
        XCTAssertTrue(cell.staticTexts["2 дня"].waitForExistence(timeout: 2), "Вчера отмечено, всего 2")

        // Завтра: нельзя отметить
        pickDay(app, "Sunday, 8 November")
        cell.buttons.firstMatch.tap()
        sleep(1)
        XCTAssertTrue(cell.staticTexts["2 дня"].exists, "На будущую дату отметка не ставится")

        // Снова сегодня: отметка сохранилась, снятие уменьшает счётчик
        pickDay(app, "Saturday, 7 November")
        XCTAssertTrue(cell.staticTexts["2 дня"].exists)
        cell.buttons.firstMatch.tap()
        XCTAssertTrue(cell.staticTexts["1 день"].waitForExistence(timeout: 2), "Снятие сегодняшней отметки")
        shot("ui_submission_main")
    }
}
