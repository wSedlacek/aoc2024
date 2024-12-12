import Foundation
import Testing

@testable import aoc

func readFile(fileName: String) throws -> String {
  let fileURL = URL(fileURLWithPath: fileName)
  let input = try String(contentsOf: fileURL, encoding: .utf8)
  return input
}

// The input is many reports (one per line)
// Each report is a list of levels separated by spaces

// For example:
// 7 6 4 2 1
// 1 2 7 8 9
// 9 7 6 2 1
// 1 3 2 4 5
// 8 6 4 4 1
// 1 3 6 7 9

// The goal is to figure out which reports are safe.
// Safety rules:
// - The levels are either all increasing or all decreasing.
// - Any two adjacent levels differ by at least one and at most three.

// For example:
// 7 6 4 2 1 - Safe
// 1 2 7 8 9 - Unsafe
// 9 7 6 2 1 - Unsafe
// 1 3 2 4 5 - Unsafe
// 8 6 4 4 1 - Unsafe
// 1 3 6 7 9 - Safe

// The answer is the number of safe reports

@Test func samplePart1() async throws {
  let input = try readFile(fileName: "sample.txt")
  let answer = aoc.part1(input)
  #expect(answer == 2)
}

@Test func puzzlePart1() async throws {
  let input = try readFile(fileName: "puzzle.txt")
  let answer = aoc.part1(input)
  #expect(answer == 624)
}

// MARK: - Part 2

// What?! Nobody told you about the Problem Dampener?!
// It can solve 1 bad level of each report!
// So, the answer is actually 4!

@Test func samplePart2() async throws {
  let input = try readFile(fileName: "sample.txt")
  let answer = aoc.part2(input)
  #expect(answer == 4)
}

@Test func puzzlePart2() async throws {
  let input = try readFile(fileName: "puzzle.txt")
  let answer = aoc.part2(input)
  #expect(answer > 653)
  #expect(answer == 658)
  #expect(answer < 710)
}

// MARK: - Testing Rules

func evaluateRule(_ rule: SafetyRule, levels: [Int]) -> Bool {
  var previous: Int?
  for level in levels {
    if !rule.evaluate(current: level, previous: previous) {
      return false
    }

    previous = level
  }
  return true
}

// MARK: - Difference Rule

@Test
func testValidDifferences() {
  let rule = DifferenceRule()
  #expect(evaluateRule(rule, levels: [1, 3, 2, 4]) == true)
}

@Test
func testTooSmallDifference() {
  let rule = DifferenceRule()
  #expect(evaluateRule(rule, levels: [1, 1]) == false)
}

@Test
func testTooLargeDifference() {
  let rule = DifferenceRule()
  #expect(evaluateRule(rule, levels: [1, 5]) == false)
}

// MARK: - Trend Rule

@Test
func testIncreasingTrend() {
  let rule = TrendRule()
  #expect(evaluateRule(rule, levels: [1, 2, 3, 4, 5]) == true)
}

@Test
func testDecreasingTrend() {
  let rule = TrendRule()
  #expect(evaluateRule(rule, levels: [5, 4, 3, 2, 1]) == true)
}

@Test
func testTrendViolation() {
  let rule = TrendRule()
  #expect(evaluateRule(rule, levels: [1, 2, 1]) == false)
}

@Test
func testResetTrendAfterViolation() {
  let rule = TrendRule()
  var previous: Int?

  #expect(rule.evaluate(current: 1, previous: previous) == true)
  previous = 1
  #expect(rule.evaluate(current: 2, previous: previous) == true)
  previous = 2

  #expect(rule.evaluate(current: 1, previous: previous) == false)
  rule.reset()

  #expect(rule.evaluate(current: 2, previous: nil) == true)
  #expect(rule.evaluate(current: 3, previous: 2))
}

@Test
func testKnownSafeWithoutDampener() {
  var report = Report(levels: [7, 6, 4, 2, 1])
  report.setupRules()
  #expect(report.isSafe() == true)

  report = Report(levels: [1, 3, 6, 7, 9])
  report.setupRules()
  #expect(report.isSafe() == true)
}

@Test
func testKnownUnsafeWithoutDampener() {
  var report = Report(levels: [1, 2, 7, 8, 9])
  report.setupRules()
  #expect(report.isSafe() == false)
}

@Test
func testKnownFixableWithDampener() {
  var report = Report(levels: [1, 3, 2, 4, 5])
  report.setupRules()
  #expect(report.isSafe(dampen: true) == true)

  report = Report(levels: [8, 6, 4, 4, 1])
  report.setupRules()
  #expect(report.isSafe(dampen: true) == true)
}

@Test
func testKnownUnfixableEvenWithDampener() {
  var report = Report(levels: [1, 2, 7, 8, 9])
  report.setupRules()
  #expect(report.isSafe(dampen: true) == false)
}

// MARK: - Tests focusing specifically on DifferenceRule and TrendRule in isolation

@Test
func testDifferenceRuleOnly() {
  let rule = DifferenceRule()
  #expect(rule.evaluate(current: 2, previous: 1) == true)  // diff=1 OK
  #expect(rule.evaluate(current: 5, previous: 1) == false)  // diff=4 too large
  #expect(rule.evaluate(current: 1, previous: 1) == false)  // diff=0 too small
}

