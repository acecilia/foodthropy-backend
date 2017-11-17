// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "foodthropy-backend",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/vapor/fluent-provider.git", .upToNextMajor(from: "1.2.0")),
        .package(url: "https://github.com/vapor/postgresql-provider", .upToNextMajor(from: "2.1.0")),
        .package(url: "https://github.com/nodes-vapor/paginator", .upToNextMajor(from: "1.1.3"))
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentProvider", "PostgreSQLProvider", "Paginator"],
                exclude: [
                    "Config",
                    "Database",
                    "Localization",
                    "Public",
                    "Resources"
                ]),
        .target(name: "Run", dependencies: ["App"])
    ]
)

