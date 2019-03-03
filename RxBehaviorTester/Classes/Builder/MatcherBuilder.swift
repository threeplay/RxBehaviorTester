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
class MatcherBuilder<Element> {
  class Context<Element> {
    private var sequentialMatchers = [AnyKindMatcher<Element>]()

    fileprivate init() {}

    fileprivate func build() -> AnyKindMatcher<Element> {
      return SequentialMatcher(sequentialMatchers).toAny()
    }

    func match(_ predicate: @escaping (Element) -> Bool) {
      sequentialMatchers.append(PredicateMatcher(predicate).toAny())
    }
  }

  func build(_ buildBlock: (Context<Element>) -> Void) -> AnyKindMatcher<Element> {
    let context = Context<Element>()
    buildBlock(context)
    return context.build()
  }
}