//  Created by Eliran Ben-Ezra on 3/2/19.

import Foundation

/*

 struct State {
   let p: Int
 }

 let matcher = build(State.self) { m in
   m.assert(.always) { $0.p != 3 }

   m.match { $0.p == 1 }

   m.assert { $0.p != 4 }

   m.match("should be 2") { $0.p == 2 }
   m.match(\.p, is: 2)
   m.match(\.p, isNot: 2)
 }


 Asserts:
   always - This should never happen in the scope being evaluated
     Converts into

     All matcher (inside a sequence matcher):
        -> All asserts are individual
        -> All the other matchers are part of a sequence

  between - Only evaluates the assert between matches
     Triggers when a matcher returns correct, and stops evaluating when next matcher is correct

     This is done by

 any {
   asserts
   matcher
 }
    

 */
private class BuilderContext<Element> {
  open func add(_ matcher: AnyKindMatcher<Element>) {
    fatalError("Must be implemented by subclasses")
  }

  open func build() -> AnyKindMatcher<Element> {
    fatalError("Must be implemented by subclasses")
  }
}

class MatcherBuilder<Element> {
  private class OrderedContext: BuilderContext<Element> {
    private var orderedMatchers = [AnyKindMatcher<Element>]()

    override func add(_ matcher: AnyKindMatcher<Element>) {
      orderedMatchers.append(matcher)
    }

    override func build() -> AnyKindMatcher<Element> {
      return SequentialMatcher(orderedMatchers).toAny()
    }
  }

  private class UnorderedContext: BuilderContext<Element> {
    private var unorderedMatchers = [AnyKindMatcher<Element>]()

    override func add(_ matcher: AnyKindMatcher<Element>) {
      unorderedMatchers.append(matcher)
    }

    override func build() -> AnyKindMatcher<Element> {
      return AllMatcher(unorderedMatchers).toAny()
    }
  }

  class BuilderDSL<Element> {
    private var contextStack = [BuilderContext<Element>]()
    private var context: BuilderContext<Element> { return contextStack.last! }

    func match(_ predicate: @escaping (Element) -> Bool) {
      context.add(PredicateMatcher(predicate).toAny())
    }

    func unordered(_ block: () -> Void) {
      context.add(with(UnorderedContext() as! BuilderContext<Element>, block: block).build())
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
      assert(contextStack.count == 1)
      return context.build()
    }
  }

  func build(_ buildBlock: (BuilderDSL<Element>) -> Void) -> AnyKindMatcher<Element> {
    let dsl = BuilderDSL<Element>(initialContext: OrderedContext())
    buildBlock(dsl)
    return dsl.build()
  }
}
