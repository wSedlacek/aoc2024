// swift-tools-version: 6.0

import PackageDescription

let package = Package(
  name: "aoc",
  products: [
    .library(
      name: "aoc",
      targets: ["aoc"])
  ],
  targets: [
    .target(
      name: "aoc"),
    .testTarget(
      name: "aocTests",
      dependencies: ["aoc"]
    ),
  ]
)
