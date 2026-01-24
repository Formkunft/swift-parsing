// swift-tools-version: 6.2
import PackageDescription

let package = Package(
	name: "swift-parsing",
	platforms: [.macOS(.v10_15)],
	products: [
		.library(
			name: "Parsing",
			targets: ["Parsing"]),
	],
	targets: [
		.target(
			name: "Parsing",
			swiftSettings: [
				.strictMemorySafety(),
				.enableExperimentalFeature("Lifetimes"),
			]),
	],
)
