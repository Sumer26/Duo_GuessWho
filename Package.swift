// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "FaceOffCore",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [.library(name: "FaceOffCore", targets: ["FaceOffCore"])],
    targets: [
        .target(name: "FaceOffCore"),
        .testTarget(name: "FaceOffCoreTests", dependencies: ["FaceOffCore"])
    ]
)
