# ADHDcleaning

Grywalizowana aplikacja do sprzątania i codziennych nawyków dla osób z ADHD (SwiftUI, iOS). Zadania dają XP i złoto, pominięcia kosztują HP, a nagrody kupujesz w sklepie.

## Funkcje

- Zadania dzienne, tygodniowe i miesięczne z kategoriami i poziomami trudności
- XP, poziomy, złoto, HP, streak, combo oraz wyzwania tygodniowe
- Klasy postać, statystyki, umiejętności, zwierzaki z wyprawami, awatar
- Sklep z nagrodami, eliksirami i przedmiotami, koło fortuny
- Tryb jednego zadania: jedno zadanie naraz, bez rozpraszaczy
- Tryb choroby: 24 godziny bez kar za pominięte zadania
- Szablony zadań (kuchnia, łazienka, sypialnia, salon, poranna rutyna)
- Focus Timer, tracker nastroju, tryb chaosu
- Eksport i import postępu do pliku JSON

## Prywatność

Aplikacja działa w pełni lokalnie. Nie ma kont, serwera, analityki ani wysyłania danych. Stan gry jest w UserDefaults na urządzeniu, a dodatkowa kopia JSON trafia do katalogu Application Support. Przeniesienie postępu na inne urządzenie: Ustawienia → Dane i zadania → Kopia zapasowa.

## Budowanie

Wymagania: Xcode z obsługą iOS 26.2 (zgodnie z ustawieniami projektu).

1. Sklonuj repozytorium i otwórz `aplikacjadonauki/aplikacjadonauki.xcodeproj`.
2. W Signing & Capabilities wybierz własny Team i zmień Bundle Identifier na własny.
3. Uruchom na symulatorze lub urządzeniu.

Jeśli projekt nadal wymaga pakietu `firebase-ios-sdk`, usuń go w Project → Package Dependencies: aplikacja go nie używa.

## Struktura

- `AppViewModel.swift` – logika gry i zapis stanu
- `Models.swift` – modele danych i domyślne zawartości sklepu
- `*TabView.swift`, `ShopView.swift`, `AvatarView.swift` – interfejs
- `AppViewModel+Backup.swift`, `BackupScreen.swift`, `DataBackupView.swift` – kopia zapasowa i tryb choroby
- `RoomTemplates.swift`, `RoomTemplatesView.swift` – szablony zadań

## Licencja

MIT, zobacz plik LICENSE.
