//
//  BarcodeScannerView.swift
//  MiCocina
//
//  Created by Carlos Cardoso on 10/04/26.
//

import SwiftUI
import VisionKit

struct BarcodeScannerView: UIViewControllerRepresentable {
    let onScan: (String) -> Void
    @Environment(\.dismiss) private var dismiss

    func makeCoordinator() -> Coordinator {
        Coordinator(onScan: onScan, dismiss: dismiss)
    }

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let scanner = DataScannerViewController(
            recognizedDataTypes: [.barcode()],
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighlightingEnabled: true
        )
        scanner.delegate = context.coordinator
        return scanner
    }

    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // Start scanning once the view controller is in the hierarchy
        guard !context.coordinator.isScanning else { return }
        context.coordinator.isScanning = true
        try? uiViewController.startScanning()
    }

    @MainActor
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        private let onScan: (String) -> Void
        private let dismiss: DismissAction
        var isScanning = false
        private var hasScanned = false

        init(onScan: @escaping (String) -> Void, dismiss: DismissAction) {
            self.onScan = onScan
            self.dismiss = dismiss
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd newItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard !hasScanned, let item = newItems.first else { return }
            if case .barcode(let barcode) = item, let payload = barcode.payloadStringValue {
                hasScanned = true
                onScan(payload)
                dismiss()
            }
        }
    }
}
