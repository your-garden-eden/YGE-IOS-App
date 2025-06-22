//
//  GuestTokenResponse.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 22.06.25.
//


// DATEI: GuestTokenResponse.swift
// PFAD: Models/User/UserAPIModels.swift
// VERSION: STABILER START 1.0
// STATUS: NEU

import Foundation

/// Dekodiert die Antwort vom `/guest-token`-Endpunkt.
/// Enthält ausschließlich das Token selbst.
struct GuestTokenResponse: Decodable {
    let token: String
}