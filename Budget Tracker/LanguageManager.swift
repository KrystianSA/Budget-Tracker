import Foundation
import SwiftUI

class LanguageManager: ObservableObject {
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "selectedLanguage")
            UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
    }
    
    init() {
        self.currentLanguage = UserDefaults.standard.string(forKey: "selectedLanguage") ?? "pl"
    }
    
    func localizedString(for key: String) -> String {
        let path = Bundle.main.path(forResource: currentLanguage, ofType: "lproj")
        let bundle = Bundle(path: path ?? "") ?? Bundle.main
        return bundle.localizedString(forKey: key, value: key, table: nil)
    }
    
    func updateLanguage(to language: String) {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentLanguage = language
        }
    }
}

extension String {
    func localized(using languageManager: LanguageManager) -> String {
        return languageManager.localizedString(for: self)
    }
}

