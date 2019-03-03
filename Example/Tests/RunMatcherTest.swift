//  Created by Eliran Ben-Ezra on 3/2/19.

import XCTest
@testable import RxBehaviorTester
import Nimble

class RunMatcherTests: XCTestCase {
  var sut: RunMatcher<Int>!
  var countOfInvocations: Int = 0


  override func setUp() {
    self.countOfInvocations = 0
    self.sut = RunMatcher { [weak self] in self?.countOfInvocations += 1 }
  }


  func test_that_it_executes_block_when_next_arrives() {
    _ = sut.on(event: .next(0))

    expect(self.countOfInvocations) == 1
  }

  func test_that_it_executes_block_when_completed_arrives() {
    _ = sut.on(event: .completed)

    expect(self.countOfInvocations) == 1
  }

  func test_that_it_executes_block_when_error_arrives() {
    _ = sut.on(event: .error(TestError.someError))

    expect(self.countOfInvocations) == 1
  }

  func test_that_it_executes_the_block_only_once() {
    _ = sut.on(event: .next(0))
    _ = sut.on(event: .next(1))
    _ = sut.on(event: .error(TestError.someError))
    _ = sut.on(event: .completed)

    expect(self.countOfInvocations) == 1
  }

  func test_that_it_reenables_block_execution_after_reset() {
    _ = sut.on(event: .next(0))
    sut.reset()
    _ = sut.on(event: .next(0))

    expect(self.countOfInvocations) == 2
  }
}
