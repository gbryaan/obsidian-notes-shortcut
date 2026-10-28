// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "NotaRapida",
    platforms: [.macOS(.v15)],
    targets: [
        .executableTarget(
            name: "NotaRapida",
            // App inteiro é UI (AppKit/SwiftUI): isolamento padrão no MainActor.
            swiftSettings: [.defaultIsolation(MainActor.self)]
        )
    ]
)
