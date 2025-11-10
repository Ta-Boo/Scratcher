//Created by Tobiáš Hládek on 10/11/2025.
// 

import XCTest
@testable import Scratcher

@MainActor
final class CardStateHolderTests: XCTestCase {
    var sut: CardStateHolder!

    override func setUp() {
        super.setUp()
        sut = CardStateHolder()
    }
    
    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    // MARK: - Initial State Tests
    
    func testInitialState_shouldBeUnscratched() {
        XCTAssertEqual(sut.cardState, .unscratched)
        XCTAssertTrue(sut.cardState.isScratchable)
        XCTAssertFalse(sut.cardState.isActivable)
    }
    
    // MARK: - State Transition Tests
    
    func testScratchCard_shouldTransitionToScratched() {
        let expectedCode = "ABC123"
        
        sut.cardState = .scratched(expectedCode)
        
        XCTAssertEqual(sut.cardState, .scratched(expectedCode))
        XCTAssertFalse(sut.cardState.isScratchable)
        XCTAssertTrue(sut.cardState.isActivable)
    }
    
    func testActivateCard_shouldTransitionToActivated() {
        let code = "ABC123"
        sut.cardState = .scratched(code)
        
        sut.cardState = .activated(code)
        
        XCTAssertEqual(sut.cardState, .activated(code))
        XCTAssertFalse(sut.cardState.isScratchable)
        XCTAssertFalse(sut.cardState.isActivable)
    }
    
    // MARK: - Code Extraction Tests
    
    func testCode_whenUnscratched_shouldReturnMaskedString() {
        XCTAssertEqual(sut.cardState.code, "*** *** ***")
    }
    
    func testCode_whenScratched_shouldReturnCode() {
        let expectedCode = "XYZ789"
        sut.cardState = .scratched(expectedCode)
        
        XCTAssertEqual(sut.cardState.code, expectedCode)
    }
    
    func testCode_whenActivated_shouldReturnCode() {
        let expectedCode = "XYZ789"
        sut.cardState = .activated(expectedCode)
        
        XCTAssertEqual(sut.cardState.code, expectedCode)
    }
    
}
