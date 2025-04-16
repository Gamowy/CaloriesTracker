//
//  AddMealView.swift
//  CaloriesCalc
//
//  Created by RMS on 25/03/2025.
//

import SwiftUI

struct AddMealView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var meals: [Meal]
    @State var newMeal : Meal
    @State var mealName : String = ""
    @State var mealType: MealType = MealType.breakfast
    @State var isButtonDisabled: Bool = true
    @State var isEditing : Bool = false
    @State var editMealId : ObjectIdentifier? = nil
    @State var showError : Bool = false

    var body: some View {
        if (isEditing) {
            Text("Edit meal").bold()
        }
        else {
            Text("Add new meal").bold()
        }
        Form {
            Section {
                DatePicker("Date:", selection: $newMeal.date, in: ...Date())
            }
            Section {
                HStack {
                    Text("Meal:")
                    TextField("Name", text: $mealName)
                        .onChange(of: mealName) {
                            if (mealName != "") {
                                isButtonDisabled = false
                            }
                            else {
                                isButtonDisabled = true
                            }
                        }
                }
            }
            Section {
                Picker("Meal type:", selection: $mealType) {
                    ForEach(MealType.allCases, id: \.self) {
                        mealType in Text(mealType.rawValue).tag(mealType)
                    }
                }.pickerStyle(MenuPickerStyle())
            }
            Section {
                HStack {
                    Text("Calories:")
                    TextField("Enter number", value: $newMeal.calories, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
            }
            Section {
                HStack {
                    Text("Proteins:")
                    TextField("Enter number", value: $newMeal.proteins, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
            }
            Section {
                HStack {
                    Text("Carbs:")
                    TextField("Enter number", value: $newMeal.carbs, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
            }
            Section {
                HStack {
                    Text("Fats:")
                    TextField("Enter number", value: $newMeal.fats, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                }
            }
            if (isEditing) {
                Button(action: EditMeal) {
                    Text("Edit meal").frame(maxWidth: .infinity, alignment: .center)
                }.disabled(isButtonDisabled)
            }
            else {
                Button(action: AddMeal) {
                    Text("Add meal").frame(maxWidth: .infinity, alignment: .center)
                }.disabled(isButtonDisabled)
            }
        }
        .sheet(isPresented: $showError) {
            // Your custom view inside the sheet
            VStack {
                Text("Values can't be negative!")
                Button("Dismiss") {
                    showError = false
                }
            }
        }
    }
    
    
    func AddMeal()
    {
        if (newMeal.calories >= 0)
        {
            CorrectValues()
            newMeal.name = mealName
            newMeal.mealType = mealType
            meals.append(newMeal)
            saveDataToStorage()
            presentationMode.wrappedValue.dismiss()
        }
        else {
            showError = true
        }
    }
    
    func EditMeal() {
        if (newMeal.calories >= 0) {
            CorrectValues()
            newMeal.name = mealName
            newMeal.mealType = mealType
            for i in 0...meals.count {
                if meals[i].id == editMealId {
                    meals[i] = newMeal
                    break
                }
            }
            saveDataToStorage()
            presentationMode.wrappedValue.dismiss()
        }
        else {
            showError = true
        }
    }
    
    func CorrectValues() {
        newMeal.proteins = max(newMeal.proteins ?? 0, 0)
        newMeal.carbs = max(newMeal.carbs ?? 0, 0)
        newMeal.fats = max(newMeal.fats ?? 0, 0)
    }
    
    func saveDataToStorage() {
        if let data = try? PropertyListEncoder().encode(meals) {
            UserDefaults.standard.set(data, forKey: "meals")
        }
    }
}
                               
#Preview {
    @Previewable @State var meals : [Meal] = []
    AddMealView(meals: $meals, newMeal: Meal(date: Date()))
}
