import SwiftUI
import UniformTypeIdentifiers

/// Eksport i import postępu do pliku JSON. Widok jest niezależny od modeli:
/// podpinasz go przez dwa closure (patrz README / opis PR).
struct DataBackupView: View {
    let makeBackup: () -> Data?
    let restoreBackup: (Data) -> Bool

    @State private var exportDocument = BackupDocument()
    @State private var showExporter = false
    @State private var showImporter = false
    @State private var message: String?

    var body: some View {
        Form {
            Section(header: Text("Kopia zapasowa"),
                    footer: Text("Dane zostają tylko na Twoim urządzeniu. Plik JSON możesz przenieść na inne urządzenie.")) {
                Button("Eksportuj postęp do pliku") {
                    if let data = makeBackup() {
                        exportDocument = BackupDocument(data: data)
                        showExporter = true
                    } else {
                        message = "Nie udało się przygotować kopii."
                    }
                }
                Button("Importuj postęp z pliku") {
                    showImporter = true
                }
            }
            if let message {
                Section { Text(message).font(.footnote) }
            }
        }
        .navigationTitle("Kopia zapasowa")
        .fileExporter(isPresented: $showExporter,
                      document: exportDocument,
                      contentType: .json,
                      defaultFilename: "adhdcleaning-backup") { result in
            switch result {
            case .success: message = "Zapisano kopię zapasową."
            case .failure(let error): message = "Błąd zapisu: \(error.localizedDescription)"
            }
        }
        .fileImporter(isPresented: $showImporter,
                      allowedContentTypes: [.json]) { result in
            switch result {
            case .success(let url):
                let scoped = url.startAccessingSecurityScopedResource()
                defer { if scoped { url.stopAccessingSecurityScopedResource() } }
                if let data = try? Data(contentsOf: url), restoreBackup(data) {
                    message = "Zaimportowano postęp."
                } else {
                    message = "Plik jest nieprawidłowy albo uszkodzony."
                }
            case .failure(let error):
                message = "Błąd importu: \(error.localizedDescription)"
            }
        }
    }
}
