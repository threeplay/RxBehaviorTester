//
//  ExampleBehaviorTest.swift
//  RxBehaviorTesterTests
//
//  Created by Eliran Ben-Ezra on 2/17/19.
//  Copyright © 2019 Threeplay Inc. All rights reserved.
//

import Foundation
import RxSwift
import XCTest

struct Test {
  let temp: Int
}

enum Other {
  static let test = Test.self
}


class ExampleBehaviorTest: XCTestCase, XCRxBehaviorTest {
  var activeContext: XCRxBehaviorTestContext<State>? = nil

  struct State {
    var error: String?
    var transition: String?
    var eventId: String?
  }

  func test_that_it_works() {
    let obs = ReplaySubject<State>.createUnbounded()
    testBehavior(of: obs) {
      match { $0.error != nil }
    }
  }
}
