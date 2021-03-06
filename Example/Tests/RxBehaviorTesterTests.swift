//  Created by Eliran Ben-Ezra on 2/16/19.

import XCTest
@testable import RxBehaviorTester
import RxSwift
import RxBlocking

class RxBehaviorTesterTests: XCTestCase {
  struct State: Equatable {
    var intField: Int
    var decision: MatchDecision
  }

  private var tester: RxBehaviorTester<State>!
  private var source: ReplaySubject<State>!
  private var mockMatcher: MockMatcher<State>!

  func makeState(intField: Int = 0, decision: MatchDecision = .pending) -> State {
    return State(intField: intField, decision: decision)
  }

  override func setUp() {
    mockMatcher = MockMatcher()
    source = ReplaySubject.createUnbounded()
    tester = RxBehaviorTester(source, matcher: mockMatcher.toAny())
  }

  func test_that_it_returns_failed_decision_if_times_out() {
    let decision = tester.test(withTimeout: 0.01)
    XCTAssertEqual(decision, .failed)
  }

  func test_that_it_resets_matcher_before_evaluating_states() {
    source.onCompleted()
    let _ = tester.test(withTimeout: 0.1)

    let expected: [MockAction<State>] = [.reset, .next(Event.completed)]
    let actual = mockMatcher.actions
    XCTAssertEqual(actual, expected)
  }

  func test_that_it_passes_event_to_matcher() {
    let states = [makeState(), makeState(intField: 1), makeState(intField: 2)]
    states.forEach(source.onNext)
    source.onCompleted()

    _ = tester.test()

    var expectedActions: [MockAction<State>] = [.reset]
    expectedActions.append(contentsOf: states.map { .next(Event.next($0)) })
    expectedActions.append(MockAction.next(Event.completed))

    XCTAssertEqual(mockMatcher.actions.count, expectedActions.count)
    XCTAssertEqual(mockMatcher.actions, expectedActions)
  }

  func test_that_correct_decision_terminates_the_test_and_returns_the_decision() {
    source.onNext(makeState())
    source.onNext(makeState(decision: .correct))
    source.onNext(makeState(decision: .failed))
    mockMatcher.returnOnNext { $0.decision }

    let decision = tester.test(withTimeout: 0.1)

    XCTAssertEqual(decision, .correct)
  }

  func test_that_final_decision_doesnt_send_any_more_events_to_matcher() {
    source.onNext(makeState())
    source.onNext(makeState(decision: .correct))
    source.onNext(makeState(decision: .failed))
    source.onNext(makeState(decision: .failed))
    mockMatcher.returnOnNext { $0.decision }

    _ = tester.test(withTimeout: 0.1)

    XCTAssertEqual(mockMatcher.actions.count, 1+2)
    XCTAssertEqual(mockMatcher.actions, [.reset, .next(.next(makeState())), .next(.next(makeState(decision: .correct)))])
  }

  func test_that_failed_decision_terminates_the_test_and_returns_the_decision() {
    source.onNext(makeState())
    source.onNext(makeState(decision: .failed))
    source.onNext(makeState(decision: .correct))
    mockMatcher.returnOnNext { $0.decision }

    let decision = tester.test(withTimeout: 0.1)

    XCTAssertEqual(decision, .failed)
  }
}
