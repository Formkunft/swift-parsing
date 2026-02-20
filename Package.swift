// swift-tools-version: 6.2
import PackageDescription

let package = Package(
	name: "swift-parsing",
	platforms: [.macOS(.v10_15)],
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
	],
)
