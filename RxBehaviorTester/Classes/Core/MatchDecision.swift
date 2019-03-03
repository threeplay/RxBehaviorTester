//  Created by Eliran Ben-Ezra on 2/16/19.

import Foundation

public enum MatchDecision: Equatable {
  case pending
  case correct
  case failed

  var isFinal: Bool {
    switch self {
    case .correct, .failed: return true
    case .pending: return false
    }
  }
}
