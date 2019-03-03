//  Created by Eliran Ben-Ezra on 2/16/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import XCTest
@testable import RxBehaviorTester
import RxSwift

//class AllMatcherTests: ListEvaluatorsTestCase {
//  var sut: AllMatcher<State>!
//
//  override func setupSUT() -> AnyMatcher<ListEvaluatorsTestCase.State>? {
//    sut = AllMatcher(mocks.map { $0.toAny() })
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
//  func test_that_it_returns_correct_if_all_are_correct() {
//    mocks.forEach { $0.alwaysReturn(.correct) }
//    source.onNext(makeState())
//
//    let decision = tester.test(withTimeout: 0.1)
//
//    XCTAssertEqual(decision, .correct)
//  }
//
//  func test_that_it_returns_failed_if_any_evaluator_failed() {
//    mocks[0].alwaysReturn(.pending)
//    mocks[1].alwaysReturn(.correct)
//    mocks[2].alwaysReturn(.failed)
//    source.onNext(makeState())
//
//    let decision = tester.test(withTimeout: 0.1)
//
//    XCTAssertEqual(decision, .failed)
//  }
//
//  func test_that_it_stops_evaluating_evaluators_that_returned_correct() {
//    let state = makeState()
//    mocks[0].alwaysReturn(.pending)
//    mocks[1].alwaysReturn(.correct)
//    mocks[2].alwaysReturn(.pending)
//    source.onNext(state)
//    source.onNext(state)
//
//    _ = tester.test(withTimeout: 0.1)
//
//    XCTAssertEqual(mocks[0].actions, [.reset, .next(.next(state)), .next(.next(state))])
//    XCTAssertEqual(mocks[1].actions, [.reset, .next(.next(state))])
//    XCTAssertEqual(mocks[2].actions, [.reset, .next(.next(state)), .next(.next(state))])
//  }
//
//  func test_that_it_returns_pending_if_not_all_are_correct() {
//    mocks[0].alwaysReturn(.correct)
//    mocks[1].alwaysReturn(.pending)
//    mocks[2].alwaysReturn(.correct)
//
//    let decision = tester.test(withTimeout: 0.1)
//
//    XCTAssertEqual(decision, .failed)
//  }
//}
