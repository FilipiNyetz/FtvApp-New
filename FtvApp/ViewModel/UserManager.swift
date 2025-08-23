//
//  UserViewModel.swift
//  FtvApp
//
//  Created by Filipi Romão on 23/08/25.
//

import Foundation
import SwiftUI

class UserManager: ObservableObject{
    
    @AppStorage("countWorkouts") var countWorkouts: Int = 0
    @AppStorage("currentStreak") var streakWorkouts: Int = 0
    
    
}
