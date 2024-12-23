//
//  barcodeReaderApp.swift
//  barcodeReader
//
//  Created by Oscar Hooman on 11/16/24.
//

import SwiftUI
import SwiftData

//@main
//struct barcodeReaderApp: App {
//    var sharedModelContainer: ModelContainer = {
//        let schema = Schema([
//            Item.self,
//        ])
//        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
//
//        do {
//            return try ModelContainer(for: schema, configurations: [modelConfiguration])
//        } catch {
//            fatalError("Could not create ModelContainer: \(error)")
//        }
//    }()
//
//    var body: some Scene {
//        WindowGroup {
//            ContentView()
//        }
//        .modelContainer(sharedModelContainer)
//    }
//}

@main
struct BarcodeScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
//            CameraPermissionView()
        }
    }
}
