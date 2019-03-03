//  Created by Eliran Ben-Ezra on 2/17/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import Foundation
import RxSwift

class PredicateMatcher<Element>: RxBehaviorMatcher {
  typealias PredicateBlock = (Element) -> Bool
  private let predicate: PredicateBlock
  private let decision: Decision

  enum Decision {
    case correct
    case failed
  }

  init(decision: Decision = .correct, _ predicate: @escaping PredicateBlock) {
    self.predicate = predicate
    self.decision = decision
  }

  func reset() {
  }

  func on(event: Event<Element>) -> MatchDecision {
    switch event {
    case let .next(element):
      guard predicate(element) else { return .pending }
      switch decision {
      case .correct: return .correct
      case .failed: return .failed
      }
    default:
      return .pending
    }
  }
}
