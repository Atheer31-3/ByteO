
import Foundation
import SwiftData
import SwiftUI

@Model
class PlayerProgress {
    var currentTrackIndex: Int = 0
    var currentLevelIndex: Int = 0
    var coins: Int = 0
    var failedAttempts: [String: Int] = [:]
    var hintsUsed: [String] = []
    var completedLevels: [String] = []
    var hasSeenIntro: Bool = false
    var lastResetDate: Date
    var achievementsUnlocked: [String] = []

    init() {
        self.lastResetDate = Date() // ✅ حطيناها هنا بدلاً من .now مباشرة
    }
}



struct StaticLevel: Identifiable {
    let id = UUID()
    let number: Int
    let question: String
    let encryptedText: String
    let correctAnswer: String
    let hint: String
    // إذا حبيت تضيف لاحقاً:
    // let points: Int
    // let timeLimit: Int?
    // let imageName: String?
}

struct LevelTrack: Identifiable {
    let id = UUID()
    let name: String
    let color: Color
    let levels: [StaticLevel]
}

struct LevelData {
    static let allTracks: [LevelTrack] = [

        // 🟦 المسار الأزرق
        LevelTrack(
            name: "المسار الأزرق",
            color: .blue,
            levels: [
                StaticLevel(
                    number: 1,
                    question: "ما هو النص المشفر؟",
                    encryptedText: "KHOOR",
                    correctAnswer: "AAAA",
                    hint: "جرب تزحزح الحروف 3 مرات"
                ),
                StaticLevel(
                    number: 2,
                    question: "حلّ النص التالي:",
                    encryptedText: "ZRUOG",
                    correctAnswer: "AAAA",
                    hint: "نفس التكنيك"
                )
            ]
        ),

        // 🟥 المسار الأحمر
        LevelTrack(
            name: "المسار الأحمر",
            color: .red,
            levels: [
                StaticLevel(
                    number: 1,
                    question: "رسالة مشفّرة من شخص غريب",
                    encryptedText: "SBWKRQ",
                    correctAnswer: "AAAA",
                    hint: "سيزر +3"
                ),
                StaticLevel(
                    number: 2,
                    question: "افكّر في التشفير",
                    encryptedText: "FDHVDU",
                    correctAnswer: "AAAA",
                    hint: "هذا هو نوع التشفير!"
                )
            ]
        )
    ]
}














@Observable
class GameDataStore {
    @MainActor
    static let shared = GameDataStore()

    var context: ModelContext
    var playerProgress: PlayerProgress?

    init() {
        let container = try! ModelContainer(for: PlayerProgress.self)
        self.context = ModelContext(container)

        Task {
            await self.loadProgress()
        }
    }

    // 🔄 تحميل أو إنشاء بيانات اللاعب
    @MainActor
    func loadProgress() {
        if let existing = try? context.fetch(FetchDescriptor<PlayerProgress>()).first {
            playerProgress = existing
        } else {
            let newProgress = PlayerProgress()
            context.insert(newProgress)
            try? context.save()
            playerProgress = newProgress
        }
    }

    // 💾 حفظ التغيرات
    @MainActor
    func save() {
        try? context.save()
    }

    // 💰 إضافة كوينز
    @MainActor
    func addCoins(_ amount: Int) {
        playerProgress?.coins += amount
        save()
    }

    // 💰 خصم كوينز
    @MainActor
    func useCoins(_ amount: Int) -> Bool {
        guard let progress = playerProgress, progress.coins >= amount else { return false }
        progress.coins -= amount
        save()
        return true
    }

    // 🔑 توليد معرف فريد للمرحلة
    func levelKey(trackName: String, levelNumber: Int) -> String {
        return "\(trackName.lowercased())-\(levelNumber)"
    }

    // 📉 تسجيل محاولة فاشلة
    @MainActor
    func registerFailedAttempt(for key: String) {
        guard let progress = playerProgress else { return }

        let current = progress.failedAttempts[key] ?? 0
        progress.failedAttempts[key] = current + 1

        if current + 1 >= 3 {
            progress.lastResetDate = Date()
        }

        save()
    }

    // ⏳ هل يمكن إعادة المحاولة؟
    func canRetry(levelKey: String) -> Bool {
        guard let progress = playerProgress else { return true }

        let attempts = progress.failedAttempts[levelKey] ?? 0

        if attempts < 3 {
            return true
        }

        let hours = Calendar.current.dateComponents([.hour], from: progress.lastResetDate, to: Date()).hour ?? 0
        return hours >= 24
    }

    // 🧼 إعادة المحاولات بعد 24 ساعة
    @MainActor
    func resetFailedAttemptsIfNeeded() {
        guard let progress = playerProgress else { return }

        let now = Date()
        let hours = Calendar.current.dateComponents([.hour], from: progress.lastResetDate, to: now).hour ?? 0

        if hours >= 24 {
            progress.failedAttempts.removeAll()
            progress.lastResetDate = now
            save()
        }
    }

    // 💡 تسجيل استخدام الهنت
    @MainActor
    func useHint(for key: String) -> Bool {
        guard let progress = playerProgress else { return false }

        if !progress.hintsUsed.contains(key) {
            progress.hintsUsed.append(key)
            save()
            return true
        }

        return false
    }

    // ✅ تسجيل المرحلة كمكتملة
    @MainActor
    func markLevelCompleted(_ key: String) {
        guard let progress = playerProgress else { return }
        if !progress.completedLevels.contains(key) {
            progress.completedLevels.append(key)
            save()
        }
    }

    // ⏫ الانتقال للمستوى التالي
    @MainActor
    func moveToNextLevel(totalLevels: Int) {
        guard let progress = playerProgress else { return }

        if progress.currentLevelIndex + 1 < totalLevels {
            progress.currentLevelIndex += 1
        } else {
            progress.currentLevelIndex = 0
            progress.currentTrackIndex += 1
        }

        save()
    }

    // 🏆 فتح إنجاز جديد
    @MainActor
    func unlockAchievement(_ name: String) {
        guard let progress = playerProgress else { return }
        if !progress.achievementsUnlocked.contains(name) {
            progress.achievementsUnlocked.append(name)
            save()
        }
    }
}
