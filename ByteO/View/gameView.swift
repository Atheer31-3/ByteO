import SwiftUI
import SwiftData

struct InfiniteLetterPicker: View {
    private let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
    private let loopCount = 3
    var allLetters: [String] {
        Array(repeating: letters, count: loopCount).flatMap { $0 }.map { String($0) }
    }
    @Binding var selectedLetter: String
    @State private var selectedIndex: Int = 0

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(.ultraThinMaterial)
                .frame(width: 30, height: 30)
                .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: 1)

            Picker("", selection: $selectedIndex) {
                ForEach(0..<allLetters.count, id: \.self) { i in
                    Text(allLetters[i])
                        .font(.title2)
                        .frame(width: 40, height: 40)
                }
            }
            .pickerStyle(WheelPickerStyle())
            .frame(width: 50, height: 120)
            .clipped()
            .onAppear {
                if let centerIndex = allLetters.firstIndex(of: selectedLetter) {
                    selectedIndex = 26 + centerIndex % 26
                }
            }
            .onChange(of: selectedIndex) { newValue in
                selectedLetter = allLetters[newValue % 26]
                if newValue <= 1 || newValue >= allLetters.count - 2 {
                    selectedIndex = 26 + (newValue % 26)
                }
            }
        }
    }
}
struct GameView: View {
    @Environment(GameDataStore.self) var gameData
    @Environment(\.dismiss) var dismiss
    
    @State private var slots: [String] = ["A", "A", "A", "A", "A"]
    @State private var showHint = false
    @State private var usedHint = false
    @State private var showResult = false
    @State private var isCorrect = false
    @State private var navigateToMap = false
    @State private var resetTimer: Timer?
    @State private var resetTimeText: String = ""
    
    @State private var showWalletPopup = false
    @State private var showAttemptsPopup = false
    @State private var showExitPopup = false
    @State private var animationOffset: CGFloat = -500
    @State private var navigateToMainMenu = false
    @State private var showHintPopup = false
    @State private var showAdPrompt = false
    
    @State private var showWinPopup = false
    @State private var showFailPopup = false
    @State private var showStoreSheet = false
    var body: some View {
        let progress = gameData.playerProgress
        let tracks = LevelData.allTracks

        let rawTrackIndex = progress?.currentTrackIndex ?? 0
        let trackIndex = min(max(0, rawTrackIndex), tracks.count - 1)
        let track = tracks[trackIndex]

        let rawLevelIndex = progress?.currentLevelIndex ?? 0
        let levels = track.levels
        let levelIndex = min(max(0, rawLevelIndex), levels.count - 1)
        let level = levels[levelIndex]
        let levelKey = gameData.levelKey(trackName: track.name, levelNumber: level.number)

        let attemptsUsed = progress?.failedAttempts[levelKey] ?? 0
        let remaining = max(3 - attemptsUsed, 0)
        
        ZStack {
            NavigationLink("", destination: MainMenuView(), isActive: $navigateToMainMenu).hidden()
            NavigationLink("", destination: MapView(), isActive: $navigateToMap).hidden()

            Color.white.opacity(0.9).edgesIgnoringSafeArea(.all).blur(radius: showHintPopup ? 5 : 0)

            Image("bg")
                .resizable()
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 5) {
                Button(action: { showExitPopup = true }) {
                    Image(systemName: "chevron.backward.circle.fill")
                        .font(.title)
                        .foregroundColor(.c3)
                        .frame(width: 50, height: 50)
                        .background(Color.white.opacity(0.4))
                        .clipShape(Circle())
                }
                .alert("Do you want to exit the game?", isPresented: $showExitPopup) {
                    Button("Yes", role: .destructive) { navigateToMainMenu = true }
                    Button("Cancel", role: .cancel) {}
                }
                
                Button(action: { showWalletPopup = true }) {
                    HStack {
                        Image(systemName: "wallet.bifold.fill")
                            .foregroundColor(.white)
                        Text(" \(progress?.coins ?? 0)")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.4))
                    .cornerRadius(12)
                }
                .alert("Your current balance is: \(progress?.coins ?? 0) coins", isPresented: $showWalletPopup) {
                    Button("OK", role: .cancel) {}
                }
                
                Button(action: { showAttemptsPopup = true }) {
                    HStack {
                        Image(systemName: "pawprint.fill")
                            .foregroundColor(.white)
                        Text(" \(remaining)x").foregroundColor(.white).font(.headline)
                    }
                    .padding(8)
                    .background(Color.white.opacity(0.4))
                    .cornerRadius(12)
                }
                .alert("You have \(remaining) attempts", isPresented: $showAttemptsPopup) {
                    Button("OK", role: .cancel) {}
                }
            }
            .padding(.leading, -410)
            .padding(.bottom, 190)

