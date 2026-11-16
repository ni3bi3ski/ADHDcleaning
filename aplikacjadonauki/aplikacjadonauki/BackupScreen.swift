import SwiftUI

/// Gotowy ekran do wstawienia w ustawieniach:
/// NavigationLink("Kopia zapasowa") { BackupScreen(vm: vm) }
struct BackupScreen: View {
    @ObservedObject var vm: AppViewModel

    var body: some View {
        VStack(spacing: 0) {
            DataBackupView(
                makeBackup: { vm.exportBackupData() },
                restoreBackup: { vm.importBackupData($0) }
            )
            Form {
                Section(header: Text("Tryb choroby"),
                        footer: Text("Na 24 godziny wyłącza kary za pominięte zadania, żeby gorszy dzień nie psuł postępu.")) {
                    if vm.profile.hasSkipPenalty {
                        Button("Wyłącz tryb choroby") { vm.deactivateSickDay() }
                    } else {
                        Button("Włącz tryb choroby na 24 h") { vm.activateSickDay() }
                    }
                }
            }
        }
    }
}
