//  Created by Eliran Ben-Ezra on 3/2/19.

import Foundation

private class BuilderContext<Element> {
  fileprivate var assertMatchers = [AnyKindMatcher<Element>]()
  fileprivate var boundedAssertMatchers = [AnyKindMatcher<Element>]()
  fileprivate var matchers = [AnyKindMatcher<Element>]()

  open func add(_ matcher: AnyKindMatcher<Element>) {
    matchers.append(matcher)
  }

  open func addAssert(_ matcher: AnyKindMatcher<Element>) {
    assertMatchers.append(matcher)
  }

  open func addBoundedAssert(_ matcher: AnyKindMatcher<Element>) {
    boundedAssertMatchers.append(matcher)
  }

  open func build() -> AnyKindMatcher<Element> {
    fatalError("Must be implemented by subclasses")
  }
}

class MatcherBuilder<Element> {
  private class OrderedContext: BuilderContext<Element> {
    private var scopes = [(matchers: [AnyKindMatcher<Element>], asserts: [AnyKindMatcher<Element>])]()

    override func addAssert(_ matcher: AnyKindMatcher<Element>) {
      if !matchers.isEmpty { makeScope() }
      super.addAssert(matcher)
    }

    override func add(_ matcher: AnyKindMatcher<Element>) {
      if !boundedAssertMatchers.isEmpty {
        super.add(AnyMatcher([matcher] + boundedAssertMatchers).toAny())
        boundedAssertMatchers = []
      } else {
        super.add(matcher)
      }
    }

    private func makeScope() {
      if matchers.isEmpty, assertMatchers.isEmpty { return }
      scopes.append((matchers: matchers, asserts: assertMatchers))
      matchers = []
      assertMatchers = []
    }

    override func build() -> AnyKindMatcher<Element> {
      makeScope()

      let ordered: AnyKindMatcher<Element>? = scopes.reversed().reduce(nil) { current, scope in
        let matchers = SequentialMatcher(current == nil ? scope.matchers : scope.matchers + [current!]).toAny()
        if !scope.asserts.isEmpty {
          return AnyMatcher(scope.asserts + [matchers]).toAny()
        }
        return matchers
      }
      return ordered ?? PredicateMatcher { _ in true }.toAny()
    }
  }

  private class UnorderedContext: BuilderContext<Element> {
    override func build() -> AnyKindMatcher<Element> {
      guard assertMatchers.isEmpty else { fatalError("Assert matchers cannot be used in unordered context") }
      return AllMatcher(matchers).toAny()
    }
  }

  private class FirstContext: BuilderContext<Element> {
    override func build() -> AnyKindMatcher<Element> {
      return AnyMatcher(assertMatchers + matchers).toAny()
    }
  }

  class BuilderDSL<Element> {
    private var contextStack = [BuilderContext<Element>]()
    private var context: BuilderContext<Element> { return contextStack.last! }

    enum AssertLifetime {
      case always
      case untilNextMatch
    }

    func match(_ predicate: @escaping (Element) -> Bool) {
      context.add(PredicateMatcher(predicate).toAny())
    }

    func unordered(_ block: () -> Void) {
      context.add(with(UnorderedContext() as! BuilderContext<Element>, block: block).build())
    }

    func first(_ block: () -> Void) {
      context.add(with(FirstContext() as! BuilderContext<Element>, block: block).build())
    }

    func assert(_ lifetime: AssertLifetime, _ predicate: @escaping (Element) -> Bool) {
      switch lifetime {
      case .always:
        context.addAssert(PredicateMatcher(decision: .failed) { !predicate($0) }.toAny())
      case .untilNextMatch:
        context.addBoundedAssert(PredicateMatcher(decision: .failed) { !predicate($0) }.toAny())
      }
    }

    fileprivate init(initialContext: BuilderContext<Element>) {
      self.contextStack = [initialContext]
    }

    fileprivate func with(_ context: BuilderContext<Element>, block: () -> Void) -> BuilderContext<Element> {
      contextStack.append(context)
      defer { contextStack.removeLast() }
      block()
      return context
    }

    fileprivate func build() -> AnyKindMatcher<Element> {
      Swift.assert(contextStack.count == 1)
      return context.build()
    }
  }

  func build(_ buildBlock: (BuilderDSL<Element>) -> Void) -> AnyKindMatcher<Element> {
    let dsl = BuilderDSL<Element>(initialContext: OrderedContext())
    buildBlock(dsl)
    return dsl.build()
  }
}
