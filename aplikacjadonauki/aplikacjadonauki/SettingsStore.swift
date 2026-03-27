import Foundation
import Combine
import SwiftUI

class SettingsStore: ObservableObject {
    @Published var accentColorName: String = "blue"
    // Add further published properties as needed

    func colorFor(_ name: String) -> Color {
        Color.blue // Implement your color logic here
    }
}
