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
    let matcher = sut.build { c in
      c.match { $0.id == 0 }
    }

    expect(self.stream([State(id: 0)], on: matcher)) == .correct
    expect(self.stream([State(id: 1)], on: matcher)) == .pending
  }

  func test_that_it_can_create_a_sequence_of_pedicate_matchers() {
    let matcher = sut.build { c in
      c.match { $0.id == 0 }
      c.match { $0.id == 2 }
    }

    expect(matcher.stream([State(id: 0), State(id: 2)])) == .correct
    expect(matcher.stream([State(id: 1), State(id: 0), State(id: 3)])) == .pending
  }

  private func stream(_ events: [State], on matcher: AnyKindMatcher<State>) -> MatchDecision {
    matcher.reset()
    return events.map { matcher.on(event: .next($0)) }.last!
  }
}
