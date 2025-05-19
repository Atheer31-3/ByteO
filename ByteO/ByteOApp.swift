//
//  testcipherApp.swift
//  testcipher
//
//  Created by atheer alshareef on 19/05/2025.
//

import SwiftUI

@main
struct ByteOApp: App {
    var body: some Scene {
        WindowGroup {
            MainMenuView()
                .environment(GameDataStore.shared) // ✅ إضافة المتغير للبيئة
        }
    }
}
