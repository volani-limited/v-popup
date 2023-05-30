//
//  LocalUsser.swift
//  v-rowcoach
//
//  Created by Oliver Bevan on 22/02/2022.
//

import Foundation

import FirebaseFirestoreSwift

struct LocalUser: Identifiable, Codable {
    @DocumentID var id: String?
    @ServerTimestamp var created: Date?
    
    var email: String?
    var fcmRegistrations: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case created
        case email
        case fcmRegistrations
    }
}
