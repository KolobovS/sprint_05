import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        try super.setUpWithError()
        
        app = XCUIApplication()
        app.launch()
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        
        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        try super.tearDownWithError()
        
        app.terminate()
        app = nil
    }
    
    func testYesButton() {
        let existsPredicate = NSPredicate(format: "exists == true")
        
        let firstPoster = app.images["Poster"]
        let expectationFirst = XCTNSPredicateExpectation(predicate: existsPredicate,
                                                         object: firstPoster)
        wait(for: [expectationFirst], timeout: 5)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Yes"].tap()
        
        let secondPoster = app.images["Poster"]
        let expectationSecond = XCTNSPredicateExpectation(predicate: existsPredicate,
                                                          object: secondPoster)
        wait(for: [expectationSecond], timeout: 5)
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        
        let index = app.staticTexts["Index"]
        
        XCTAssertEqual(index.firstMatch.label, "2/10")
    }
    
    func testNoButton() {
        let existsPredicate = NSPredicate(format: "exists == true")
        
        let firstPoster = app.images["Poster"]
        let expectationFirst = XCTNSPredicateExpectation(
            predicate: existsPredicate,
            object: firstPoster)
        wait(for: [expectationFirst], timeout: 3)
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["No"].tap()
        let secondPoster = app.images["Poster"]
        let expectationSecond = XCTNSPredicateExpectation(
            predicate: existsPredicate,
            object: secondPoster)
        wait(for: [expectationSecond], timeout: 3)
        
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        let index = app.staticTexts["Index"]
        
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(index.firstMatch.label, "2/10")
    }
    
    func testEndingAlert() {
        for _ in 1...10{
            app.buttons["Yes"].tap()
            sleep(1)
        }
        let alert = app.alerts["Alert"]
        
        let alertButton = alert.buttons.firstMatch.label
        XCTAssertTrue(alert.firstMatch.exists)
        XCTAssertEqual(alert.label, "Этот раунд окончен!")
        XCTAssertEqual(alertButton, "Сыграть еще раз")
    }
    
    func testAlertButton() {
        for _ in 1...10 {
            app.buttons["Yes"].tap()
            sleep(1)
        }
        
        let alert = app.alerts["Alert"]
        
        XCTAssertTrue(alert.exists)
        alert.buttons.firstMatch.tap()
        sleep(2)
        let indexLabel = app.staticTexts["Index"]
        XCTAssertEqual(indexLabel.firstMatch.label, "1/10")
    }
    
}
