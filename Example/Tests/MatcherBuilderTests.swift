//  Created by Eliran Ben-Ezra on 3/3/19.

import XCTest
@testable import RxBehaviorTester
import Nimble

class MatcherBuilderTests: XCTestCase {
  struct State {
    var id: Int
    var string: String

    init(id: Int = 0, string: String = "") {
      self.id = id
      self.string = string
    }
  }

  var sut: MatcherBuilder<State>!

  override func setUp() {
    sut = MatcherBuilder()
  }

  func test_that_it_can_create_a_predicate_matcher() {
    let matcher = sut.build { dsl in
      dsl.match { $0.id == 0 }
    }

    expect(matcher.stream([State(id: 0)])) == .correct
    expect(matcher.stream([State(id: 1)])) == .pending
  }

  func test_that_it_can_create_a_sequence_of_pedicate_matchers() {
    let matcher = sut.build { dsl in
      dsl.match { $0.id == 0 }
      dsl.match { $0.id == 2 }
    }

    expect(matcher.stream([State(id: 0), State(id: 2)])) == .correct
    expect(matcher.stream([State(id: 2), State(id: 0)])) == .pending
  }

  func test_that_it_can_create_an_unordered_matcher() {
    let matcher = sut.build { dsl in
      dsl.unordered {
        dsl.match { $0.id == 0 }
        dsl.match { $0.id == 1 }
      }
    }

    expect(matcher.stream([State(id: 0), State(id: 1)])) == .correct
    expect(matcher.stream([State(id: 1), State(id: 0)])) == .correct
    expect(matcher.stream([State(id: 1), State(id: 2)])) == .pending
  }

  func test_that_it_can_create_a_first_matcher() {
    let matcher = sut.build { dsl in
      dsl.first {
        dsl.match { $0.id == 0 }
        dsl.match { $0.id == 1 }
      }
    }

    expect(matcher.stream([State(id: 0)])) == .correct
    expect(matcher.stream([State(id: 1)])) == .correct
    expect(matcher.stream([State(id: 2)])) == .pending
  }

  func test_that_it_can_create_always_assertions() {
    let matcher = sut.build { dsl in
      dsl.assert(.always) { $0.id == 0 }
    }

    expect(matcher.stream([State(id: 0)])) == .correct
    expect(matcher.stream([State(id: 1)])) == .failed
  }

  func test_that_it_evaluates_assertions_all_the_time_in_parallel_with_matchers() {
    let matcher = sut.build { dsl in
      dsl.assert(.always) { $0.id != 0 }
      dsl.match { $0.id == 1 }
      dsl.match { $0.id == 2 }
    }

    expect(matcher.stream([State(id: 1), State(id: 2)])) == .correct
    expect(matcher.stream([State(id: 1), State(id: 0), State(id: 2)])) == .failed
    expect(matcher.stream([State(id: 1), State(id: 2), State(id: 0)])) == .correct
  }

  func test_that_assertion_start_after_the_last_match() {
    let matcher = sut.build { dsl in
      dsl.match { $0.id != 0 }
      dsl.assert(.always) { $0.id != 0 }
      dsl.match { $0.id == 1 }
    }

    expect(matcher.stream([State(id: 0)])) == .pending
    expect(matcher.stream([State(id: 1)])) == .correct
    expect(matcher.stream([State(id: 2), State(id: 0)])) == .failed
  }
}
