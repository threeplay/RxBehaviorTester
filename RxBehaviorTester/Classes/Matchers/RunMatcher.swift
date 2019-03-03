//  Created by Eliran Ben-Ezra on 3/2/19.

import Foundation
import enum RxSwift.Event

class RunMatcher<Element>: RxBehaviorMatcher {
  typealias RunBlock = () -> Void

  private let runBlock: RunBlock
  private var invoked = false

  init(_ runBlock: @escaping RunBlock) {
    self.runBlock = runBlock
  }

  func reset() {
    invoked = false
  }

  func on(event: Event<Element>) -> MatchDecision {
    if !invoked {
      invoked = true
      runBlock()
    }
    return .correct
  }
}
