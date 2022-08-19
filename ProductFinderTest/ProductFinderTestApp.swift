//
//  ProductFinderTestApp.swift
//  ProductFinderTest
//
//  Created by Joseph Grasso on 8/1/22.
//

import SwiftUI

@main
struct ProductFinderTestApp: App {
    
    @StateObject var navigate = Navigation()
    @StateObject var productProvider = ProductProvider.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(navigate)
                .environmentObject(ProductProvider.shared)
                .environment(\.managedObjectContext, productProvider.container.viewContext)
        }
    }
}
