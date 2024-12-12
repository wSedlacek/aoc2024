func parseInput(input: String) -> ([Int], [Int]) {
  // There are two lists of location ids
  // Each list is a column in the input
  // Each column as two spaces separated numbers

  let lines = input.split(separator: "\n")
  var list1: [Int] = []
  var list2: [Int] = []

  for line in lines {
    let columns = line.split(separator: " ")
    let column1 = Int(columns[0])!
    let column2 = Int(columns[1])!

    list1.append(column1)
    list2.append(column2)
  }

  return (list1, list2)
}

func reconcileList(list1: [Int], list2: [Int]) -> [(Int, Int)] {
  let sortedList1 = list1.sorted()
  let sortedList2 = list2.sorted()

  var result: [(Int, Int)] = []
  for index in 0..<min(sortedList1.count, sortedList2.count) {
    result.append((sortedList1[index], sortedList2[index]))
  }

  return result
}

func distance(_ pair: (Int, Int)) -> Int {
  return abs(pair.0 - pair.1)
}

func sumDistances(pairs: [(Int, Int)]) -> Int {
  var result = 0
  for pair in pairs {
    result += distance(pair)
  }

  return result
}

func part1(input: String) -> Int {
  let (list1, list2) = parseInput(input: input)
  let pairs = reconcileList(list1: list1, list2: list2)
  let sum = sumDistances(pairs: pairs)

  return sum
}

func part2(input: String) -> Int {
  let (list1, list2) = parseInput(input: input)
  var similarity = 0

  for number in list1 {
    let count = list2.filter { $0 == number }.count
    similarity += number * count
  }

  return similarity
}
