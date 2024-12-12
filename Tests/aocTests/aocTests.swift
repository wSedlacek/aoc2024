import Foundation
import Testing

@testable import aoc

func readFile(fileName: String) throws -> String {
  let fileURL = URL(fileURLWithPath: fileName)
  let input = try String(contentsOf: fileURL, encoding: .utf8)
  return input
}

// Input is 2 list of location ids left by the Chief Historian
// It is loaded from a file. The file contains only numbers sperated by spaces and new lines
// Each column represents a list of location ids

// For the pair of list we need to "reconcile" them.
// The order the of the location ids is insignificant (for now)
// The goal is to pair up numbers from each list by the value of the numbers (smallest to largest)

// 3   4
// 4   3
// 2   5
// 1   3
// 3   9
// 3   3

// Pairs are:
// (1, 3), (2, 3), (3, 3), (3, 4), (3, 5), (4, 9)

// For the pairs we find the distance between the two numbers
// (1, 3) distance is 2
// (2, 3) distance is 1
// (3, 3) distance is 0
// (3, 4) distance is 1
// (3, 5) distance is 2
// (4, 9) distance is 5

// Then add the distances together
// 2 + 1 + 0 + 1 + 2 + 5 = 11

// The answer is the sum of the distances

@Test func samplePart1() async throws {
  let input = try readFile(fileName: "sample.txt")
  let answer = aoc.part1(input: input)
  #expect(answer == 11)
}

@Test func puzzlePart1() async throws {
  let input = try readFile(fileName: "puzzle.txt")
  let answer = aoc.part1(input: input)
  #expect(answer == 2_164_381)
}

// Oh no, these inputs are way too different!
// Let's figure out HOW different they are

// Given the same input calculate a similarity score
// This is done by counting how many times each number
// in the left list appears in the right list, then
// multiplying each number in the left list by the
// the count and adding all the results together.

// For example, given the following lists:
// 3   4
// 4   3
// 2   5
// 1   3
// 3   9
// 3   3

// 3 apepars 3 times
// 4 apepars 1 time
// 2 apepars 0 times
// 1 apepars 0 times
// 3 apepars 3 times
// 3 apepars 3 times

// (3 * 3) + (4 * 1) + (2 * 0) + (1 * 0) + (3 * 3) + (3 * 3)
// 9 + 1 + 0 + 0 + 9 + 9
// 31

@Test func samplePart2() async throws {
  let input = try readFile(fileName: "sample.txt")
  let answer = aoc.part2(input: input)
  #expect(answer == 31)
}

@Test func puzzlePart2() async throws {
  let input = try readFile(fileName: "puzzle.txt")
  let answer = aoc.part2(input: input)
  #expect(answer == 20_719_933)
}
