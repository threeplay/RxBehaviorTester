//  Created by Eliran Ben-Ezra on 2/17/19.

import Foundation
import enum RxSwift.Event

class AnyMatcher<Element>: RxBehaviorMatcher {
  private let matchers: [AnyKindMatcher<Element>]
  private var finalDecision: MatchDecision?

  init(_ matchers: [AnyKindMatcher<Element>]) {
    self.matchers = matchers
  }

  func reset() {
    finalDecision = nil
    matchers.forEach { $0.reset() }
  }

  func on(event: Event<Element>) -> MatchDecision {
    if let decision = finalDecision { return decision }
    for matcher in matchers {
      let decision = matcher.on(event: event)
      switch decision {
      case .pending:
        break
      case .correct:
        finalDecision = .correct
      case .failed:
        finalDecision = .failed
        return .failed
      }
    }
    return finalDecision ?? .pending
  }
}
