//
//  WoW_AIApp.swift
//  WoW AI
//
//  Created by Abhinav Kompella on 4/18/24.
//

import SwiftUI

@main
struct WoW_AIApp: App {
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            MainScreen()
                .preferredColorScheme(.light)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
