# RxBehaviorTester

[![CI Status](https://img.shields.io/travis/threeplay/RxBehaviorTester.svg?style=flat)](https://travis-ci.org/threeplay/RxBehaviorTester)
[![Version](https://img.shields.io/cocoapods/v/RxBehaviorTester.svg?style=flat)](https://cocoapods.org/pods/RxBehaviorTester)
[![License](https://img.shields.io/cocoapods/l/RxBehaviorTester.svg?style=flat)](https://cocoapods.org/pods/RxBehaviorTester)
[![Platform](https://img.shields.io/cocoapods/p/RxBehaviorTester.svg?style=flat)](https://cocoapods.org/pods/RxBehaviorTester)
[![Maintainability](https://api.codeclimate.com/v1/badges/f8fa18ad5ae7d25ae75c/maintainability)](https://codeclimate.com/github/threeplay/RxBehaviorTester/maintainability)

Rx Behavior Testing by stream pattern matching and assertions

## Testing an observable

```swift
struct State {
  var isLoading: Bool
  var isSaveEnabled: Bool
  var name: String
}

let observable: Observable<State> = ...

let decision = testBehavior(of: observable) { dsl in 
  dsl.match { $0.isLoading == false }
  dsl.assert(.always) { $0.isLoading == false }
  dsl.match { $0.name == "Updated Name" }
  dsl.match { $0.isSaveEnabled == true }
  dsl.run(.async) { triggerSaving() }
  dsl.match { $0.isSaveEnabled == false }
}

// Decision will be
//  .correct: If no assertions failed and all match clauses matched
//  .failed: If any assetions failed or observable completes or times out without matching
```

## Matchers

### Predicate matcher

```swift
  dsl.match { state in 
    predicate  
  }
```

### Always assertion

```swift
  dsl.assert(.always) { state in
    assertion
  }
```

Assertion is checked from the point of definition until the test completes

### Bounded assertion

```swift
  dsl.assert(.untilNextMatch) { state in
    assertion
  }
```

Only evaluates the assertion until the next matcher after that the assertion is not checked

### Unordered scope

```swift
  dsl.unordered {
    dsl...  // matchers/assertions or other scopes
  }

```

Completes when **all** of the matchers return a result in any order

### First scope

```swift
  dsl.first {
    dsl... // matchers/assertions or other scopes
  }
```

Completes when any of the matchers or assertions returns a result (`.correct` or `.failed`)


## Requirements

* Swift 4.2
* RxSwift 4

## Installation

RxBehaviorTester is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RxBehaviorTester'
```

## Author

Eliran Ben-Ezra, eliran@threeplay.com

## License

RxBehaviorTester is available under the MIT license. See the LICENSE file for more info.
