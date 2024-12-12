import Foundation

// MARK: - SafetyRule Protocol
protocol SafetyRule {
  func evaluate(current: Int, previous: Int?) -> Bool
  func reset()
}

// MARK: - TrendRule
final class TrendRule: SafetyRule {
  private var trend: Int?

  func evaluate(current: Int, previous: Int?) -> Bool {
    guard let previous = previous else { return true }

    if trend == nil {
      trend = (current > previous) ? 1 : (current < previous ? -1 : nil)
    }

    guard let t = trend else { return false }
    return (t == 1 && current > previous) || (t == -1 && current < previous)
  }

  func reset() {
    trend = nil
  }
}

// MARK: - DifferenceRule
final class DifferenceRule: SafetyRule {
  func evaluate(current: Int, previous: Int?) -> Bool {
    guard let previous = previous else { return true }
    let diff = abs(current - previous)
    return (1...3).contains(diff)
  }

  func reset() {}
}

// MARK: - SafetySystems Protocol
protocol SafetySystems {
  var levels: [Int] { get }
  var rules: [SafetyRule] { get }

  func isSafe() -> Bool
  func isSafe(dampen: Bool) -> Bool
}

extension SafetySystems {
  func isSafe() -> Bool {
    RuleEvaluator(rules: rules).evaluate(levels: levels)
  }

  func isSafe(dampen: Bool) -> Bool {
    guard dampen else { return isSafe() }
    if isSafe() { return true }

    return levels.indices.contains { index in
      let modifiedLevels = levels.removing(at: index)
      return RuleEvaluator(rules: rules).evaluate(levels: modifiedLevels)
    }
  }
}

// MARK: - RuleEvaluator
struct RuleEvaluator {
  private var rules: [SafetyRule]

  init(rules: [SafetyRule]) {
    self.rules = rules
    self.rules.forEach { $0.reset() }
  }

  func evaluate(levels: [Int]) -> Bool {
    var previous: Int?
    for level in levels {
      if !rules.allSatisfy({ $0.evaluate(current: level, previous: previous) }) {
        return false
      }
      previous = level
    }
    return true
  }
}

// MARK: - Report
struct Report: SafetySystems, Collection {
  static func parse(_ input: String) -> [Report] {
    input.split(separator: "\n").map { line in
      let levels = line.split(separator: " ").compactMap { Int($0) }
      return Report(levels: levels)
    }
  }

  let levels: [Int]
  var rules: [SafetyRule] = [TrendRule(), DifferenceRule()]

  // Collection conformance
  typealias Index = Int
  var startIndex: Int { levels.startIndex }
  var endIndex: Int { levels.endIndex }
  func index(after index: Int) -> Int { levels.index(after: index) }
  subscript(position: Int) -> Int { levels[position] }
}

// MARK: - Utilities
extension Array {
  func removing(at index: Int) -> [Element] {
    var copy = self
    copy.remove(at: index)
    return copy
  }
}

// MARK: - Entry Points
func part1(_ input: String) -> Int {
  Report.parse(input).count { $0.isSafe() }
}

func part2(_ input: String) -> Int {
  Report.parse(input).count { $0.isSafe(dampen: true) }
}
