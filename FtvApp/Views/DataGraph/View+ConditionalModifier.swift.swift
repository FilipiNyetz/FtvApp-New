//
//  View+ConditionalModifier.swift
//  FtvApp
//
//  Created by Joao pedro Leonel on 19/08/25.
//
import SwiftUI

extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
