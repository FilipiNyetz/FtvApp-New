//
//  ShareSheet.swift
//  FtvApp
//
//  Created by Gustavo Souto Pereira on 21/08/25.
//

import SwiftUI

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}
