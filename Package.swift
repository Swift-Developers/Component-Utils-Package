// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Utils",
    platforms: [.iOS(.v10)],
    products: [
        // Products define the executables and libraries produced by a package, and make them visible to other packages.
        .library(
            name: "Utils",
            targets: [
                "Utils",
                "Utils-Tools",
                "Utils-Cache"
            ]
        ),
        .library(
            name: "Utils-Tools",
            targets: ["Utils-Tools"]
        ),
        .library(
            name: "Utils-Cache",
            targets: ["Utils-Cache"]
        )
    ],
    dependencies: [
<<<<<<< HEAD
        // Dependencies declare other packages that this package depends on.
         .package(url: "https://github.com/saoudrizwan/Disk.git", from: "0.6.4")
=======
        .package(name: "Disk", url: "https://csummer.coding.net/p/swift-developers/d/Disk/git", from: "0.6.4")
>>>>>>> 488c6d3125f9c00e229527adbc803e2cf68dc705
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "Utils",
<<<<<<< HEAD
            dependencies: ["Disk"]),
=======
            dependencies: [
                "Utils-Tools",
                "Utils-Cache"
            ],
            path: "Sources",
            sources: ["Utils"]
        ),
        .target(
            name: "Utils-Tools",
            path: "Sources",
            sources: ["Tools"]
        ),
        .target(
            name: "Utils-Cache",
            path: "Sources",
            sources: ["Cache"]
        ),
>>>>>>> 488c6d3125f9c00e229527adbc803e2cf68dc705
        .testTarget(
            name: "UtilsTests",
            dependencies: ["Utils"]),
    ],
    swiftLanguageVersions: [.v5]
)
