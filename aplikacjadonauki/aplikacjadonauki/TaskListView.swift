import SwiftUI

// MARK: - TaskListView
struct TaskListView: View {
    @ObservedObject var vm: AppViewModel
    @State private var selectedCategory: TaskCategory?  = nil
    @State private var selectedFrequency: TaskFrequency? = nil
    @State private var showAddTask = false
    @State private var expandedSections: Set<TaskFrequency> = Set(TaskFrequency.allCases)

    var filteredTasks: [CleaningTask] {
        vm.tasks.filter { task in
            let catMatch  = selectedCategory  == nil || task.category  == selectedCategory
            let freqMatch = selectedFrequency == nil || task.frequency == selectedFrequency
            return catMatch && freqMatch
        }
    }

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            VStack(spacing: 0) {
                filterSection
                taskListSection
            }
            #if !targetEnvironment(macCatalyst)
            addButton
            #endif
        }
        .sheet(isPresented: $showAddTask) { AddCustomTaskView(vm: vm) }
    }

    // MARK: - FAB
    private var addButton: some View {
        Button { showAddTask = true } label: {
            ZStack {
                Circle()
                    .fill(LinearGradient(colors: [.blue, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    .frame(width: 58, height: 58)
                    .shadow(color: Color.blue.opacity(0.40), radius: 14, x: 0, y: 6)
                Image(systemName: "plus")
                    .font(.title2).bold()
                    .foregroundColor(.white)
            }
        }
        .buttonStyle(.plain)
        .padding(20)
    }

    // MARK: - Filters
    private var filterSection: some View {
        VStack(spacing: 0) {
            // Częstotliwość
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ModernFilterChip(label: "Wszystkie", icon: "square.grid.2x2.fill",
                                     color: .gray, isSelected: selectedFrequency == nil) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedFrequency = nil }
                    }
                    ForEach(TaskFrequency.allCases, id: \.self) { freq in
                        ModernFilterChip(label: freq.rawValue, icon: freq.icon,
                                         color: freq.swiftUIColor,
                                         isSelected: selectedFrequency == freq) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedFrequency = (selectedFrequency == freq) ? nil : freq
                            }
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 10)
            }

            // Kategoria
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ModernFilterChip(label: "Wszystkie", icon: "square.grid.2x2.fill",
                                     color: .gray, isSelected: selectedCategory == nil) {
                        withAnimation(.easeInOut(duration: 0.2)) { selectedCategory = nil }
                    }
                    ForEach(TaskCategory.allCases, id: \.self) { cat in
                        ModernFilterChip(label: cat.rawValue, icon: cat.icon,
                                         color: cat.swiftUIColor,
                                         isSelected: selectedCategory == cat) {
                            withAnimation(.easeInOut(duration: 0.2)) {
                                selectedCategory = (selectedCategory == cat) ? nil : cat
                            }
                        }
                    }
                }
                .padding(.horizontal, 16).padding(.bottom, 10)
            }
        }
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 2)
        .padding(.horizontal, 16).padding(.bottom, 6)
    }

    // MARK: - Task List
    private var taskListSection: some View {
        ScrollView {
            LazyVStack(spacing: 10, pinnedViews: .sectionHeaders) {
                if filteredTasks.isEmpty {
                    emptyState
                } else if selectedFrequency == nil {
                    ForEach(TaskFrequency.allCases, id: \.self) { freq in
                        let tasks = filteredTasks.filter { $0.frequency == freq }
                        if !tasks.isEmpty {
                            Section {
                                if expandedSections.contains(freq) {
                                    ForEach(tasks) { task in
                                        ModernTaskRow(task: task) { vm.toggle(task: task) }
                                            .transition(.opacity.combined(with: .move(edge: .top)))
                                            .contextMenu {
                                                if task.isCustom {
                                                    Button(role: .destructive) {
                                                        vm.tasks.removeAll { $0.id == task.id }
                                                    } label: {
                                                        Label("Usuń zadanie", systemImage: "trash")
                                                    }
                                                }
                                            }
                                    }
                                }
                            } header: {
                                SectionHeader(
                                    frequency: freq, tasks: tasks,
                                    isExpanded: expandedSections.contains(freq)
                                ) {
                                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                                        if expandedSections.contains(freq) {
                                            expandedSections.remove(freq)
                                        } else {
                                            expandedSections.insert(freq)
                                        }
                                    }
                                }
                            }
                        }
                    }
                } else {
                    ForEach(filteredTasks) { task in
                        ModernTaskRow(task: task) { vm.toggle(task: task) }
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.bottom, 110)
        }
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle().fill(Color.green.opacity(0.10)).frame(width: 90, height: 90)
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(LinearGradient(colors: [.green, .teal], startPoint: .top, endPoint: .bottom))
            }
            Text("Wszystkie ukończone! 🎉")
                .font(.title3).bold()
            Text("Dodaj nowe lub czekaj na reset")
                .foregroundStyle(.secondary).font(.subheadline)
        }
        .frame(maxWidth: .infinity)
        .padding(50)
    }
}

