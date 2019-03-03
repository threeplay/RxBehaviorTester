//
//  MatcherBuilder.swift
//  RxBehaviorTesterTests
//
//  Created by Eliran Ben-Ezra on 2/17/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import Foundation
import XCTest
import RxSwift
@testable import RxBehaviorTester
/*

 RxMatcherBuilder

 // match: returns `matched` or `pending`
 // assert: returns `failed` or `matched`


 assert can be between matchers it means that between the matches the assert must hold


 Example reactor testing:

 assert(.always) { $0.error == nil }



 match { $0.isLoading }

 assert { $0.email != nil }

 match { !$0.isLoading }

 do { action.onNext() }

 match { $0.transition == nil }


 What this should do:
   1. check all states and fail if any state has error non nil
   2. wait for state to contain: isLoading == true
   3. wait for state to contain: isLoading == false
   4. Between step 2 & 3 assert that email is not nil
 }


 */

class MatcherBuilderTests: XCTestCase {
}

class XCRxBehaviorTestContext<Element> {
  func buildEvaluators() -> AnyRxBehaviorEvaluator<Element> {
    return PredicateEvaluator<Element> { _ in return false }.toAny()
  }
}

enum AssertScope {
  case always
  case never
}

protocol XCRxBehaviorTest: AnyObject {
  associatedtype Element

  var activeContext: XCRxBehaviorTestContext<Element>? { get set }

  func assert(_ scope: AssertScope, _ predicate: @escaping (Element) -> Bool)
  func match(_ predicate: @escaping (Element) -> Bool)
  func testBehavior(of observable: Observable<Element>, builder: () -> Void)
}

extension XCRxBehaviorTest {
  func assert(_ scope: AssertScope, _ predicate: @escaping (Element) -> Bool) {
    print("Adding assert scope")
  }

  func match(_ predicate: @escaping (Element) -> Bool) {
    print("Adding matcher")
  }

  func testBehavior(of observable: Observable<Element>, builder: () -> Void) {
    activeContext = XCRxBehaviorTestContext()
    builder()
    let decision = RxBehaviorTester(observable, evaluator: activeContext!.buildEvaluators()).test(withTimeout: 1)
    activeContext = nil
    switch decision {
    case .failed:
      XCTFail("Rx Behavior Test Failed")
    case .pending:
      XCTFail("Rx Behavior Test is still pending")
    case .correct:
      break
    }
  }
}
