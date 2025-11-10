//Created by Tobiáš Hládek on 10/11/2025.
// 

import XCTest
@testable import Scratcher

final class CardStateTests: XCTestCase {
    
    // MARK: - Equality Tests
    
    func testEquality_unscratched_shouldBeEqual() {
        XCTAssertEqual(CardState.unscratched, CardState.unscratched)
    }
    
    func testEquality_scratched_withSameCode_shouldBeEqual() {
        let code = "ABC123"
        XCTAssertEqual(CardState.scratched(code), CardState.scratched(code))
    }
    
    func testEquality_scratched_withDifferentCode_shouldNotBeEqual() {
        XCTAssertNotEqual(CardState.scratched("ABC123"), CardState.scratched("XYZ789"))
    }
    
    func testEquality_activated_withSameCode_shouldBeEqual() {
        let code = "ABC123"
        XCTAssertEqual(CardState.activated(code), CardState.activated(code))
    }
    
    func testEquality_differentStates_shouldNotBeEqual() {
        XCTAssertNotEqual(CardState.unscratched, CardState.scratched("ABC123"))
        XCTAssertNotEqual(CardState.scratched("ABC123"), CardState.activated("ABC123"))
    }
    
    // MARK: - isScratchable Tests
    
    func testIsScratchable_whenUnscratched_shouldBeTrue() {
        XCTAssertTrue(CardState.unscratched.isScratchable)
    }
    
    func testIsScratchable_whenScratched_shouldBeFalse() {
        XCTAssertFalse(CardState.scratched("ABC123").isScratchable)
    }
    
    func testIsScratchable_whenActivated_shouldBeFalse() {
        XCTAssertFalse(CardState.activated("ABC123").isScratchable)
    }
    
    // MARK: - isActivable Tests
    
    func testIsActivable_whenUnscratched_shouldBeFalse() {
        XCTAssertFalse(CardState.unscratched.isActivable)
    }
    
    func testIsActivable_whenScratched_shouldBeTrue() {
        XCTAssertTrue(CardState.scratched("ABC123").isActivable)
    }
    
    func testIsActivable_whenActivated_shouldBeFalse() {
        XCTAssertFalse(CardState.activated("ABC123").isActivable)
    }
    
    // MARK: - code Tests
    
    func testCode_whenUnscratched_shouldReturnMaskedString() {
        XCTAssertEqual(CardState.unscratched.code, "*** *** ***")
    }
    
    func testCode_whenScratched_shouldReturnCode() {
        let expectedCode = "XYZ789"
        XCTAssertEqual(CardState.scratched(expectedCode).code, expectedCode)
    }
    
    func testCode_whenActivated_shouldReturnCode() {
        let expectedCode = "XYZ789"
        XCTAssertEqual(CardState.activated(expectedCode).code, expectedCode)
    }
    
    // MARK: - State Transition Tests
    
    func testStateTransition_fromUnscratched_toScratched_shouldBeValid() {
        var state = CardState.unscratched
        XCTAssertTrue(state.isScratchable)
        
        state = .scratched("ABC123")
        XCTAssertFalse(state.isScratchable)
        XCTAssertTrue(state.isActivable)
    }
    
    func testStateTransition_fromScratched_toActivated_shouldBeValid() {
        let code = "ABC123"
        var state = CardState.scratched(code)
        XCTAssertTrue(state.isActivable)
        
        state = .activated(code)
        XCTAssertFalse(state.isActivable)
        XCTAssertFalse(state.isScratchable)
    }
}