// MARK: - Modern Filter Chip
struct ModernFilterChip: View {
    let label: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 5) {
                Image(systemName: icon)
                    .font(.caption2).bold()
                Text(label)
                    .font(.caption).bold()
            }
            .foregroundColor(isSelected ? .white : color)
            .padding(.horizontal, 12).padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isSelected
                          ? LinearGradient(colors: [color, color.opacity(0.75)], startPoint: .leading, endPoint: .trailing)
                          : LinearGradient(colors: [color.opacity(0.12), color.opacity(0.07)], startPoint: .leading, endPoint: .trailing))
            )
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.clear : color.opacity(0.22), lineWidth: 1)
            )
            .shadow(color: isSelected ? color.opacity(0.30) : .clear, radius: 5, x: 0, y: 2)
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.18), value: isSelected)
    }
}

// MARK: - Section Header
private struct SectionHeader: View {
    let frequency: TaskFrequency
    let tasks: [CleaningTask]
    let isExpanded: Bool
    let onToggle: () -> Void

    var completed: Int { tasks.filter { $0.isDone }.count }
    var allDone: Bool  { completed == tasks.count }

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(frequency.swiftUIColor.opacity(0.13))
                        .frame(width: 30, height: 30)
                    Image(systemName: frequency.icon)
                        .font(.caption).bold()
                        .foregroundColor(frequency.swiftUIColor)
                }
                Text(frequency.rawValue)
                    .font(.subheadline).bold()
                    .foregroundColor(.primary)
                Spacer()
                // Progress mini ring
                ZStack {
                    Circle()
                        .stroke(Color(.systemFill), lineWidth: 3)
                        .frame(width: 26, height: 26)
                    Circle()
                        .trim(from: 0, to: CGFloat(completed) / CGFloat(max(tasks.count, 1)))
                        .stroke(allDone ? Color.green : frequency.swiftUIColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 26, height: 26)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: completed)
                }
                Text("\(completed)/\(tasks.count)")
                    .font(.caption).bold()
                    .foregroundColor(allDone ? .green : .secondary)
                    .frame(width: 32)
                Image(systemName: "chevron.down")
                    .font(.caption).bold()
                    .foregroundColor(.secondary)
                    .rotationEffect(.degrees(isExpanded ? 0 : -90))
                    .animation(.spring(response: 0.35, dampingFraction: 0.75), value: isExpanded)
            }
            .padding(.horizontal, 14).padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 14)
                    .fill(Color(.systemBackground))
                    .shadow(color: frequency.swiftUIColor.opacity(0.08), radius: 5, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .strokeBorder(frequency.swiftUIColor.opacity(0.18), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .background(Color(.systemGroupedBackground))
    }
}

// MARK: - ModernTaskRow
struct ModernTaskRow: View {
    let task: CleaningTask
    let onToggle: () -> Void

