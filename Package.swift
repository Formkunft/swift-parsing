// swift-tools-version: 6.2
import PackageDescription

let package = Package(
	name: "swift-parsing",
	platforms: [.macOS(.v10_15)],
	products: [
		.library(
		.library(
			name: "SpanParsing",
			targets: ["SpanParsing"]),
	],
	targets: [
		.target(
			name: "SpanParsing",
			swiftSettings: [
				.strictMemorySafety(),
				.enableExperimentalFeature("Lifetimes"),
			]),
	],
)
