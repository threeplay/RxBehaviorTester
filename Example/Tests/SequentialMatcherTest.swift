//  Created by Eliran Ben-Ezra on 2/16/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import XCTest
@testable import RxBehaviorTester
import Nimble

class SequentialEvaluatorTests: XCTestCase {
  var sut: SequentialMatcher<Int>!
  var mocks: [MockMatcher<Int>]!

  override func setUp() {
    mocks = [MockMatcher(), MockMatcher(), MockMatcher()]
    sut = SequentialMatcher(mocks.map { $0.toAny() })
  }

  func test_that_all_matchers_get_the_reset_signal() {
    sut.reset()
    expect(self.mocks.map { $0.actions }) == [[.reset], [.reset], [.reset]]
  }

  func test_that_reset_starts_evaluating_matchers_from_the_start() {
    setupSequential()

    _ = sut.on(event: .next(0))
    sut.reset()
    _ = sut.on(event: .next(1))
    _ = sut.on(event: .next(0))

    expect(self.mocks[0].actions) == [.next(.next(0)), .reset, .next(.next(1)), .next(.next(0))]
    expect(self.mocks[1].actions) == [.next(.next(0)), .reset, .next(.next(0))]
    expect(self.mocks[2].actions) == [.reset]
  }

  func test_that_it_evaluates_the_first_matcher_as_long_as_it_pending() {
    _ = sut.on(event: .next(0))
    _ = sut.on(event: .next(1))

    expect(self.mocks[0].actions) == [.next(.next(0)), .next(.next(1))]
    expect(self.mocks[1].actions) == []
    expect(self.mocks[2].actions) == []
  }

  func test_that_it_evaluates_each_in_sequence() {
    setupSequential()

    _ = sut.on(event: .next(0))
    _ = sut.on(event: .next(1))
    _ = sut.on(event: .next(2))

    expect(self.mocks[0].actions.last!) == .next(.next(0))
    expect(self.mocks[1].actions.last!) == .next(.next(1))
    expect(self.mocks[2].actions.last!) == .next(.next(2))
  }

  func test_that_it_stops_at_the_first_failure() {
    setupSequential()
    mocks[1].alwaysReturn(.failed)

    _ = sut.on(event: .next(0))
    _ = sut.on(event: .next(1))
    let decision = sut.on(event: .next(2))

    expect(decision) == .failed
    expect(self.mocks[0].actions.last!) == .next(.next(0))
    expect(self.mocks[1].actions.last!) == .next(.next(0))
    expect(self.mocks[2].actions) == []
  }

  func test_that_an_matcher_following_a_correct_matcher_will_see_the_same_event() {
    setupSequential()

    _ = sut.on(event: .next(0))
    _ = sut.on(event: .next(1))
    _ = sut.on(event: .next(2))

    expect(self.mocks[0].actions) == [.next(.next(0))]
    expect(self.mocks[1].actions) == [.next(.next(0)), .next(.next(1))]
    expect(self.mocks[2].actions) == [.next(.next(1)), .next(.next(2))]
  }

  func test_that_it_returns_correct_if_all_actions_are_correct() {
    setupSequential()

    let decisions = [sut.on(event: .next(0)), sut.on(event: .next(1)), sut.on(event: .next(2))]

    expect(decisions) == [.pending, .pending, .correct]
  }

  private func setupSequential() {
    mocks[0].returnDecision(.correct, when: { $0 == 0 })
    mocks[1].returnDecision(.correct, when: { $0 == 1 })
    mocks[2].returnDecision(.correct, when: { $0 == 2 })
  }
}
