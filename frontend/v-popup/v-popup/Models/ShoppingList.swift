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
    var sharedWith: String
    var title: String
    var items: [ShoppingListItem]
    
    enum CodingKeys: String, CodingKey {
        case id
        case created
        case owner
        case title
        case items
        case sharedWith
    }
    
}
