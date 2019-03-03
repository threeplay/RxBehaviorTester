//  Created by Eliran Ben-Ezra on 2/16/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import Foundation
import RxSwift

class SequentialMatcher<Element>: RxBehaviorMatcher {
  private let matchers: [AnyMatcher<Element>]
  private var current: Int = 0
  private var decision: MatchDecision?

  init(_ matchers: [AnyMatcher<Element>]) {
    self.matchers = matchers
  }

  func reset() {
    current = 0
    decision = nil
    matchers.forEach { $0.reset() }
  }

  func on(event: Event<Element>) -> MatchDecision {
    if let decision = decision {
      return decision
    }
    while current < matchers.count {
      switch matchers[current].on(event: event) {
      case .pending:
        return .pending
      case .failed:
        decision = .failed
        return .failed
      case .correct:
        current += 1
      }
    }
    return .correct
  }
}
