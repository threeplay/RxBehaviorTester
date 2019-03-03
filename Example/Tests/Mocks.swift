//  Created by Eliran Ben-Ezra on 3/2/19.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import RxSwift
import RxBehaviorTester
import XCTest

extension MockAction: Equatable where Element: Equatable {
  internal static func == (lhs: MockAction<Element>, rhs: MockAction<Element>) -> Bool {
    switch (lhs, rhs) {
    case (.reset, .reset): return true
    case let (.next(l), .next(r)) where l == r: return true
    default: return false
    }
  }
}

enum MockAction<Element> {
  case reset
  case next(Event<Element>)
}

class MockMatcher<Element>: RxBehaviorMatcher {
  var actions = [MockAction<Element>]()
  var onEvent: ((RxSwift.Event<Element>) -> MatchDecision)?

  init() {
    resetMock()
  }

  func resetMock() {
    actions = []
    onEvent = nil
  }

  func alwaysReturn(_ decision: MatchDecision) {
    self.onEvent = { _ in return decision }
  }

  func returnOnNext(_ nextBlock: @escaping (Element) -> MatchDecision) {
    self.onEvent = {
      switch $0 {
      case let .next(e): return nextBlock(e)
      default: return .pending
      }
    }
  }

  func returnDecision(_ decision: MatchDecision, when elementBlock: @escaping (Element) -> Bool) {
    returnOnNext { elementBlock($0) ? decision : .pending }
  }

  func reset() {
    actions.append(.reset)
  }

  func on(event: Event<Element>) -> MatchDecision {
    actions.append(.next(event))
    return onEvent?(event) ?? .pending
  }
}

