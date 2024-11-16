//
//  ContentView.swift
//  barcodeReader
//
//  Created by Oscar Hooman on 11/16/24.
//

import SwiftUI
import SwiftData

struct ContentStandView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]

    var body: some View {
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
    CameraPermissionView()
        .modelContainer(for: Item.self, inMemory: true)
}



//struct NavigationView: View {
//
////  @State private var exercises: [Exercise] = Exercise.sample
////  @State private var path = NavigationPath()
////
////  var body: some View {
////    NavigationStack(path: $path) {
////      ExercisesList(exercises: exercises)
////        .navigationDestination(for: Exercise.self, destination: { exercise in
////          ExerciseDetail(exercise: exercise)
////        })
////    }
////  }
//}


struct ContentButtonView: View {
    @State private var viewModel = ViewModel()

    var body: some View {
        VStack {
            ClaimButton(configuration: viewModel.claimButtonConfiguration) {
                viewModel.claimCoupon()
            }
        }
        .padding()
    }
}

@Observable class ViewModel {
    var claimButtonConfiguration: ClaimButton.Configuration = .normal

    // Testing function
    func claimCoupon() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.claimButtonConfiguration = .loading
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.claimButtonConfiguration = .confirmed
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.claimButtonConfiguration = .disabled
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.claimButtonConfiguration = .normal
                    }
                }
            }
        }
    }
}
