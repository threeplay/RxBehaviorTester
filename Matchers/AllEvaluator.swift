//
//  AllEvaluator.swift
//  RxBehaviorTester
//
//  Created by Eliran Ben-Ezra on 2/17/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import Foundation
import RxSwift

class AllMatcher<Element>: RxBehaviorMatcher {
  private let evaluators: [AnyRxBehaviorEvaluator<Element>]
  private var areCorrect: [Bool]

  init(_ evaluators: [AnyRxBehaviorEvaluator<Element>]) {
    self.evaluators = evaluators
    self.areCorrect = Array(repeating: false, count: evaluators.count)
  }

  func reset() {
    evaluators.forEach { $0.reset() }
    areCorrect = Array(repeating: false, count: evaluators.count)
  }

  func on(event: Event<Element>) -> EvaluationDecision {
    for (i, (evaluator, isCorrect)) in zip(evaluators, areCorrect).enumerated() where isCorrect == false {
      switch evaluator.on(event: event) {
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
