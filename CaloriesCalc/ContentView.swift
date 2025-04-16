//
//  ContentView.swift
//  CaloriesCalc
//
//  Created by RMS on 11/03/2025.
//

import SwiftUI
import Foundation

struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    
    @State var meals: [Meal] = []
    
    @State var currentDate = Date()
    @State var showDatePicker = false
    @State var showAddMealView = false
    @State var isNextDayButtonDisabled = true
    
    init() {
        self.loadDataFromStorage()
        print(meals.count)
    }
    
    var body: some View {
            NavigationSplitView {
                List {
                    ForEach($meals) { $meal in
                        if Calendar.current.isDate(meal.date, inSameDayAs: currentDate) {
                            NavigationLink(destination: AddMealView(
                                meals: $meals,
                                newMeal: meal,
                                mealName: meal.name,
                                mealType: meal.mealType,
                                isButtonDisabled: false,
                                isEditing: true,
                                editMealId: $meal.id)) {
                                Text("\(meal.mealType.rawValue): \(meal.name) | \(meal.calories) kcal")
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: pickDate) {
                            Label("Pick date", systemImage: "calendar")
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EditButton()
                    }
                    ToolbarItem {
                        NavigationLink(destination: AddMealView(meals: $meals, newMeal: Meal(date: currentDate))) {
                            Label("Add meal", systemImage: "plus")
                        }
                    }
                    ToolbarItem(placement: .principal) {
                        VStack {
                            Text("Calories App").font(.headline)
                            Text(getFormattedDate())
                        }
                        
                    }
                }
                VStack {
                    let totalCaloriesForTargetDate = meals
                        .filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                        .reduce(0) { $0 + $1.calories }
                    let totalProteins = meals
                        .filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                        .compactMap { $0.proteins ?? 0 }
                        .reduce(0, +)
                    let totalCarbs = meals
                        .filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                        .compactMap { $0.carbs ?? 0 }
                        .reduce(0, +)
                    let totalFats = meals
                        .filter { Calendar.current.isDate($0.date, inSameDayAs: currentDate) }
                        .compactMap { $0.fats ?? 0 }
                        .reduce(0, +)
                    
                    Text("Total calories: \(totalCaloriesForTargetDate)").bold()
                    HStack {
                        Text("Proteins: \(totalProteins)").foregroundStyle(.green)
                        Text("Carbs: \(totalCarbs)").foregroundStyle(.blue)
                        Text("Fats: \(totalFats)").foregroundStyle(.yellow)
                    }
                }
                HStack(spacing: 200.0) {
                    Button("Previous", systemImage: "arrow.left", action: previousDay)
                        .labelStyle(.iconOnly)
                        .font(.system(size: 30))
                    
                    
                    Button("Next", systemImage: "arrow.right", action: nextDay)
                        .labelStyle(.iconOnly)
                        .font(.system(size: 30))
                        .disabled(isNextDayButtonDisabled)
                }.padding(20.0)
            } detail: {
                Text("Select an item")
            }
            
            .sheet(isPresented: $showDatePicker) {
                VStack {
                    Text("Pick a date")
                        .font(.headline)
                        .padding()
                    
                    DatePicker("Select a date", selection: $currentDate, in: ...Date(), displayedComponents: [.date]).datePickerStyle(GraphicalDatePickerStyle())
                    
                    Button("Done") {
                        showDatePicker.toggle()
                        checkNextButtonDisabledCondition()
                    }
                    .padding()
                }
                .padding()
            }
            .onAppear() {
                loadDataFromStorage()
            }
            .onChange(of: scenePhase) { newPhase, oldPhase in
                if newPhase == .active {
                    loadDataFromStorage()
                }
            }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                meals.remove(at: index)
            }
        }
        saveDataToStorage()
    }
    
    private func getFormattedDate() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: currentDate)
    }
    
    private func previousDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate) ?? currentDate
        checkNextButtonDisabledCondition()
    }
    
    private func nextDay() {
        currentDate = Calendar.current.date(byAdding: .day, value: +1, to: currentDate) ?? currentDate
        checkNextButtonDisabledCondition()
    }
    
    private func pickDate() {
        showDatePicker.toggle()
    }
    
    private func checkNextButtonDisabledCondition() {
        if Calendar.current.isDateInToday(currentDate) {
            isNextDayButtonDisabled = true
        }
        else {
            isNextDayButtonDisabled = false
        }
    }
        
    func saveDataToStorage() {
        if let data = try? PropertyListEncoder().encode(meals) {
            UserDefaults.standard.set(data, forKey: "meals")
        }
    }
    
    func loadDataFromStorage() {
        let defaults = UserDefaults.standard
        if let data = defaults.data(forKey: "meals") {
            meals = try! PropertyListDecoder().decode([Meal].self, from: data)
        }
    }
}

#Preview {
    ContentView()
}
