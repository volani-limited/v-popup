//
//  ShoppingList.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import Foundation
import FirebaseFirestoreSwift

struct ShoppingList: Codable {
    @DocumentID var id: String?
    @ServerTimestamp var created: Date?
    
    var owner: String
    var items: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case created
        case owner
        case items
    }
    
}
