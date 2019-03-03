//  Created by Eliran Ben-Ezra on 2/16/19.

import XCTest
@testable import RxBehaviorTester
import Nimble

class AnyMatcherTests: XCTestCase {
  var sut: AnyMatcher<Int>!
  var mocks: [MockMatcher<Int>]!

  override func setUp() {
    mocks = [MockMatcher(), MockMatcher(), MockMatcher()]
    sut = AnyMatcher(mocks.map { $0.toAny() })
  }

  func test_that_all_matchers_get_a_reset_signal() {
    sut.reset()
    expect(self.mocks.map { $0.actions }) == [[.reset], [.reset], [.reset]]
  }

  func test_that_it_returns_correct_if_any_matcher_is_correct() {
    mocks[1].alwaysReturn(.correct)
    expect(self.sut.on(event: .next(0))) == .correct
  }

  func test_that_it_returns_failed_if_any_matcher_failed() {
    mocks[1].alwaysReturn(.correct)
    mocks[2].alwaysReturn(.failed)

    expect(self.sut.on(event: .next(0))) == .failed
  }

  func test_that_it_stops_evaluating_matches_after_first_correct() {
    mocks[1].alwaysReturn(.correct)

    _ = sut.on(event: .next(0))
    _ = sut.on(event: .next(1))

    expect(self.mocks[0].actions) == [.next(.next(0))]
    expect(self.mocks[1].actions) == [.next(.next(0))]
    expect(self.mocks[2].actions) == [.next(.next(0))]
  }

  func test_that_it_reevaluates_after_reset() {
    mocks[1].alwaysReturn(.correct)

    _ = sut.on(event: .next(0))
    sut.reset()
    _ = sut.on(event: .next(1))

    expect(self.mocks[0].actions) == [.next(.next(0)), .reset, .next(.next(1))]
    expect(self.mocks[1].actions) == [.next(.next(0)), .reset, .next(.next(1))]
    expect(self.mocks[2].actions) == [.next(.next(0)), .reset, .next(.next(1))]
  }
}
