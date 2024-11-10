//
//  ContentView.swift
//  barcodeReader
//
//  Created by Oscar Hooman on 11/9/24.
//

import SwiftUI
import SwiftData
import AVFoundation

struct CameraView: UIViewControllerRepresentable {
    var onCodeScanned: (String) -> Void

    // Método requerido para crear el UIViewController
    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        let viewController = BarcodeScannerViewController()
        viewController.onCodeScanned = onCodeScanned
        return viewController
    }

    // Método requerido para actualizar el UIViewController
    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {
        // No se necesita actualización continua en este caso
    }
}

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    
    @State private var scannedCode: String?

    var body: some View {
        VStack {
            if let scannedCode = scannedCode {
                Text("Código escaneado: \(scannedCode)")
                    .font(.title)
                    .padding()
            } else {
                Text("Apunta la cámara a un código de barras")
                    .font(.headline)
                    .padding()
            }
            
            CameraView { code in
                scannedCode = code
            }
            .edgesIgnoringSafeArea(.all)
            .frame(height: 400)
        }
        NavigationSplitView {
            List {
                ForEach(items) { item in
                    NavigationLink {
                        Text("Item at \(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))")
                    } label: {
                        Text(item.timestamp, format: Date.FormatStyle(date: .numeric, time: .standard))
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addItem) {
                        Label("Add Item", systemImage: "plus")
                    }
                }
            }
        } detail: {
            Text("Select an item")
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
