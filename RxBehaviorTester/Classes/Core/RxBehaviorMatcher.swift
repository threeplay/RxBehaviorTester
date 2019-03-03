//  Created by Eliran Ben-Ezra on 2/16/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.

import Foundation
import enum RxSwift.Event

public protocol RxBehaviorMatcher {
  associatedtype Element
  typealias Event = RxSwift.Event<Element>

  func reset()
  func on(event: Event) -> MatchDecision
}
