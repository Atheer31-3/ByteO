import SwiftUI

struct MainMenuView: View {
    @Environment(GameDataStore.self) var gameData
    @State private var navigateToIntro = false
    @State private var navigateToGame = false
    @State private var navigateToMap = false
    @State private var navigateToSettings = false
    @State private var navigateToAchievements = false
    @State private var showCoinStore = false


    var body: some View {
        NavigationStack {
            ZStack {
                // 🔵 الخلفية (تقدر تحط صورة أو لون خاص)
                Color.white.ignoresSafeArea()
            
                VStack(spacing: 40) {
                    Spacer()
                    // في الأعلى داخل الواجهة
                    Button(action: {
                        showCoinStore = true
                    }) {
                        HStack {
                            Image(systemName: "bitcoinsign.circle")
                            Text("\(gameData.playerProgress?.coins ?? 0)")
                        }
                    }
                    .sheet(isPresented: $showCoinStore) {
                        CoinStoreView()
                    }
                    // 🧠 عنوان اللعبة
                    Text("لعبة تشفير سيزر")
                        .font(.largeTitle.bold())

                    // 🟢 زر بدء اللعب
                    Button(action: {
                        if gameData.playerProgress?.hasSeenIntro == false {
                            navigateToIntro = true
                        } else {
                            navigateToGame = true
                        }
                    }) {
                        Text("بدء اللعب")
                            .font(.title2.bold())
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    // 🗺️ زر الخريطة
                    Button(action: {
                        navigateToMap = true
                    }) {
                        Text("الخريطة")
                            .font(.title2)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Spacer()

                    // ✅ التنقلات المخفية
                    NavigationLink("", destination: IntroScenarioView(), isActive: $navigateToIntro)
                    NavigationLink("", destination: GameView(), isActive: $navigateToGame)
                    NavigationLink("", destination: MapView(), isActive: $navigateToMap)
                }
                .padding()

                // 🛠️ شريط علوي
                VStack {
                    HStack {
                        Button(action: {
                            navigateToSettings = true
                        }) {
                            Image(systemName: "gearshape")
                                .font(.title2)
                                .padding()
                        }

                        Spacer()

                        // 💰 عدد الكوينز
                        HStack(spacing: 4) {
                            Image(systemName: "bitcoinsign.circle")
                            Text("\(gameData.playerProgress?.coins ?? 0)")
                        }
                        .padding(.trailing)

                        // 🏆 الإنجازات
                        Button(action: {
                            navigateToAchievements = true
                        }) {
                            Image(systemName: "rosette")
                                .font(.title2)
                                .padding()
                        }
                    }
                    .padding(.horizontal)

                    Spacer()
                }

                // ⛳ روابط الإعدادات والإنجازات
                NavigationLink("", destination: SettingsView(), isActive: $navigateToSettings)
                NavigationLink("", destination: AchievementsView(), isActive: $navigateToAchievements)
            }
        }
    }
}
#Preview {
    MainMenuView()
        .environment(GameDataStore.shared)
}
