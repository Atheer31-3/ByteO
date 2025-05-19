


import SwiftUI

struct MapView: View {
    @Environment(GameDataStore.self) var gameData
    @State private var navigateToGame = false
    @State private var selectedTrackIndex: Int?
    @State private var selectedLevelIndex: Int?

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    ForEach(LevelData.allTracks.indices, id: \.self) { trackIndex in
                        trackSection(trackIndex: trackIndex)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("خريطة المراحل")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToGame) {
                if let trackIdx = selectedTrackIndex,
                   let levelIdx = selectedLevelIndex {
                    GameView()
                } else {
                    Text("لم يتم اختيار مرحلة")
                }
            }
        }
    }

    // MARK: - قسم المسار مع عنوانه والمستويات
    @ViewBuilder
    func trackSection(trackIndex: Int) -> some View {
        let track = LevelData.allTracks[trackIndex]

        VStack(alignment: .leading, spacing: 16) {
            Text(track.name)
                .font(.title2.bold())
                .foregroundColor(track.color)

            levelsGrid(track: track, trackIndex: trackIndex)
        }
        .padding(.horizontal)
    }

    // MARK: - شبكة المستويات داخل المسار
    @ViewBuilder
    func levelsGrid(track: LevelTrack, trackIndex: Int) -> some View {
        LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 12) {
            ForEach(track.levels.indices, id: \.self) { levelIndex in
                levelButton(track: track, trackIndex: trackIndex, levelIndex: levelIndex)
            }
        }
    }

    // MARK: - زر المستوى
    func levelButton(track: LevelTrack, trackIndex: Int, levelIndex: Int) -> some View {
        let level = track.levels[levelIndex]
        let levelKey = gameData.levelKey(trackName: track.name, levelNumber: level.number)

        let isCompleted = gameData.playerProgress?.completedLevels.contains(levelKey) ?? false
        let isCurrent = (trackIndex == gameData.playerProgress?.currentTrackIndex && levelIndex == gameData.playerProgress?.currentLevelIndex)
        let isLocked = trackIndex > (gameData.playerProgress?.currentTrackIndex ?? 0) ||
            (trackIndex == (gameData.playerProgress?.currentTrackIndex ?? 0) && levelIndex > (gameData.playerProgress?.currentLevelIndex ?? 0))

        return Button(action: {
            guard !isLocked else { return }
            selectedTrackIndex = trackIndex
            selectedLevelIndex = levelIndex
            gameData.playerProgress?.currentTrackIndex = trackIndex
            gameData.playerProgress?.currentLevelIndex = levelIndex
            gameData.save()
            navigateToGame = true
        }) {
            ZStack {
                Circle()
                    .fill(isLocked ? Color.gray.opacity(0.3) : track.color)
                    .frame(width: 60, height: 60)
                    .overlay(
                        Circle()
                            .stroke(isCurrent ? Color.yellow : .clear, lineWidth: 3)
                    )

                if isCompleted {
                    Image(systemName: "checkmark.seal.fill")
                        .foregroundColor(.white)
                        .font(.title2)
                } else {
                    Text("\(level.number)")
                        .foregroundColor(.white)
                        .bold()
                }
            }
        }
        .disabled(isLocked)
    }
}
struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environment(GameDataStore.shared) // أو .environmentObject(GameDataStore.shared)
    }
}

struct SettingsView: View {
    var body: some View {
        Text("الإعدادات...")
    }
}

struct AchievementsView: View {
    var body: some View {
        Text("الإنجازات...")
    }
}

import SwiftUI

struct IntroScenarioView: View {
    @Environment(GameDataStore.self) var gameData
    @Environment(\.dismiss) var dismiss
    @State private var navigateToTutorial = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.opacity(0.95).ignoresSafeArea()

                VStack(spacing: 30) {
                    Text("📜 القصة")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)

                    Text("""
                    في عالم مليء بالأسرار والرسائل المشفّرة، أنت الجاسوس المختار لحلّ ألغاز قد تغيّر مجرى التاريخ.
                    
                    ستواجه تحديات من عصور مختلفة، وسلاحك الوحيد هو قدرتك على فهم الشفرات. هل أنت مستعد؟
                    """)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white)
                    .padding()

                    Button(action: {
                        gameData.playerProgress?.hasSeenIntro = true
                        gameData.save()
                        navigateToTutorial = true
                    }) {
                        Text("استمرار")
                            .font(.headline)
                            .padding()
                            .frame(width: 200)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    NavigationLink("", destination: TutorialView(), isActive: $navigateToTutorial)
                }
                .padding()
            }
        }
    }
}


struct TutorialView: View {
    @Environment(\.dismiss) var dismiss
    @State private var navigateToGame = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("💡 كيف تلعب؟")
                    .font(.largeTitle.bold())

                Text("""
                - كل مرحلة فيها رسالة مشفّرة بتشفير سيزر.
                - مطلوب تفك التشفير وتكتب الجواب الصحيح.
                - عندك 3 محاولات فقط.
                - تقدر تستخدم هنت لمساعدتك مرة وحدة.
                - بعد ما تفوز، تنفتح لك المرحلة اللي بعدها.
                """)
                .multilineTextAlignment(.leading)
                .padding()

                Button("ابدأ اللعب") {
                    navigateToGame = true
                }
                .font(.headline)
                .padding()
                .frame(width: 200)
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(12)

                NavigationLink("", destination: GameView(), isActive: $navigateToGame)
            }
            .padding()
        }
    }
}



import SwiftUI

struct CoinStoreView: View {
    @Environment(GameDataStore.self) var gameData
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("🪙 متجر الكوينز")
                    .font(.largeTitle.bold())

                Text("رصيدك الحالي: \(gameData.playerProgress?.coins ?? 0) 💰")
                    .font(.headline)
                    .foregroundColor(.gray)

                // 🟨 الباقات
                ForEach(coinPackages, id: \.self) { amount in
                    Button(action: {
                        gameData.addCoins(amount)
                    }) {
                        HStack {
                            Image(systemName: "bitcoinsign.circle.fill")
                                .font(.title2)
                            Text("اشترِ \(amount) كوينز")
                                .font(.title3.bold())
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.yellow)
                        .foregroundColor(.black)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    }
                    .padding(.horizontal)
                }

                Spacer()

                Button("رجوع") {
                    dismiss()
                }
                .foregroundColor(.blue)
            }
            .padding()
        }
    }

    // 🪙 خيارات الباقات
    var coinPackages: [Int] {
        [75, 150, 300]
    }
}
