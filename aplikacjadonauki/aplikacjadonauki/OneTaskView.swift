import SwiftUI

/// Tryb jednego zadania: pokazuje tylko jedno zadanie naraz.
struct OneTaskView: View {
    @ObservedObject var vm: AppViewModel
    @State private var current: CleaningTask?
    @State private var showConfetti = false

    var body: some View {
        ZStack {
            VStack(spacing: 24) {
                Spacer()
                if let task = current {
                    Text(task.title)
                        .font(.largeTitle.bold())
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    Text("+\(task.exp) XP  •  +\(task.gold) złota")
                        .foregroundColor(.secondary)
                    HStack(spacing: 16) {
                        Button {
                            Haptics.success()
                            vm.toggle(task: task)
                            showConfetti = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                                showConfetti = false
                            }
                            current = vm.randomTask
                        } label: {
                            Label("Zrobione", systemImage: "checkmark.circle.fill")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)

                        Button {
                            Haptics.tap()
                            current = vm.pendingTasks.filter { $0.id != task.id }.randomElement() ?? task
                        } label: {
                            Label("Inne", systemImage: "arrow.triangle.2.circlepath")
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding(.horizontal)
                } else {
                    Text("Wszystko zrobione na dziś 🎉")
                        .font(.title2.bold())
                }
                Spacer()
            }
            if showConfetti { ConfettiView() }
        }
        .navigationTitle("Jedno zadanie")
        .onAppear { current = vm.randomTask }
    }
}
