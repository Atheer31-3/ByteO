
import SwiftUI

struct GameView: View {
    @Environment(GameDataStore.self) var gameData
    @Environment(\.dismiss) var dismiss

    @State private var userAnswer: String = ""
    @State private var showHint = false
    @State private var usedHint = false
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var attemptsRemaining: Int = 3
    @State private var navigateToMap = false
    @State private var resetTimer: Timer?
    @State private var resetTimeText: String = ""
    var body: some View {
        let progress = gameData.playerProgress
        let trackIndex = progress?.currentTrackIndex ?? 0
        let levelIndex = progress?.currentLevelIndex ?? 0
        let track = LevelData.allTracks[trackIndex]
        let level = track.levels[levelIndex]
        let levelKey = gameData.levelKey(trackName: track.name, levelNumber: level.number)

        // 🧮 استرجاع المحاولات المتبقية
        let attemptsUsed = progress?.failedAttempts[levelKey] ?? 0
        let remaining = max(3 - attemptsUsed, 0)

        VStack(spacing: 20) {
            // العنوان
            Text("\(track.name) - مرحلة \(level.number)")
                .font(.title2.bold())
                .foregroundColor(track.color)

            // النص المشفر
            Text("🔐 \(level.encryptedText)")
                .font(.system(size: 30, weight: .bold, design: .monospaced))

            // خانة الإجابة
            TextField("اكتب الإجابة هنا", text: $userAnswer)
                .textFieldStyle(.roundedBorder)
                .padding(.horizontal)

            // عدد المحاولات
            Text("المحاولات المتبقية: \(remaining)")
                .foregroundColor(.orange)

            // الكوينز الحالية
            Text("💰 كوينزك: \(progress?.coins ?? 0)")
                .foregroundColor(.secondary)

            // زر الهنت
            if !usedHint && !(progress?.hintsUsed.contains(levelKey) ?? false) {
                Button("💡 استخدم الهنت") {
                    usedHint = gameData.useHint(for: levelKey)
                    showHint = true
                }
            }

            if showHint {
                Text("💬 تلميح: \(level.hint)")
                    .foregroundColor(.blue)
            }

            // تحقق
            if remaining > 0 {
                Button("✅ تحقق") {
                    if userAnswer.uppercased().trimmingCharacters(in: .whitespacesAndNewlines) == level.correctAnswer.uppercased() {
                        isCorrect = true
                        showResult = true
                        gameData.markLevelCompleted(levelKey)
                        gameData.addCoins(10) // تعطيه كوينز كمكافأة
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            gameData.moveToNextLevel(totalLevels: track.levels.count)
                            navigateToMap = true
                        }
                    } else {
                        isCorrect = false
                        showResult = true
                        gameData.registerFailedAttempt(for: levelKey)
                    }
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            } else {
                if (progress?.coins ?? 0) >= 50 {
                    Button("🪙 استخدم 50 كوينز لمحاولة إضافية") {
                        if gameData.useCoins(50) {
                            let current = gameData.playerProgress?.failedAttempts[levelKey] ?? 0
                            if current > 0 {
                                gameData.playerProgress?.failedAttempts[levelKey] = current - 1
                            } else {
                                // تأكيد إننا ما نحطها بالسالب
                                gameData.playerProgress?.failedAttempts[levelKey] = 0
                            }
                            gameData.save()
                        }
                    }
                    .foregroundColor(.yellow)
                } else {
                    VStack {
                        Text("❌ انتهت محاولاتك!")
                            .foregroundColor(.red)

                        if let lastReset = progress?.lastResetDate {
                            Text("⏳ المحاولات ترجع خلال:")
                                .font(.subheadline)

                            Text(timeUntilReset(lastDate: lastReset))
                                .font(.title3)
                                .foregroundColor(.blue)
                                .bold()
                                .onAppear {
                                    // تشغيل المؤقت للتحديث كل دقيقة
                                    resetTimer?.invalidate()
                                    resetTimer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                                        resetTimeText = timeUntilReset(lastDate: lastReset)
                                    }
                                    resetTimeText = timeUntilReset(lastDate: lastReset)
                                }
                                .onDisappear {
                                    resetTimer?.invalidate()
                                }
                        }
                    }
                }
            }
        

            // النتيجة
            if showResult {
                Text(isCorrect ? "🎉 إجابة صحيحة!" : "❌ خطأ، حاول مجددًا")
                    .font(.headline)
                    .foregroundColor(isCorrect ? .green : .red)
            }

            NavigationLink("", destination: MapView(), isActive: $navigateToMap)
        }
        .padding()
        .navigationTitle("مرحلة \(level.number)")
    }
    
    func timeUntilReset(lastDate: Date) -> String {
        let now = Date()
        let resetDate = Calendar.current.date(byAdding: .hour, value: 24, to: lastDate) ?? now
        let diff = Calendar.current.dateComponents([.hour, .minute], from: now, to: resetDate)

        let h = diff.hour ?? 0
        let m = diff.minute ?? 0
        return String(format: "%02d ساعة و %02d دقيقة", h, m)
    }
}



struct MapView: View {
    @Environment(GameDataStore.self) var gameData
    @State private var navigateToGame = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 40) {
                    ForEach(LevelData.allTracks.indices, id: \.self) { trackIndex in
                        let track = LevelData.allTracks[trackIndex]
                        VStack(alignment: .leading, spacing: 16) {
                            Text(track.name)
                                .font(.title2.bold())
                                .foregroundColor(track.color)

                            // 🧩 مستويات هذا المسار
                            LazyVGrid(columns: Array(repeating: .init(.flexible()), count: 4), spacing: 12) {
                                ForEach(track.levels.indices, id: \.self) { levelIndex in
                                    let level = track.levels[levelIndex]
                                    let levelKey = gameData.levelKey(trackName: track.name, levelNumber: level.number)

                                    let isCompleted = gameData.playerProgress?.completedLevels.contains(levelKey) ?? false
                                    let isCurrent = (trackIndex == gameData.playerProgress?.currentTrackIndex && levelIndex == gameData.playerProgress?.currentLevelIndex)
                                    let isLocked = trackIndex > gameData.playerProgress?.currentTrackIndex ?? 0 ||
                                        (trackIndex == gameData.playerProgress?.currentTrackIndex && levelIndex > gameData.playerProgress?.currentLevelIndex ?? 0)

                                    Button(action: {
                                        if !isLocked {
                                            gameData.playerProgress?.currentTrackIndex = trackIndex
                                            gameData.playerProgress?.currentLevelIndex = levelIndex
                                            gameData.save()
                                            navigateToGame = true
                                        }
                                    }) {
                                        ZStack {
                                            Circle()
                                                .fill(isLocked ? Color.gray.opacity(0.3) : track.color)
                                                .frame(width: 60, height: 60)
                                                .overlay(
                                                    Circle()
                                                        .stroke(isCurrent ? Color.yellow : .clear, lineWidth: 3)
                                                )

                                            Text("\(level.number)")
                                                .foregroundColor(.white)
                                                .bold()
                                        }
                                    }
                                    .disabled(isLocked)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("خريطة المراحل")
            .navigationBarTitleDisplayMode(.inline)
            .navigationDestination(isPresented: $navigateToGame) {
                GameView()
            }
        }
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
