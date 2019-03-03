//  Created by Eliran Ben-Ezra on 2/16/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxBlocking

public class RxBehaviorTester<Element> {
  private let observableUnderTest: Observable<Element>
  private let matcher: AnyMatcher<Element>

  public init(_ observableUnderTest: Observable<Element>, matcher: AnyMatcher<Element>) {
    self.observableUnderTest = observableUnderTest
    self.matcher = matcher
  }

  public func test(withTimeout timeout: RxTimeInterval? = nil) -> MatchDecision {
    do {
      return try observableUnderTest
        .do(onSubscribe: { [matcher] in matcher.reset() })
        .materialize()
        .scan(MatchDecision.pending) { [matcher] decision, nextElement -> MatchDecision in
          guard !decision.isFinal else { return decision }
          return matcher.on(event: nextElement)
        }
        .skipWhile { !$0.isFinal }
        .take(1)
        .toBlocking(timeout: timeout)
        .single()
    } catch {
      return .failed
    }
  }
}

