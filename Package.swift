// swift-tools-version: 6.3
import PackageDescription

let package = Package(
	name: "swift-parsing",
	platforms: [.macOS(.v10_15), .iOS(.v13), .tvOS(.v13), .watchOS(.v6)],
	products: [
		.library(
			name: "CollectionParsing",
			targets: ["CollectionParsing"]),
		.library(
			name: "SpanParsing",
			targets: ["SpanParsing"]),
	],
	targets: [
		.target(
			name: "CollectionParsing",
			swiftSettings: [
				.strictMemorySafety(),
			]),
		.target(
			name: "SpanParsing",
			swiftSettings: [
				.strictMemorySafety(),
				.enableExperimentalFeature("Lifetimes"),
			]),
		.testTarget(
			name: "CollectionParsingTests",
			dependencies: ["CollectionParsing"]),
		.testTarget(
			name: "SpanParsingTests",
			dependencies: ["SpanParsing"],
			swiftSettings: [
				.enableExperimentalFeature("Lifetimes"),
			]),
	],
)
