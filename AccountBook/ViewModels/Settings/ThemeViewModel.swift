//
//  ThemeViewModel.swift
//  AccountBook
//
//  Created by 김정원 on 11/25/25.
//

class ThemeViewModel {
    let manager = ThemeManager.shared
    
    var selectedRow: Int {
        return manager.listOfThemes.firstIndex(of: manager.currentKind)!
    }
    
    var numberOfRowsInSection: Int {
        return manager.countOfThemes
    }
    
    func cellForRowAt(row: Int) -> AppTheme {
        return manager.listOfThemes[row].theme
    }
    
    func didSelectRowAt(row: Int) {
        let kind = manager.listOfThemes[row]
        manager.apply(kind: kind)
    }
}
