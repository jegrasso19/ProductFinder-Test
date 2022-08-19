//
//  ContentView.swift
//  ProductFinderTest
//
//  Created by Joseph Grasso on 8/1/22.
//

import SwiftUI
import CoreData

enum myError: Error {
    case programError(String)
}

class Navigation: ObservableObject {
    @Published var selection : String? = nil
}

struct ContentView: View {
    
    @EnvironmentObject var navigation : Navigation
    
    var body: some View {
        NavigationView {
            VStack {
                InitialView(buttonText: "LOGIN")
            }
        }
        .environmentObject(navigation)
        .navigationViewStyle(StackNavigationViewStyle() )
    }
}
struct InitialView: View {
    
    @EnvironmentObject var productProvider : ProductProvider
    @State private var navigated   : Bool = false
    @State private var dataLoaded  : Bool = false
    @State private var dataCleared : Bool = false
    @State private var productFamilySelection : Set<String> = []
    @State private var partNumberSelection    : Set<String> = []
    
    var buttonText : String
    
    @FetchRequest(sortDescriptors: [SortDescriptor(\.productFamily, order: .forward)])
    private var productFamilies: FetchedResults<ProductFamily>
    @FetchRequest(sortDescriptors: [SortDescriptor(\.partNumber, order: .forward)])
    private var partNumbers: FetchedResults<PartNumber>
    
    var body: some View {
        
        Button(action: {
            self.navigated.toggle()
        }, label: {
            Text("\(buttonText)")
                .bold()
                .padding()
        })
        Button(action: {
            self.dataLoaded.toggle()
            Task {
                await self.fetchProductData()
            }
        }, label: {
            Text("LOAD DATA")
                .bold()
                .padding()
        })
        Button(action: {
            self.dataCleared.toggle()
            Task {
                productFamilySelection = Set(productFamilies.map { $0.code })
                partNumberSelection    = Set(partNumbers.map { $0.code })

                await deleteProductFamilies(for: productFamilySelection)
                await deletePartNumbers(for: partNumberSelection)
            }
        }, label: {
            Text("CLEAR DATA")
                .bold()
                .padding()
        })
        .navigationBarBackButtonHidden(true)
        NavigationLink(destination: ProductFamilyView(), isActive: $navigated ) {
            EmptyView()
        }
    }
    
    private func fetchProductData() async {

        do {
            try await productProvider.fetchProductData()
        } catch {
            print(myError.programError("Fetch Product Data Error"))
        }
    }
    private func deleteProductFamilies(for codes: Set<String>) async {

        do {
            let productFamiliesToDelete = productFamilies.filter { codes.contains($0.code) }
            try await productProvider.deleteProductFamilies(productFamiliesToDelete)
        } catch {
            print(myError.programError("Delete ProductFamily Error"))
        }
    }
    private func deletePartNumbers(for codes: Set<String>) async {

        do {
            let partNumbersToDelete = partNumbers.filter { codes.contains($0.code) }
            try await productProvider.deletePartNumbers(partNumbersToDelete)
        } catch {
            print(myError.programError("Delete PartNumber Error"))
        }
    }
}

struct ProductFamilyView: View { //This is my home view

    @FetchRequest(sortDescriptors: [SortDescriptor(\.productFamily, order: .forward)])
    var productFamilies : FetchedResults<ProductFamily>
    
    var body: some View {
        List {
            ForEach(productFamilies) { (productFamily) in
                ProductFamilyRow(productFamily: productFamily)
            }
        }
        .navigationTitle("Product Families")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
    }
}
struct ProductFamilyRow: View {
    
    @EnvironmentObject var navigation : Navigation
    @State var productFamily : ProductFamily

    var body: some View {
        NavigationLink(destination: PartNumberView(productFamily: productFamily), tag: productFamily.productFamily, selection: $navigation.selection) {
            Text("\(productFamily.productFamily)")
        }
        .isDetailLink(false)
    }
}
struct PartNumberView: View {

    @State var productFamily: ProductFamily
        
    var body: some View {
        
        let partNumbers = self.productFamily.partNumbers.sorted{ $0.code > $1.code }
        
        List {
            ForEach(partNumbers) { (partNumber) in
                NavigationLink(destination: PartNumberRow(partNumber: partNumber)) {
                    Text("\(partNumber.partNumber)")
                }
            }
        }
        .navigationTitle("\(productFamily.productFamily)")
        .navigationBarItems(trailing: HomeButtonView() )
    }
}
struct PartNumberRow: View {
    
    @State var partNumber : PartNumber
    
    var body: some View {
        List {
            Text("Description: \(partNumber.pnDescription)")
        }
        .navigationTitle("\(partNumber.partNumber)")
        .navigationBarItems(trailing: HomeButtonView() )
    }
}

struct HomeButtonView: View {
    
    @EnvironmentObject var navigation : Navigation
    
    var body: some View {
        
        Button(action: {
            self.navigation.selection = nil
        }, label: {
            Image(systemName: "house")
        })
        .environmentObject(navigation)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(Navigation())
            .environmentObject(ProductProvider.shared)
    }
}
