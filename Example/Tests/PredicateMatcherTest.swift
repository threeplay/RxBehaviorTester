//  Created by Eliran Ben-Ezra on 2/17/19.

import XCTest
@testable import RxBehaviorTester
import RxSwift
import Nimble

class PredicateMatcherTests: XCTestCase {
  func test_that_false_predicate_returns_a_pending_decision() {
    let sut = PredicateMatcher<Int>(decision: .correct) { _ in return false }

    expect(sut.on(event: .next(0))).to(equal(.pending))
  }

  func test_that_true_predicate_returns_the_correct_configured_decision() {
    let sut = PredicateMatcher<Int>(decision: .correct) { _ in return true }

    expect(sut.on(event: .next(0))).to(equal(.correct))
  }

  func test_that_true_predicate_returns_the_failed_configured_decision() {
    let sut = PredicateMatcher<Int>(decision: .failed) { _ in return true }
    expect(sut.on(event: .next(0))).to(equal(.failed))
  }

  func test_that_complete_event_returns_pending() {
    let sut = PredicateMatcher<Int>(decision: .failed) { _ in return true }
    expect(sut.on(event: .completed)).to(equal(.pending))
  }

  func test_that_failed_event_returns_pending() {
    let sut = PredicateMatcher<Int>(decision: .failed) { _ in return true }
    expect(sut.on(event: .error(TestError.someError))).to(equal(.pending))
  }

  func test_that_event_is_passed_to_block_for_evaluation() {
    var values = [Int]()
    let sut = PredicateMatcher<Int>(decision: .failed) {
      values.append($0)
      return true
    }

    _ = sut.on(event: .next(3))
    _ = sut.on(event: .next(1))
    _ = sut.on(event: .next(2))
    _ = sut.on(event: .completed)

    expect(values).to(equal([3, 1, 2]))
  }
}
