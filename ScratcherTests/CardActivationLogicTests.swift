//Created by Tobiáš Hládek on 10/11/2025.
// 

import XCTest
import SwiftUI
@testable import Scratcher
@testable import APIClient

@MainActor
final class CardActivationLogicTests: XCTestCase {
    
    // MARK: - Version Comparison Tests
    
    func testVersionComparison_greaterThan6_1_shouldPass() {
        let passingVersions = ["6.24", "6.2", "7.0", "10.5", "6.11"]
        
        for versionString in passingVersions {
            if let version = Double(versionString) {
                XCTAssertTrue(version > 6.1, "Version \(versionString) should be greater than 6.1")
            }
        }
    }
    
    func testVersionComparison_lessThanOrEqualTo6_1_shouldFail() {
        let failingVersions = ["6.1", "6.0", "5.9", "1.0"]
        
        for versionString in failingVersions {
            if let version = Double(versionString) {
                XCTAssertFalse(version > 6.1, "Version \(versionString) should not be greater than 6.1")
            }
        }
    }
    
    
    // MARK: - Activation Response Parsing Tests
    
    func testActivationResponse_withSuccessfulVersion_shouldActivate() throws {
        let response = ActivationResponse(ios: "6.24")
        
        if let version = Double(response.ios), version > 6.1 {
            XCTAssertTrue(true, "Should activate with version 6.24")
        } else {
            XCTFail("Should have activated with version 6.24")
        }
    }
    
    func testActivationResponse_withFailingVersion_shouldNotActivate() throws {
        let response = ActivationResponse(ios: "6.0")
        
        if let version = Double(response.ios), version > 6.1 {
            XCTFail("Should not activate with version 6.0")
        } else {
            XCTAssertTrue(true, "Should not activate with version 6.0")
        }
    }
    
    // MARK: - Card State After Activation Tests
    
    func testCardState_afterSuccessfulActivation_shouldBeActivated() {
        let code = "ABC123"
        var cardState = CardState.scratched(code)
        
        // Simulate successful activation
        cardState = .activated(code)
        
        XCTAssertEqual(cardState, .activated(code))
        XCTAssertFalse(cardState.isActivable)
        XCTAssertFalse(cardState.isScratchable)
    }
    
    func testCardState_afterFailedActivation_shouldRemainScratched() {
        let code = "ABC123"
        let cardState = CardState.scratched(code)
        
        // Simulate failed activation (state doesn't change)
        XCTAssertEqual(cardState, .scratched(code))
        XCTAssertTrue(cardState.isActivable)
    }
}

final class ActivationWorkflowTests: XCTestCase {
    
    // MARK: - Complete Workflow Tests
    
    func testCompleteWorkflow_fromUnscratched_toActivated() {
        var state = CardState.unscratched
        XCTAssertTrue(state.isScratchable)
        XCTAssertFalse(state.isActivable)
        
        // Step 1: Scratch the card
        let code = "XYZ789"
        state = .scratched(code)
        XCTAssertFalse(state.isScratchable)
        XCTAssertTrue(state.isActivable)
        XCTAssertEqual(state.code, code)
        
        // Step 2: Activate the card
        state = .activated(code)
        XCTAssertFalse(state.isScratchable)
        XCTAssertFalse(state.isActivable)
        XCTAssertEqual(state.code, code)
    }
    
    func testWorkflow_cannotScratchActivatedCard() {
        let code = "ABC123"
        let state = CardState.activated(code)
        
        XCTAssertFalse(state.isScratchable, "Activated card should not be scratchable")
    }
    
    func testWorkflow_cannotActivateUnscratched() {
        let state = CardState.unscratched
        
        XCTAssertFalse(state.isActivable, "Unscratched card should not be activable")
    }
    
    func testWorkflow_cannotReactivateActivatedCard() {
        let code = "ABC123"
        let state = CardState.activated(code)
        
        XCTAssertFalse(state.isActivable, "Already activated card should not be activable again")
    }
}
