//import SwiftUI
//import SwiftData
//
//// MARK: - Combined Line Progress Box
//struct CombinedProgressBox: View {
//    let metroLines: [MetroLine]
//
//    /// Flatten all levels across lines
//    private var allLevels: [Level] {
//        metroLines.flatMap { $0.levels }
//    }
//
//    /// Percentage of completed levels
//    private var progress: Double {
//        guard !allLevels.isEmpty else { return 0 }
//        let completedCount = allLevels.filter { $0.isCompleted }.count
//        return Double(completedCount) / Double(allLevels.count)
//    }
//
//    var body: some View {
//        VStack(alignment: .leading, spacing: 15) {
//            Text("Byto Progress")
//                .font(.headline)
//
//            GeometryReader { geo in
//                ZStack(alignment: .leading) {
//                    Capsule()
//                        .fill(Color.gray.opacity(0.3))
//                        .frame(height: 8)
//
//                    Capsule()
//                        .fill(Color.green)
//                        .frame(width: geo.size.width * progress, height: 8)
//
//                    Image("ByteOWalking")
//                        .resizable()
//                        .frame(width: 50, height: 50)
//                        .offset(x: CGFloat(progress) * (geo.size.width - 24))
//                        .animation(.linear(duration: 0.5), value: progress)
//                }
//            }
//            .frame(height: 24)
//
//            Text("\(Int(progress * 100))% completed")
//                .font(.caption2)
//                .foregroundColor(.secondary)
//        }
//        .padding(8)
//        .background(.ultraThinMaterial)
//        .cornerRadius(16)
//    }
//}
//
//// MARK: - Metro Map View
//struct MetroMapView: View {
//    @Environment(\.modelContext) private var context
//    @Query private var stores: [GameDataStore]
//    @State private var selectedLevelID: UUID?
//
//    /// The single game store, if it exists
//    private var store: GameDataStore? {
//        stores.first
//    }
//
//    /// Wrap into an array so we can support multiple lines later
//    private var metroLines: [MetroLine] {
//        if let line = store?.metroLine {
//            return [line]
//        }
//        return []
//    }
//
//    /// Flattened tuple of (level, color, lineName)
//    private var levelTuples: [(level: Level, color: Color, lineName: String)] {
//        metroLines.flatMap { line in
//            line.levels.map { level in
//                (level, line.lineColor, line.name)
//            }
//        }
//    }
//
//    var body: some View {
//        ZStack {
//            Image("bg")
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .ignoresSafeArea()
//
//            if let game = store {
//                VStack(spacing: 16) {
//                    // Progress bar
//                    CombinedProgressBox(metroLines: metroLines)
//                        .padding(.trailing, 45)
//
//                    // Scrollable map
//                    ScrollView(.horizontal, showsIndicators: false) {
//                        VStack(alignment: .center, spacing: 12) {
//                            // Line names row
//                            HStack(spacing: 0) {
//                                ForEach(Array(levelTuples.enumerated()), id: \.offset) { idx, tuple in
//                                    if idx == 0 || levelTuples[idx - 1].lineName != tuple.lineName {
//                                        Text(tuple.lineName)
//                                            .font(.headline)
//                                            .foregroundColor(.white)
//                                    } else {
//                                        Spacer().frame(width: 74)
//                                    }
//                                }
//                            }
//
//                            // Level circles row
//                            HStack(spacing: 0) {
//                                ForEach(Array(levelTuples.enumerated()), id: \.offset) { idx, tuple in
//                                    let level    = tuple.level
//                                    let color    = tuple.color
//                                    let unlocked = level.levelNumber <= game.currentLevel
//
//                                    HStack(spacing: 0) {
//                                        if idx != 0 {
//                                            Rectangle()
//                                                .fill(color)
//                                                .frame(width: 40, height: 4)
//                                        }
//
//                                        ZStack {
//                                            Circle()
//                                                .fill(color)
//                                                .frame(
//                                                    width: selectedLevelID == level.id ? 40 : 30,
//                                                    height: selectedLevelID == level.id ? 40 : 30
//                                                )
//                                                .shadow(
//                                                    color: selectedLevelID == level.id
//                                                        ? color.opacity(0.8)
//                                                        : .clear,
//                                                    radius: selectedLevelID == level.id ? 10 : 0
//                                                )
//                                                .scaleEffect(selectedLevelID == level.id ? 1.2 : 1)
//                                                .opacity(unlocked ? 1 : 0.5)
//                                                .animation(.spring(response: 0.4, dampingFraction: 0.6),
//                                                           value: selectedLevelID)
//
//                                            Image(systemName: unlocked ? "lock.open" : "lock")
//                                                .resizable()
//                                                .scaledToFit()
//                                                .frame(width: 14, height: 14)
//                                                .foregroundColor(.white)
//                                        }
//                                        .onTapGesture {
//                                            guard unlocked else { return }
//                                            game.currentLevel   = level.levelNumber
//                                            selectedLevelID     = level.id
//                                            try? context.save()
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                        .padding(.horizontal, 20)
//                        .padding(.vertical, 30)
//                        .background(.ultraThinMaterial)
//                        .cornerRadius(16)
//                    }
//                }
//            } else {
//                // Fallback UI if no data exists
//                VStack(spacing: 20) {
//                    Image(systemName: "exclamationmark.triangle.fill")
//                        .font(.system(size: 40))
//                        .foregroundColor(.orange)
//                    Text("⚠️ No game data available")
//                        .font(.headline)
//                        .foregroundColor(.white)
//                }
//            }
//        }
//        // Bootstrap if needed
//        .onAppear {
//            if stores.isEmpty {
//                bootstrapIfNeeded()
//            }
//        }
//        // Navigate into the decryption view
//        .navigationDestination(for: UUID.self) { id in
//            DecryptionGameView(levelID: id)
//        }
//    }
//
//    /// Creates the initial GameDataStore if none exists yet
//    private func bootstrapIfNeeded() {
//        let player   = Player()
//        let settings = Settings()
//
//        let lineDefs: [(line: Level.Line, title: String)] = [
//            (.yellow, "Yellow Line"),
//            (.teal,   "Teal Line"),
//            (.purple, "Purple Line")
//        ]
//
//        let metroLines: [MetroLine] = lineDefs.map { def in
//            let levels: [Level] = (1...3).map { num in
//                let qs = QuestionBank.shared.questionsByLevel[num] ?? []
//                return Level(
//                    levelNumber: num,
//                    lineName:    def.line,
//                    isCompleted: false,
//                    questions:   qs
//                )
//            }
//            return MetroLine(
//                name:     def.title,
//                lineName: def.line,
//                levels:   levels
//            )
//        }
//
//        let store = GameDataStore(
//            metroLine:    metroLines.first!,
//            player:       player,
//            settings:     settings,
//            achievements: [],
//            levels:       metroLines.flatMap(\.levels)
//        )
//        context.insert(store)
//        try? context.save()
//    }
//}
//
//// MARK: - Preview
//
//struct MetroMapView_Previews: PreviewProvider {
//    static var previews: some View {
//        MetroMapView()
//            .previewInterfaceOrientation(.landscapeLeft)
//    }
//}
