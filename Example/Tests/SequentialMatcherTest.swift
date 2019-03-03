//  Created by Eliran Ben-Ezra on 2/16/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import XCTest
@testable import RxBehaviorTester
import RxSwift

//class SequentialEvaluatorTests: ListEvaluatorsTestCase {
//  var sut: SequentialMatcher<State>!
//
//  override func setupSUT() -> AnyMatcher<ListEvaluatorsTestCase.State>? {
//    sut = SequentialMatcher(mocks.map { $0.toAny() })
//    return sut.toAny()
//  }
//  
//  func test_that_all_evaluators_get_the_reset_signal() {
//    _ = tester.test(withTimeout: 0.1)
//
//    mocks.forEach {
//      XCTAssertEqual($0.actions, [.reset])
//    }
//  }
//
//  func test_that_it_evaluates_the_first_evaluator_only_as_long_as_it_pending() {
//    source.onNext(makeState())
//    source.onNext(makeState())
//    source.onNext(makeState())
//
//    _ = tester.test(withTimeout: 0.1)
//
//    XCTAssertEqual(mocks[0].actions.count, 1+3)
//    mocks.dropFirst().forEach {
//      XCTAssertEqual($0.actions.count, 1)
//    }
//  }
//
//  func test_that_it_evaluates_each_in_sequence() {
//    setupSequentialMocksWithEvents()
//
//    _ = tester.test(withTimeout: 0.1)
//
//    XCTAssertEqual(mocks[0].actions.last!, .next(.next(makeState())))
//    XCTAssertEqual(mocks[1].actions.last!, .next(.next(makeState(intField: 1))))
//    XCTAssertEqual(mocks[2].actions.last!, .next(.next(makeState(intField: 2))))
//  }
//
//  func test_that_it_stops_at_the_first_failure() {
//    setupSequentialMocksWithEvents()
//
//    mocks[1].alwaysReturn(.failed)
//
//    let decision = tester.test(withTimeout: 0.1)
//
//    XCTAssertEqual(decision, .failed)
//    XCTAssertEqual(mocks[0].actions.count, 2)
//    XCTAssertEqual(mocks[1].actions.count, 2)
//    XCTAssertEqual(mocks[2].actions.count, 1)
//  }
//
//  func test_that_an_evaluator_following_a_correct_evaluator_will_see_the_same_event() {
//    let states = setupSequentialMocksWithEvents()
//
//    _ = tester.test(withTimeout: 0.1)
//
//    XCTAssertEqual(mocks[0].actions, [.reset, .next(.next(states[0]))])
//    XCTAssertEqual(mocks[1].actions, [.reset, .next(.next(states[0])), .next(.next(states[1]))])
//    XCTAssertEqual(mocks[2].actions, [.reset, .next(.next(states[1])), .next(.next(states[2]))])
//  }
//
//  func test_that_it_returns_correct_if_all_actions_are_correct() {
//    let state = setupSequentialMocksWithEvents().first!
//    mocks.forEach { $0.alwaysReturn(.correct) }
//
//    let decision = tester.test(withTimeout: 0.1)
//
//    XCTAssertEqual(decision, .correct)
//    mocks.forEach {
//      XCTAssertEqual($0.actions, [.reset, .next(.next(state))])
//    }
//  }
//
//  @discardableResult
//  private func setupSequentialMocksWithEvents() -> [State] {
//    let states = [makeState(),  makeState(intField: 1), makeState(intField: 2)]
//    states.forEach(source.onNext)
//    mocks[0].returnDecision(.correct, when: { $0.intField == 0 })
//    mocks[1].returnDecision(.correct, when: { $0.intField == 1 })
//    mocks[2].returnDecision(.correct, when: { $0.intField == 2 })
//    return states
//  }
//}
