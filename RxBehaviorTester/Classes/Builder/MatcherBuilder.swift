//  Created by Eliran Ben-Ezra on 3/2/19.

import Foundation

private class BuilderContext<Element> {
  fileprivate var assertMatchers = [AnyKindMatcher<Element>]()
  fileprivate var matchers = [AnyKindMatcher<Element>]()

  open func add(_ matcher: AnyKindMatcher<Element>) {
    matchers.append(matcher)
  }

  open func addAssert(_ matcher: AnyKindMatcher<Element>) {
    assertMatchers.append(matcher)
  }

  open func build() -> AnyKindMatcher<Element> {
    fatalError("Must be implemented by subclasses")
  }
}

class MatcherBuilder<Element> {
  private class OrderedContext: BuilderContext<Element> {
    override func build() -> AnyKindMatcher<Element> {
      let ordered = SequentialMatcher(matchers).toAny()
      if !assertMatchers.isEmpty {
        return AnyMatcher(assertMatchers + [ordered]).toAny()
      }
      return ordered
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

    enum AssertMode {
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

    func assert(_ mode: AssertMode, _ predicate: @escaping (Element) -> Bool) {
      switch mode {
      case .always:
        context.addAssert(PredicateMatcher(decision: .failed) { !predicate($0) }.toAny())
      default:
        break
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