@Test
func testTrendRuleOnly() {
  let rule = TrendRule()
  // Increasing sequence
  #expect(rule.evaluate(current: 1, previous: nil) == true)
  #expect(rule.evaluate(current: 2, previous: 1) == true)
  #expect(rule.evaluate(current: 3, previous: 2) == true)
  // Continues increasing: allowed
  #expect(rule.evaluate(current: 2, previous: 3) == false)  // breaks trend
  rule.reset()
  // Decreasing sequence
  #expect(rule.evaluate(current: 5, previous: nil) == true)
  #expect(rule.evaluate(current: 4, previous: 5) == true)
  #expect(rule.evaluate(current: 3, previous: 4) == true)
  #expect(rule.evaluate(current: 5, previous: 3) == false)  // breaks decreasing trend
}

// MARK: - Combined tests that we know are fixable by one removal

@Test
func testSimpleFixableCases() {
  var report = Report(levels: [1, 2, 3, 2])
  report.setupRules()
  #expect(report.isSafe() == false)
  #expect(report.isSafe(dampen: true) == true)

  report = Report(levels: [1, 2, 6])
  report.setupRules()
  #expect(report.isSafe() == false)
  #expect(report.isSafe(dampen: true) == true)
}

// MARK: - Difficult edge cases

@Test
func testEdgeCaseTrickyDifferences() {
  var report = Report(levels: [1, 2, 3, 9])
  report.setupRules()
  #expect(report.isSafe() == false)
  #expect(report.isSafe(dampen: true) == true)
}

// MARK: - Tests that confirm sequences that appear close to fixable but are not

@Test
func testAlmostFixableButNot() {
  var report = Report(levels: [1, 3, 10, 9])
  report.setupRules()
  #expect(report.isSafe() == false)
  #expect(report.isSafe(dampen: true) == false)
}

@Test
func testConsecutiveDuplicatesAtEndFixable() {
  var report = Report(levels: [67, 68, 70, 72, 74, 77, 79, 79])
  report.setupRules()
  #expect(report.isSafe() == false)
  #expect(report.isSafe(dampen: true) == true)
}

@Test
func testDecreasingAtEndWithLargeJumps() {
  var report = Report(levels: [1, 34, 36, 38, 40, 43, 46, 44])
  report.setupRules()
  #expect(report.isSafe() == false)
  #expect(report.isSafe(dampen: true) == false)
}

@Test
func testMultipleDuplicates() {
  var report = Report(levels: [6, 4, 4, 6, 8, 8])
  report.setupRules()
  #expect(report.isSafe() == false)
  #expect(report.isSafe(dampen: true) == false)
}

@Test
func testMiddleDuplicatesFixable() {
  var report = Report(levels: [13, 15, 18, 19, 19, 21, 22, 26])
  report.setupRules()
  #expect(report.isSafe() == false)
  #expect(report.isSafe(dampen: true) == false)
}

@Test
func testComplexTrendAndDuplicates() {
  var report = Report(levels: [80, 79, 81, 81, 83, 84, 83])
  report.setupRules()
  #expect(report.isSafe() == false)
  #expect(report.isSafe(dampen: true) == false)
}

@Test
func testClearlySafeDecreasing() {
  var report = Report(levels: [95, 93, 91, 88, 87, 85, 84])
  report.setupRules()
  #expect(report.isSafe() == true)
  #expect(report.isSafe(dampen: true) == true)
}

@Test
func testClearlySafeIncreasing() {
  var report = Report(levels: [3, 5, 6, 8, 11, 13, 14, 17])
  report.setupRules()
  #expect(report.isSafe() == true)
  #expect(report.isSafe(dampen: true) == true)
}

@Test
func testLongDecreasingAllWithinRange() {
  var report = Report(levels: [50, 48, 45, 42, 40, 38, 35])
  report.setupRules()
  #expect(report.isSafe() == true)
  #expect(report.isSafe(dampen: true) == true)
}

@Test
func testShortSequenceDecreasing() {
  var report = Report(levels: [17, 14, 11, 8, 6])
  report.setupRules()
  #expect(report.isSafe() == true)
}

@Test
func testShortSequenceIncreasing() {
  var report = Report(levels: [61, 64, 66, 69, 71])
  report.setupRules()
  #expect(report.isSafe() == true)
}

@Test
func testSlightlyLongerIncreasing() {
  var report = Report(levels: [34, 37, 39, 42, 45, 46, 49])
  report.setupRules()
  #expect(report.isSafe() == true)
}

@Test
func testNearlyAllDecreasingNoFixNeeded() {
  var report = Report(levels: [86, 83, 81, 80, 79, 78])
  report.setupRules()
  #expect(report.isSafe() == true)
}

@Test
func testEdgeCaseWithCloseIncrements() {
  var report = Report(levels: [20, 21, 22, 23, 25, 26, 28, 30])
  report.setupRules()
  #expect(report.isSafe() == true)
}

@Test
func testComplexDecreasingNoIssues() {
  var report = Report(levels: [12, 9, 7, 4, 1])
  report.setupRules()
  #expect(report.isSafe() == true)
}
