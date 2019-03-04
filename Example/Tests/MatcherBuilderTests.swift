//  Created by Eliran Ben-Ezra on 3/3/19.

import XCTest
@testable import RxBehaviorTester
import Nimble

class MatcherBuilderTests: XCTestCase {
  var sut: MatcherBuilder<Int>!

  override func setUp() {
    sut = MatcherBuilder()
  }

  func test_that_it_can_create_an_empty_matcher() {
    let matcher = sut.build { _ in
    }

    expect(matcher.stream([0])) == .correct
  }

  func test_that_it_can_create_a_predicate_matcher() {
    let matcher = sut.build { dsl in
      dsl.match { $0 == 0 }
    }

    expect(matcher.stream([0])) == .correct
    expect(matcher.stream([1])) == .pending
  }

  func test_that_it_can_create_a_sequence_of_pedicate_matchers() {
    let matcher = sut.build { dsl in
      dsl.match { $0 == 0 }
      dsl.match { $0 == 2 }
    }

    expect(matcher.stream([0, 2])) == .correct
    expect(matcher.stream([2, 0])) == .pending
  }

  func test_that_it_can_create_an_unordered_matcher() {
    let matcher = sut.build { dsl in
      dsl.unordered {
        dsl.match { $0 == 0 }
        dsl.match { $0 == 1 }
      }
    }

    expect(matcher.stream([0, 1])) == .correct
    expect(matcher.stream([1, 0])) == .correct
    expect(matcher.stream([1, 2])) == .pending
  }

  func test_that_it_can_create_a_first_matcher() {
    let matcher = sut.build { dsl in
      dsl.first {
        dsl.match { $0 == 0 }
        dsl.match { $0 == 1 }
      }
    }

    expect(matcher.stream([0])) == .correct
    expect(matcher.stream([1])) == .correct
    expect(matcher.stream([2])) == .pending
  }

  func test_that_it_can_create_always_assertions() {
    let matcher = sut.build { dsl in
      dsl.assert(.always) { $0 == 0 }
    }

    expect(matcher.stream([0])) == .correct
    expect(matcher.stream([1])) == .failed
  }

  func test_that_it_evaluates_assertions_all_the_time_in_parallel_with_matchers() {
    let matcher = sut.build { dsl in
      dsl.assert(.always) { $0 != 0 }
      dsl.match { $0 == 1 }
      dsl.match { $0 == 2 }
    }

    expect(matcher.stream([1, 2])) == .correct
    expect(matcher.stream([1, 0, 2])) == .failed
    expect(matcher.stream([1, 2, 0])) == .correct
  }

  func test_that_assertion_start_after_the_last_match() {
    let matcher = sut.build { dsl in
      dsl.match { $0 != 0 }
      dsl.assert(.always) { $0 != 0 }
      dsl.match { $0 == 1 }
    }

    expect(matcher.stream([0])) == .pending
    expect(matcher.stream([1])) == .correct
    expect(matcher.stream([2, 0])) == .failed
  }

  func test_that_assertions_untilNextMatcher_asserts_assert_between_matchers() {
    let matcher = sut.build { dsl in
      dsl.match { $0 != 0 }
      dsl.assert(.untilNextMatch) { $0 != 0 }
      dsl.match { $0 == 1 }
      dsl.match { $0 == 0 }
    }

    expect(matcher.stream([1, 0])) == .correct
    expect(matcher.stream([2, 0])) == .failed
    expect(matcher.stream([1, 2])) == .pending
  }
}
