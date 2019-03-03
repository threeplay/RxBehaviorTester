//  Created by Eliran Ben-Ezra on 2/16/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import XCTest
@testable import RxBehaviorTester
import Nimble

class AllMatcherTests: XCTestCase {
  var sut: AllMatcher<Int>!
  var mocks: [MockMatcher<Int>]!

  override func setUp() {
    mocks = [MockMatcher(), MockMatcher(), MockMatcher()]
    sut = AllMatcher(mocks.map { $0.toAny() })
  }

  func test_that_all_matchers_get_a_reset_signal() {
    sut.reset()
    expect(self.mocks.map { $0.actions }) == [[.reset], [.reset], [.reset]]
  }

  func test_that_it_returns_correct_if_all_matchers_are_correct() {
    mocks.forEach { $0.alwaysReturn(.correct) }
    expect(self.sut.on(event: .next(0))) == .correct
  }

  func test_that_it_returns_failed_if_any_matcher_failed() {
    mocks[0].alwaysReturn(.pending)
    mocks[1].alwaysReturn(.correct)
    mocks[2].alwaysReturn(.failed)

    expect(self.sut.on(event: .next(0))) == .failed
  }

  func test_that_it_stops_evaluating_matches_that_returned_correct() {
    mocks[0].alwaysReturn(.pending)
    mocks[1].alwaysReturn(.correct)
    mocks[2].alwaysReturn(.pending)

    _ = sut.on(event: .next(0))
    _ = sut.on(event: .next(1))

    expect(self.mocks[0].actions) == [.next(.next(0)), .next(.next(1))]
    expect(self.mocks[1].actions) == [.next(.next(0))]
    expect(self.mocks[2].actions) == [.next(.next(0)), .next(.next(1))]
  }

  func test_that_it_returns_pending_if_not_all_are_correct() {
    mocks[0].alwaysReturn(.correct)
    mocks[1].alwaysReturn(.pending)
    mocks[2].alwaysReturn(.correct)

    expect(self.sut.on(event: .next(0))) == .pending
  }
}