            HStack(alignment: .top, spacing: -15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(.ultraThinMaterial)
                        .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.c2.opacity(0.8), lineWidth: 1.8))
                        .shadow(color: .c2.opacity(0.5), radius: 8, x: 0, y: 5)

                    VStack(alignment: .leading, spacing: 5) {
                        Text("\(track.name) \(level.number)")
                            .font(.system(size: 18, weight: .bold, design: .monospaced))
                            .foregroundColor(track.color)
                        Text("Encrypted messages : \(level.encryptedText)")
                            .font(.system(size: 16, design: .monospaced))
                            .foregroundColor(.white.opacity(0.9))
                    }
                    .padding()
                    .offset(x: animationOffset)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.5)) {
                            animationOffset = 0
                        }
                    }
                    .frame(width: 500, height: 100)

                    Button(action: {
                        if !usedHint && !(progress?.hintsUsed.contains(levelKey) ?? false) {
                            usedHint = gameData.useHint(for: levelKey)
                            showHint = true
                        } else {
                            showAdPrompt = true
                        }
                    }) {
                        ZStack {
                            Circle().fill(Color.c2.opacity(0.99)).frame(width: 50, height: 50)
                            Image(systemName: "lightbulb.fill")
                                .font(.title)
                                .frame(width: 50, height: 50)
                                .foregroundColor(.white)
                        }
                    }
                    .alert("Alert", isPresented: $showAdPrompt) {
                        Button("OK") {}
                    } message: {
                        Text("To unlock another hint, you need to watch an Ad")
                    }
                    .padding(.leading, -320)
                    .padding(.bottom, 50)
                    .transition(.move(edge: .bottom))
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: showHintPopup)
                }

                .frame(width: 450, height: 130)

                Image("robot_zero")
                    .resizable()
                    .frame(width: 160, height: 160)
                    .alignmentGuide(.top) { _ in 0 }
                    .offset(x: animationOffset, y: -30)
                    .transition(.scale)
                    .onAppear {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.5)) {
                            animationOffset = 0
                        }
                    }
            }
            .padding(.trailing, -250)
            .padding(.bottom, 180)

            VStack(spacing: -15) {
                Text(slots.joined())
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.8))
                    .padding()
                    .frame(maxWidth: 250)
                    .background(.ultraThinMaterial)
                    .cornerRadius(12)

                HStack(alignment: .top, spacing: 5) {
                    ForEach(slots.indices, id: \.self) { index in
                        InfiniteLetterPicker(selectedLetter: $slots[index])
                    }
                }

                Button("Submit") {
                    let result = slots.joined().trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
                    let correctAnswer = level.correctAnswer.uppercased()

                    if remaining > 0 {
                        if result == correctAnswer {
                            isCorrect = true
                            showWinPopup = true
                            gameData.markLevelCompleted(levelKey)
                            gameData.addCoins(10)
                        } else {
                            isCorrect = false
                            showFailPopup = true
                            gameData.registerFailedAttempt(for: levelKey)
                        }
                    } else {
                        showFailPopup = true
                    }
                }
                .padding()
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.2))
                    .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.c4.opacity(0.4)))
                    .shadow(color: Color.c4, radius: 10, x: 8, y: 8)
                )
                .padding(.leading, 500)
            }

            // Show Win Popup
            if showWinPopup {
                WinPopup(isPresented: $showWinPopup) {
                    let totalLevels = track.levels.count
                    let totalTracks = tracks.count

                    if trackIndex < totalTracks {
                        if levelIndex + 1 < totalLevels {
                            gameData.playerProgress?.currentLevelIndex = levelIndex + 1
                        } else if trackIndex + 1 < totalTracks {
                            gameData.playerProgress?.currentTrackIndex = trackIndex + 1
                            gameData.playerProgress?.currentLevelIndex = 0
                        } else {
                            // no more levels
                        }
                    }

                    gameData.save()
                    navigateToMap = true
                }
            }

            // Show Fail Popup
            if showFailPopup {
                FailPopup(
                    isPresented: $showFailPopup,
                    attemptsRemaining: remaining,
                    onRetry: {
                        showFailPopup = false
                    },
                    onWait: {
                        showFailPopup = false
                    },
                    onBuyCoins: {
                        showFailPopup = false
                        showStoreSheet = true  // افتح شاشة المتجر
                        if gameData.useCoins(50) {
                            let current = gameData.playerProgress?.failedAttempts[levelKey] ?? 0
                            if current > 0 {
                                gameData.playerProgress?.failedAttempts[levelKey] = current - 1
                            } else {
                                gameData.playerProgress?.failedAttempts[levelKey] = 0
                            }
                            gameData.save()
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showStoreSheet) {
            CoinStoreView()
                .environment(gameData)  // تمرير environment
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
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




struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView()
            .environment(GameDataStore.shared)
    }
}
