import Foundation

// MARK: - SafetyRule Protocol
protocol SafetyRule {
  func evaluate(current: Int, previous: Int?) -> Bool
  func reset()
  func snapshot() -> Any
  func restore(from snapshot: Any)
}

// MARK: - TrendRule
// Ensures the sequence is strictly increasing or strictly decreasing once established.
class TrendRule: SafetyRule {
  private var trend: Int?  // +1 for increasing, -1 for decreasing

  func evaluate(current: Int, previous: Int?) -> Bool {
    guard let previous = previous else { return true }

    if trend == nil {
      if current > previous {
        trend = 1
      } else if current < previous {
        trend = -1
      } else {
        // Equal values are not allowed for the trend
        return false
      }
    }

    if let t = trend {
      // If trend is increasing, we must never go down.
      // If trend is decreasing, we must never go up.
      if (t == 1 && current <= previous) || (t == -1 && current >= previous) {
        return false
      }
    }
    return true
  }

  func reset() {
    trend = nil
  }

  func snapshot() -> Any {
    return trend as Any
  }

  func restore(from snapshot: Any) {
    trend = snapshot as? Int
  }
}

// MARK: - DifferenceRule
// Ensures differences between consecutive levels are in [1, 3].
class DifferenceRule: SafetyRule {
  func evaluate(current: Int, previous: Int?) -> Bool {
    guard let previous = previous else { return true }
    let diff = abs(current - previous)
    return diff >= 1 && diff <= 3
  }

  func reset() {}
  func snapshot() -> Any { return () }
  func restore(from snapshot: Any) {}
}

// MARK: - SafetySystems Protocol
// Something that can be evaluated by SafetyRules.
protocol SafetySystems {
  var levels: [Int] { get }
  var rules: [SafetyRule] { get set }

  mutating func setupRules()
  func isSafe() -> Bool
  func isSafe(dampen: Bool) -> Bool
}

// MARK: - Default Implementations for SafetySystems
extension SafetySystems {
  mutating func setupRules() {
    // Initialize fresh rules
    rules = [TrendRule(), DifferenceRule()]
  }

  func isSafe() -> Bool {
    return evaluateWithoutDampener()
  }

  func isSafe(dampen: Bool) -> Bool {
    guard dampen else {
      return isSafe()
    }

    // If already safe, no need to remove anything
    if isSafe() {
      return true
    }

    // Brute force approach: try removing each level and test again
    for i in 0..<levels.count {
      let modifiedLevels = Array(levels[..<i]) + Array(levels[(i + 1)...])
      var modifiedReport = Report(levels: modifiedLevels)
      modifiedReport.setupRules()
      if modifiedReport.isSafe() {
        return true
      }
    }

    return false
  }

  private func evaluateWithoutDampener() -> Bool {
    // Use a RuleEvaluator to keep logic clean
    let evaluator = RuleEvaluator(rules: rules.map { cloneRule($0) })
    return evaluator.evaluate(levels: levels)
  }

  // Helper to clone rules. Since these are class-based, we can reset them instead of truly cloning.
  // For testing and safety, we can create new instances. Here we rely on reset().
  private func cloneRule(_ rule: SafetyRule) -> SafetyRule {
    // If we had more complicated logic, we might need a real clone. Here we just reset a new instance:
    switch rule {
    case is TrendRule:
      let r = TrendRule()
      return r
    case is DifferenceRule:
      let r = DifferenceRule()
      return r
    default:
      // If more rules added, handle cloning them here.
      fatalError("Unknown rule type!")
    }
  }
}

// MARK: - RuleEvaluator
// Evaluates a list of rules on a sequence of levels without a dampener.
struct RuleEvaluator {
  var rules: [SafetyRule]

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
      let nums = line.split(separator: " ").compactMap { Int($0) }
      var report = Report(levels: nums)
      report.setupRules()
      return report
    }
  }

  let levels: [Int]
  var rules: [SafetyRule] = []

  typealias Index = Int
  var startIndex: Int { return levels.startIndex }
  var endIndex: Int { return levels.endIndex }

  func index(after index: Int) -> Int {
    return levels.index(after: index)
  }

  subscript(position: Int) -> Int {
    return levels[position]
  }

  mutating func setupRules() {
    rules = [TrendRule(), DifferenceRule()]
  }

}

// MARK: - Entry Points
func part1(_ input: String) -> Int {
  let reports = Report.parse(input)
  return reports.count { $0.isSafe() }
}

func part2(_ input: String) -> Int {
  let reports = Report.parse(input)
  return reports.count { $0.isSafe(dampen: true) }
}
