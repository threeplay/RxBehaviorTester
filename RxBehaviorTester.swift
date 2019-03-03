//
//  RxBehaviorTester.swift
//  RxBehaviorTester
//
//  Created by Eliran Ben-Ezra on 2/16/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import Foundation
import RxSwift
import RxBlocking

public class RxBehaviorTester<Element> {
  private let observableUnderTest: Observable<Element>
  private let evaluator: AnyRxBehaviorEvaluator<Element>

  public init(_ observableUnderTest: Observable<Element>, evaluator: AnyRxBehaviorEvaluator<Element>) {
    self.observableUnderTest = observableUnderTest
    self.evaluator = evaluator
  }

  public func test(withTimeout timeout: RxTimeInterval? = nil) -> EvaluationDecision {
    do {
      return try observableUnderTest
        .do(onSubscribe: { [evaluator] in evaluator.reset() })
        .materialize()
        .scan(EvaluationDecision.pending) { [evaluator] decision, nextElement -> EvaluationDecision in
          guard !decision.isFinal else { return decision }
          return evaluator.on(event: nextElement)
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

