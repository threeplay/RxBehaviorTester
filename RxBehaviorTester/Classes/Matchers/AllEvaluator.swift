//  Created by Eliran Ben-Ezra on 2/17/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import Foundation
import RxSwift

class AllMatcher<Element>: RxBehaviorMatcher {
  private let matchers: [AnyMatcher<Element>]
  private var areCorrect: [Bool]

  init(_ matchers: [AnyMatcher<Element>]) {
    self.matchers = matchers
    self.areCorrect = Array(repeating: false, count: matchers.count)
  }

  func reset() {
    matchers.forEach { $0.reset() }
    areCorrect = Array(repeating: false, count: matchers.count)
  }

  func on(event: Event<Element>) -> MatchDecision {
    for (i, (matchers, isCorrect)) in zip(matchers, areCorrect).enumerated() where isCorrect == false {
      switch matchers.on(event: event) {
      case .failed:
        return .failed
      case .pending:
        break
      case .correct:
        areCorrect[i] = true
      }
    }
    return areCorrect.allSatisfy { $0 } ? .correct : .pending
  }
}
