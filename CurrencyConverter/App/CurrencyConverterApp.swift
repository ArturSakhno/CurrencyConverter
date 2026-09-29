//
//  CurrencyConverterApp.swift
//  CurrencyConverter
//
//  Created by Artur Sakhno on 27/09/2026.
//

import SwiftUI

@main
struct CurrencyConverterApp: App {
    private let dependencies = DependencyContainer()

    var body: some Scene {
        WindowGroup {
            RootView(dependencies: dependencies)
        }
    }
}
