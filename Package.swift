// swift-tools-version:4.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "hangman",
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
  .executable(name: "research", targets: ["Research"]),
    .executable(name: "play", targets: ["Play"]),
    .library(name: "BoardGames", targets: ["Games"])
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
      .package(url: "https://github.com/jakeheis/SwiftCLI", from: "5.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
      .target(
        name: "Play",
        dependencies: ["Games", "SwiftCLI"]),
      .target(
        name: "Research",
        dependencies: ["Games", "SwiftCLI"]),
        .target(
            name: "Games",
            dependencies: ["Utility"]),
        .target(
          name: "Utility",
          dependencies: []),
        .testTarget(
          name: "GamesTests",
          dependencies: ["Games"]),
        .testTarget(
            name: "UtilityTests",
            dependencies: ["Utility"])
    ]
)
