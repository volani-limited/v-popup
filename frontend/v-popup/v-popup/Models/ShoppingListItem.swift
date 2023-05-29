//
//  ShoppingListItem.swift
//  v-popup
//
//  Created by Oliver Bevan on 25/05/2023.
//

import Foundation

struct ShoppingListItem: Identifiable, Codable {
    var id = UUID()
    var title: String
    
    enum CodingKeys: CodingKey {
        case id
        case title
    }
}
