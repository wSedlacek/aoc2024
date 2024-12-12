import Foundation
import Testing

@testable import aoc

// MARK: - Rule-Specific Tests
@Test
func testDifferenceRuleValid() {
  let rule = DifferenceRule()
  #expect(rule.evaluate(current: 2, previous: 1) == true)  // diff=1 OK
}

@Test
func testDifferenceRuleTooLarge() {
  let rule = DifferenceRule()
  #expect(rule.evaluate(current: 5, previous: 1) == false)  // diff=4 too large
}

@Test
func testDifferenceRuleTooSmall() {
  let rule = DifferenceRule()
  #expect(rule.evaluate(current: 1, previous: 1) == false)  // diff=0 too small
}

@Test
func testTrendRuleIncreasing() {
  let rule = TrendRule()
  #expect(rule.evaluate(current: 1, previous: nil) == true)  // Start trend
  #expect(rule.evaluate(current: 2, previous: 1) == true)  // Increasing OK
}

@Test
func testTrendRuleBreaksIncreasing() {
  let rule = TrendRule()
  #expect(rule.evaluate(current: 3, previous: 2) == true)
  #expect(rule.evaluate(current: 2, previous: 3) == false)  // Breaks trend
}

@Test
func testTrendRuleDecreasing() {
  let rule = TrendRule()
  #expect(rule.evaluate(current: 5, previous: nil) == true)  // Start trend
  #expect(rule.evaluate(current: 4, previous: 5) == true)  // Decreasing OK
}

@Test
func testTrendRuleBreaksDecreasing() {
  let rule = TrendRule()
  #expect(rule.evaluate(current: 3, previous: 4) == true)
  #expect(rule.evaluate(current: 5, previous: 3) == false)  // Breaks trend
}

// MARK: - Safe and Unsafe Reports
@Test
func testKnownSafeReportDecreasing() {
  let report = Report(levels: [7, 6, 4, 2, 1])  // Decreasing, differences OK
  #expect(report.isSafe() == true)
}

@Test
func testKnownSafeReportIncreasing() {
  let report = Report(levels: [1, 3, 6, 7, 9])  // Increasing, differences OK
  #expect(report.isSafe() == true)
}

@Test
func testKnownUnsafeReportLargeDifference() {
  let report = Report(levels: [1, 2, 7, 8, 9])  // Large difference (2 -> 7 = 5)
  #expect(report.isSafe() == false)
}

@Test
func testKnownUnsafeReportTrendBreak() {
  let report = Report(levels: [1, 3, 2, 4, 5])  // Trend break (3 -> 2)
  #expect(report.isSafe() == false)
}

// MARK: - Fixable Reports with Dampener
@Test
func testFixableReportTrendBreak() {
  let report = Report(levels: [1, 3, 2, 4, 5])  // Removing 3 fixes the trend
  #expect(report.isSafe(dampen: true) == true)
}

@Test
func testFixableReportDuplicateDifference() {
  let report = Report(levels: [8, 6, 4, 4, 1])  // Removing 4 fixes differences
  #expect(report.isSafe(dampen: true) == true)
}

@Test
func testUnfixableReportLargeDifference() {
  let report = Report(levels: [1, 34, 36, 38, 40, 43, 46, 44])  // Too large difference (1 -> 34)
  #expect(report.isSafe(dampen: true) == false)
}

@Test
func testUnfixableReportDuplicateDifferences() {
  let report = Report(levels: [6, 4, 4, 6, 8, 8])  // Duplicate differences
  #expect(report.isSafe(dampen: true) == false)
}

// MARK: - Part Tests

func readFile(fileName: String) throws -> String {
  let fileURL = URL(fileURLWithPath: fileName)
  return try String(contentsOf: fileURL, encoding: .utf8)
}

@Test
func testSamplePart1() async throws {
  let input = try readFile(fileName: "sample.txt")
  let answer = aoc.part1(input)
  #expect(answer == 2)
}

@Test
func testSamplePart2() async throws {
  let input = try readFile(fileName: "sample.txt")
  let answer = aoc.part2(input)
  #expect(answer == 4)
}

@Test
func testPuzzlePart1() async throws {
  let input = try readFile(fileName: "puzzle.txt")
  let answer = aoc.part1(input)
  #expect(answer == 624)
}

@Test
func testPuzzlePart2() async throws {
  let input = try readFile(fileName: "puzzle.txt")
  let answer = aoc.part2(input)
  #expect(answer == 658)
}
