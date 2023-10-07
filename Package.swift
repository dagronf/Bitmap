// swift-tools-version: 5.4

import PackageDescription

let package = Package(
	name: "Bitmap",
	platforms: [.macOS(.v10_11), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
	products: [
		.library(
			name: "Bitmap",
			targets: ["Bitmap"]),
	],
	dependencies: [
		.package(url: "https://github.com/dagronf/SwiftImageReadWrite", from: "1.1.3")
	],
	targets: [
		.target(
			name: "Bitmap",
			dependencies: ["SwiftImageReadWrite"]),
		.testTarget(
			name: "BitmapTests",
			dependencies: ["Bitmap"],
			resources: [ .process("resources") ]
		)
	]
)
