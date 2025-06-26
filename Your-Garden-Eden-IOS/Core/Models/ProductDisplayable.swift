//
//  ProductDisplayable.swift
//  Your-Garden-Eden-IOS
//
//  Created by Josef Ewert on 24.06.25.
//


// DATEI: SharedProtocols.swift
// PFAD: Models/Protocols/SharedProtocols.swift

import Foundation
import SwiftUI

public protocol ProductDisplayable {
    var displayId: Int { get }
    var displayName: String { get }
    var displayImageURL: URL? { get }
    var displayPrice: String { get }
    var displayStrikethroughPrice: String? { get }
}