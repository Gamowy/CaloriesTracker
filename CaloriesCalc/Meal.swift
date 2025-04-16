//
//  Item.swift
//  CaloriesCalc
//
//  Created by RMS on 11/03/2025.
//

import Foundation
import SwiftUI

enum MealType : String, Codable, CaseIterable{
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case supper = "Supper"
    case snack = "Snack"
}

class Meal : Identifiable, Codable {
    var date: Date
    var name: String = ""
    var mealType: MealType = MealType.breakfast
    var calories: Int = 100
    var proteins: Int? = nil
    var carbs: Int? = nil
    var fats: Int? = nil
    
    init(date: Date) {
        self.date = date
    }
    
    init(date: Date, name: String, mealType: MealType, calories: Int) {
        self.date = date
        self.name = name
        self.mealType = mealType
        self.calories = calories
    }
    
    func setNutritions(proteins: Int, carbs: Int, fats: Int) {
        self.proteins = proteins
        self.carbs = carbs
        self.fats = fats
    }
}