    @State private var pressed: Bool = false
    @State private var justDone: Bool = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.22, dampingFraction: 0.6)) { pressed = true }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                    pressed = false
                    if !task.isDone { justDone = true }
                }
                onToggle()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    justDone = false
                }
            }
        } label: {
            HStack(spacing: 14) {
                // Check circle
                ZStack {
                    Circle()
                        .fill(task.isDone
                              ? LinearGradient(colors: [.green, .teal], startPoint: .topLeading, endPoint: .bottomTrailing)
                              : LinearGradient(colors: [Color(.systemFill), Color(.systemFill)], startPoint: .topLeading, endPoint: .bottomTrailing))
                        .frame(width: 34, height: 34)
                        .shadow(color: task.isDone ? Color.green.opacity(0.30) : .clear, radius: 6, x: 0, y: 2)
                    Image(systemName: task.isDone ? "checkmark" : task.category.icon)
                        .font(.system(size: task.isDone ? 13 : 14, weight: .semibold))
                        .foregroundColor(task.isDone ? .white : task.category.swiftUIColor)
                }
                .scaleEffect(justDone ? 1.18 : 1.0)
                .animation(.spring(response: 0.35, dampingFraction: 0.55), value: justDone)

                // Title + badges
                VStack(alignment: .leading, spacing: 5) {
                    Text(task.title)
                        .font(.subheadline).bold()
                        .foregroundColor(task.isDone ? .secondary : .primary)
                        .strikethrough(task.isDone, color: .secondary)
                        .lineLimit(2)
                        .animation(.easeInOut(duration: 0.2), value: task.isDone)

                    HStack(spacing: 6) {
                        // Difficulty
                        HStack(spacing: 2) {
                            Text(task.difficulty.icon)
                            Text(task.difficulty.rawValue)
                        }
                        .font(.caption2).bold()
                        .foregroundColor(difficultyColor)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Capsule().fill(difficultyColor.opacity(0.10)))

                        // XP
                        HStack(spacing: 2) {
                            Image(systemName: "bolt.fill").font(.system(size: 9))
                            Text("+\(task.exp) XP")
                        }
                        .font(.caption2).bold()
                        .foregroundColor(.blue)
                        .padding(.horizontal, 7).padding(.vertical, 3)
                        .background(Capsule().fill(Color.blue.opacity(0.08)))

                        // Gold
                        if task.gold > 0 {
                            HStack(spacing: 2) {
                                Image(systemName: "dollarsign.circle.fill").font(.system(size: 9))
                                Text("+\(task.gold)g")
                            }
                            .font(.caption2).bold()
                            .foregroundColor(.yellow)
                            .padding(.horizontal, 7).padding(.vertical, 3)
                            .background(Capsule().fill(Color.yellow.opacity(0.10)))
                        }

                        if task.isCustom {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundColor(.purple)
                        }
                    }
                }

                Spacer()

                // Czas ukończenia
                if task.isDone, let completed = task.lastCompleted {
                    VStack(alignment: .trailing, spacing: 1) {
                        Image(systemName: "clock.fill")
                            .font(.system(size: 9))
                            .foregroundColor(.green.opacity(0.7))
                        Text(completed, style: .time)
                            .font(.system(size: 9))
                            .foregroundColor(.secondary)
                    }
                }
            }
            .padding(.horizontal, 14).padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(task.isDone
                          ? Color.green.opacity(0.05)
                          : Color(.systemBackground))
                    .shadow(color: task.isDone
                            ? Color.green.opacity(0.08)
                            : Color.black.opacity(0.05),
                            radius: 8, x: 0, y: 2)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(
                        task.isDone
                            ? Color.green.opacity(0.25)
                            : task.category.swiftUIColor.opacity(0.12),
                        lineWidth: 1
                    )
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(pressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.22, dampingFraction: 0.6), value: pressed)
    }

    private var difficultyColor: Color {
        switch task.difficulty {
        case .easy:   return .green
        case .medium: return .orange
        case .hard:   return .red
        }
    }
}
