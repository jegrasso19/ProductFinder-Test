//
//  PartNumber.swift
//  ProductFinderTest
//
//  Created by Joseph Grasso on 8/1/22.
//

import CoreData
import SwiftUI

class PartNumber: NSManagedObject {
    
    @NSManaged var code          : String
    @NSManaged var partNumber    : String
    @NSManaged var productFamily : String
    @NSManaged var orderable     : Bool
    @NSManaged var pnDescription : String
    @NSManaged var productLine   : ProductFamily
 
    func update(from partNumberProperties: PartNumberProperties) throws {
        
        let dictionary = partNumberProperties.dictionaryValue
        guard let newCode          = dictionary["code"] as? String,
              let newCienaPEC      = dictionary["partNumber"] as? String,
              let newProductFamily = dictionary["productFamily"] as? String,
              let newOrderable     = dictionary["orderable"] as? Bool,
              let newDescription   = dictionary["pnDescription"] as? String
        else {
            throw myError.programError("Missing Data")
        }
        code          = newCode
        partNumber    = newCienaPEC
        productFamily = newProductFamily
        orderable     = newOrderable
        pnDescription = newDescription
    }
}

extension PartNumber: Identifiable {

    static var preview: PartNumber {
        let partNumbers = PartNumber.makePreviews(count: 1)
        return partNumbers[0]
    }

    @discardableResult
    static func makePreviews(count: Int) -> [PartNumber] {
        var partNumbers = [PartNumber]()
        let viewContext = ProductProvider.preview.container.viewContext
        for _ in 0..<count {
            let partNumber = PartNumber(context: viewContext)
            partNumber.code          = UUID().uuidString
            partNumber.partNumber    = "100-2400-500"
            partNumber.productFamily = "Product Family 1"
            partNumber.orderable     = true
            partNumber.pnDescription = "100-2400-500 Part Number Description"
            
            partNumbers.append(partNumber)
        }
        return partNumbers
    }
}

struct PartNumberJSON: Decodable {
    
    private(set) var partNumbers = [PartNumberProperties]()
    
    init(from decoder: Decoder) throws {
        var rootContainer = try decoder.unkeyedContainer()
        
        while !rootContainer.isAtEnd {
            if let properties = try? rootContainer.decode(PartNumberProperties.self) {
                partNumbers.append(properties)
            }
        }
    }
}

struct PartNumberProperties : Decodable {
    
    enum CodingKeys: String, CodingKey {
        case code
        case partNumber
        case productFamily
        case orderable
        case pnDescription
    }
    let code          : String
    let partNumber    : String
    let productFamily : String
    let orderable     : Bool
    let pnDescription : String
    
    init(from decoder: Decoder) throws {
        let values           = try decoder.container(keyedBy: CodingKeys.self)
        let rawCode          = try? values.decode(String.self, forKey: .code)
        let rawCienaPEC      = try? values.decode(String.self, forKey: .partNumber)
        let rawProductFamily = try? values.decode(String.self, forKey: .productFamily)
        let rawOrderable     = try? values.decode(Bool.self, forKey: .orderable)
        let rawDescription   = try? values.decode(String.self, forKey: .pnDescription)
    
        guard let code          = rawCode,
              let partNumber    = rawCienaPEC,
              let productFamily = rawProductFamily,
              let orderable     = rawOrderable,
              let pnDescription = rawDescription
        else {
            throw myError.programError("Missing Data")
        }
        self.code          = code
        self.partNumber    = partNumber
        self.productFamily = productFamily
        self.orderable     = orderable
        self.pnDescription = pnDescription
    }
    var dictionaryValue: [String: Any] {
        [
            "code"          : code,
            "partNumber"    : partNumber,
            "productFamily" : productFamily,
            "orderable"     : orderable,
            "pnDescription" : pnDescription
        ]
    }
}
