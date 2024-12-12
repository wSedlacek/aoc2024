// MARK: - Core Struct
struct LocationList {
  var locationIDs: [Int]

  static func pair(input: String) throws(ParsingError) -> (LocationList, LocationList) {
    let lines = input.split(separator: "\n")
    var list1: [Int] = []
    var list2: [Int] = []

    for line in lines {
      let columns = line.split(separator: " ")

      guard columns.count == 2,
        let column1 = Int(columns[0]),
        let column2 = Int(columns[1])
      else {
        throw ParsingError.invalidInput
      }

      list1.append(column1)
      list2.append(column2)
    }

    return (LocationList(locationIDs: list1), LocationList(locationIDs: list2))
  }

  enum ParsingError: Error {
    case invalidInput
  }
}

// MARK: - Protocols
protocol Reconcilable {
  func reconcile(with other: LocationList) -> [(Int, Int)]
}

protocol DistanceCalculable {
  func distance(from other: LocationList) -> Int
}

protocol SimilarityCalculable {
  func similarity(with other: LocationList) -> Int
}

// MARK: - Default Implementations
extension LocationList: Reconcilable {
  func reconcile(with other: LocationList) -> [(Int, Int)] {
    let sortedSelf = locationIDs.sorted()
    let sortedOther = other.locationIDs.sorted()
    return zip(sortedSelf, sortedOther).map { ($0, $1) }
  }
}

extension LocationList: DistanceCalculable {
  func distance(from other: LocationList) -> Int {
    let pairs = reconcile(with: other)
    return pairs.reduce(0) { $0 + abs($1.0 - $1.1) }
  }
}

extension LocationList: SimilarityCalculable {
  func similarity(with other: LocationList) -> Int {
    let counts = Dictionary(other.locationIDs.map { ($0, 1) }, uniquingKeysWith: +)

    return locationIDs.reduce(0) { result, id in
      result + (id * (counts[id] ?? 0))
    }
  }
}

// MARK: - Main Functions
func part1(input: String) throws(LocationList.ParsingError) -> Int {
  let (list1, list2) = try LocationList.pair(input: input)
  return list1.distance(from: list2)
}

func part2(input: String) throws(LocationList.ParsingError) -> Int {
  let (list1, list2) = try LocationList.pair(input: input)
  return list1.similarity(with: list2)
}
