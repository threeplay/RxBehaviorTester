//
//  SequentialEvaluator.swift
//  RxBehaviorTester
//
//  Created by Eliran Ben-Ezra on 2/16/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import Foundation
import RxSwift

class SequentialEvaluator<Element>: RxBehaviorEvaluator {
  private let evaluators: [AnyRxBehaviorEvaluator<Element>]
  private var current: Int = 0

  init(_ evaluators: [AnyRxBehaviorEvaluator<Element>]) {
    self.evaluators = evaluators
  }

  func reset() {
    current = 0
    evaluators.forEach { $0.reset() }
  }

  func on(event: Event<Element>) -> EvaluationDecision {
    while current < evaluators.count {
      switch evaluators[current].on(event: event) {
      case .pending: return .pending
      case .failed: return .failed
      case .correct: current += 1
      }
    }
    return .correct
  }
}
