// swift-tools-version:5.0

import PackageDescription

let package = Package(
  name: "EnumProperties",
  products: [
    .executable(
      name: "generate-enum-properties",
      targets: ["generate-enum-properties"]),
    .library(
      name: "EnumProperties",
      targets: ["EnumProperties"]),
  ],
  dependencies: [
    .package(url: "https://github.com/apple/swift-syntax.git", .exact("0.50100.0")),
    .package(url: "https://github.com/apple/swift-argument-parser", from: "0.0.1"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.7.1"),
  ],
  targets: [
    .target(
      name: "generate-enum-properties",
      dependencies: ["EnumProperties", "SwiftSyntax", "ArgumentParser"]),
    .target(
      name: "EnumProperties",
      dependencies: ["SwiftSyntax"]),
    .testTarget(
      name: "EnumPropertiesTests",
      dependencies: ["EnumProperties", "SnapshotTesting"]),
  ]
)
