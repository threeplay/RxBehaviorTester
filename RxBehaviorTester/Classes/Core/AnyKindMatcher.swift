//  Created by Eliran Ben-Ezra on 2/16/19.

import Foundation
import enum RxSwift.Event

public class AnyKindMatcher<Element>: RxBehaviorMatcher {
  private let _onEvent: (Event<Element>) -> MatchDecision
  private let _reset: () -> Void
  
  public init<Matcher: RxBehaviorMatcher>(_ matcher: Matcher) where Element == Matcher.Element {
    self._onEvent = matcher.on
    self._reset = matcher.reset
  }

  public func reset() {
    return _reset()
  }

  public func on(event: Event<Element>) -> MatchDecision {
    return _onEvent(event)
  }
}

public extension RxBehaviorMatcher {
  public func toAny() -> AnyKindMatcher<Element> {
    return AnyKindMatcher(self)
  }
}
