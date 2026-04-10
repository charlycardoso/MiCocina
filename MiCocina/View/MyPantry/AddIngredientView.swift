//
//  AddIngredientView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 10/04/26.
//

import SwiftUI
import SwiftData
import VisionKit

struct AddIngredientView: View {
    @ObservedObject private var viewModel: MyPantryModuleViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var quantity: Int = 1
    @State private var showAlert: (show: Bool, title: String, message: String) = (false, "", "")
    @State private var showBarcodeScanner = false
    @State private var isLoadingProduct = false
    @State private var shouldDismissOnOK = false

    init(viewModel: MyPantryModuleViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Button {
                        showBarcodeScanner = true
                    } label: {
                        Label("addIngredient.scanBarcode", systemImage: "barcode.viewfinder")
                    }
                    .disabled(!DataScannerViewController.isSupported || !DataScannerViewController.isAvailable)
                }

                if isLoadingProduct {
                    Section {
                        HStack(spacing: 12) {
                            ProgressView()
                            Text("addIngredient.searchingProduct")
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    TextField("common.ingredient.namePlaceholder", text: $name)
                        .textFieldStyle(.plain)

                    Stepper(value: $quantity, in: 1...999) {
                        HStack {
                            Text("common.quantity")
                            Spacer()
                            Text("\(quantity)")
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("common.details")
                } footer: {
                    Text("addIngredient.footer")
                }
            }
            .navigationTitle("addIngredient.navigationTitle")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("common.cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("common.save") {
                        saveIngredient()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert(
                showAlert.title,
                isPresented: $showAlert.show
            ) {
                Button("common.ok") {
                    if shouldDismissOnOK {
                        dismiss()
                    }
                }
            } message: {
                Text(showAlert.message)
            }
        }
        .sheet(isPresented: $showBarcodeScanner) {
            BarcodeScannerView { barcode in
                fetchProduct(barcode: barcode)
            }
        }
    }

    private func fetchProduct(barcode: String) {
        Task {
            defer { isLoadingProduct = false }
            isLoadingProduct = true
            let urlString = "https://world.openfoodfacts.org/api/v0/product/\(barcode).json"
            guard let url = URL(string: urlString) else { return }
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let status = json["status"] as? Int, status == 1,
                   let product = json["product"] as? [String: Any],
                   let productName = (product["product_name"] as? String)?.trimmingCharacters(in: .whitespacesAndNewlines),
                   !productName.isEmpty {
                    name = productName
                } else {
                    shouldDismissOnOK = false
                    showAlert = (
                        true,
                        String(localized: "addIngredient.productNotFound.title"),
                        String(localized: "addIngredient.productNotFound.message")
                    )
                }
            } catch {
                shouldDismissOnOK = false
                showAlert = (true, String(localized: "common.error"), String(localized: "addIngredient.fetchError"))
            }
        }
    }

    private func saveIngredient() {
        let trimmedName = name.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedName.isEmpty else {
            shouldDismissOnOK = false
            showAlert = (true, String(localized: "common.error"), String(localized: "common.ingredient.emptyNameError"))
            return
        }

        let newIngredient = Ingredient(name: trimmedName, quantity: quantity)

        if viewModel.exists(newIngredient) {
            shouldDismissOnOK = false
            showAlert = (
                true,
                String(localized: "common.ingredient.duplicateTitle"),
                String(localized: "addIngredient.duplicate.message")
            )
            return
        }

        do {
            try viewModel.add(newIngredient)
            shouldDismissOnOK = true
            showAlert = (
                true,
                String(localized: "addIngredient.success.title"),
                String(localized: "addIngredient.success.message")
            )
        } catch {
            shouldDismissOnOK = false
            showAlert = (true, String(localized: "common.error"), String(localized: "addIngredient.saveError"))
        }
    }
}

#Preview {
    let schema = Schema([
        Item.self,
        SDRecipe.self,
        SDIngredient.self,
        SDRecipeIngredient.self,
    ])
    let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [config])

    let mockVM = MyPantryModuleViewModel.mockForPreview(context: container.mainContext)

    return AddIngredientView(viewModel: mockVM)
        .modelContainer(container)
}
