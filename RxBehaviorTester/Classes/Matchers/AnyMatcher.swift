//  Created by Eliran Ben-Ezra on 2/17/19.

import Foundation
import enum RxSwift.Event

class AnyMatcher<Element>: RxBehaviorMatcher {
  private let matchers: [AnyKindMatcher<Element>]

  init(_ matchers: [AnyKindMatcher<Element>]) {
    self.matchers = matchers
  }

  func reset() {
    matchers.forEach { $0.reset() }
  }

  func on(event: Event<Element>) -> MatchDecision {
    return .pending
  }
}
