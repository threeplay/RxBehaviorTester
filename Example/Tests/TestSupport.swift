//  Created by Eliran Ben-Ezra on 2/16/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxBehaviorTester
import XCTest

enum TestError: Swift.Error {
  case someError
}

extension RxSwift.Event: Equatable where Element: Equatable {
  public static func == (lhs: RxSwift.Event<Element>, rhs: RxSwift.Event<Element>) -> Bool {
    switch (lhs, rhs) {
    case let (.next(l), .next(r)) where l == r: return true
    case (.error(_), .error(_)): return true
    case (.completed, .completed): return true
    default: return false
    }
  }
}

extension RxBehaviorMatcher {
  func stream(_ events: [Element]) -> MatchDecision {
    reset()
    return events.map { self.on(event: .next($0)) }.last ?? .correct
  }
}

class ListMatcherTestCase: XCTestCase {
  struct State: Equatable {
    var intField: Int
    var decision: MatchDecision
  }

  var tester: RxBehaviorTester<State>!
  var source: ReplaySubject<State>!
  var mocks: [MockMatcher<State>]!

  override func setUp() {
    mocks = [MockMatcher(), MockMatcher(), MockMatcher()]
    source = ReplaySubject.createUnbounded()
    tester = RxBehaviorTester(source, matcher: setupSUT()!)
  }

  func setupSUT() -> AnyKindMatcher<State>? {
    return nil
  }

  func makeState(intField: Int = 0, decision: MatchDecision = .pending) -> State {
    return State(intField: intField, decision: decision)
  }
}
