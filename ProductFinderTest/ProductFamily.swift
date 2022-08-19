//
//  ProductFamily.swift
//  ProductFinderTest
//
//  Created by Joseph Grasso on 8/1/22.
//

import CoreData
import SwiftUI

class ProductFamily: NSManagedObject {

    @NSManaged var code          : String
    @NSManaged var productFamily : String
    @NSManaged var partNumbers   : Set<PartNumber>

    func update(from productFamilyProperties: ProductFamilyProperties) throws {
        
        let dictionary = productFamilyProperties.dictionaryValue
        guard let newCode = dictionary["code"] as? String,
              let newProductFamily = dictionary["productFamily"] as? String
        else {
            throw myError.programError("Missing Data")
        }
        code = newCode
        productFamily = newProductFamily
    }
}

extension ProductFamily: Identifiable {

    static var preview: ProductFamily {
        let productFamilies = ProductFamily.makePreviews(count: 1)
        return productFamilies[0]
    }

    @discardableResult
    static func makePreviews(count: Int) -> [ProductFamily] {
        var productFamilies = [ProductFamily]()
        let viewContext = ProductProvider.preview.container.viewContext
        for _ in 0..<count {
            let productFamily = ProductFamily(context: viewContext)
            productFamily.code = UUID().uuidString
            productFamily.productFamily = "Product Family 1"
            productFamilies.append(productFamily)
        }
        return productFamilies
    }
}

struct ProductFamilyJSON: Decodable {
    
    private(set) var productFamilies = [ProductFamilyProperties]()
    
    init(from decoder: Decoder) throws {
        var rootContainer = try decoder.unkeyedContainer()
        
        while !rootContainer.isAtEnd {
            if let properties = try? rootContainer.decode(ProductFamilyProperties.self) {
                productFamilies.append(properties)
            }
        }
    }
}

struct ProductFamilyProperties : Decodable {
    
    enum CodingKeys: String, CodingKey {
        case code
        case productFamily
    }
    let code : String
    let productFamily : String
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let rawCode = try? values.decode(String.self, forKey: .code)
        let rawProductFamily = try? values.decode(String.self, forKey: .productFamily)
    
        guard let code = rawCode,
              let productFamily = rawProductFamily
        else {
            throw myError.programError("Missing Data")
            
        }
        self.code = code
        self.productFamily = productFamily
    }
    var dictionaryValue: [String: Any] {
        [
            "code": code,
            "productFamily": productFamily
        ]
    }
}

