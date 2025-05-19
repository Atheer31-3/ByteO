//
//
//import SwiftUI
//import SwiftData
//
//struct InfiniteLetterPicker: View {
//    private let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
//    private let loopCount = 3
//    var allLetters: [String] {
//        Array(repeating: letters, count: loopCount).flatMap { $0 }.map { String($0) }
//    }
//    @Binding var selectedLetter: String
//    @State private var selectedIndex: Int = 0
//
//    var body: some View {
//        ZStack {
//            RoundedRectangle(cornerRadius: 8)
//                .fill(.ultraThinMaterial)
//                .frame(width: 30, height: 30)
//                .shadow(color: .white.opacity(0.1), radius: 2, x: 0, y: 1)
//
//            Picker("", selection: $selectedIndex) {
//                ForEach(0..<allLetters.count, id: \ .self) { i in
//                    Text(allLetters[i])
//                        .font(.title2)
//                        .frame(width: 40, height: 40)
//                }
//            }
//            .pickerStyle(WheelPickerStyle())
//            .frame(width: 50, height: 120)
//            .clipped()
//            .onAppear {
//                if let centerIndex = allLetters.firstIndex(of: selectedLetter) {
//                    selectedIndex = 26 + centerIndex % 26
//                }
//            }
//            .onChange(of: selectedIndex) { newValue in
//                selectedLetter = allLetters[newValue % 26]
//                if newValue <= 1 || newValue >= allLetters.count - 2 {
//                    selectedIndex = 26 + (newValue % 26)
//                }
//            }
//        }
//    }
//}
//
//import SwiftUI
//import SwiftData
//
//struct DecryptionGameView: View {
////    let levelID: Int // ← المستوى الحالي
//         let levelID: UUID
//    @Environment(\.modelContext) private var context
// //   @Query var players: [Player]
//    @Query var gameData: [GameDataStore]
//
//    @State private var selectedQuestion: Question = QuestionBank.shared.questionsByLevel[1]![0]
//    @State private var slots: [String] = ["A", "A", "A", "A", "A"]
//    @State private var showWalletPopup = false
//    @State private var showAttemptsPopup = false
//    @State private var showExitPopup = false
//    @State private var showWinPopup = false
//    @State private var showLosePopup = false
//    @State private var animationOffset: CGFloat = -500
//    @State private var navigateToMainMenu = false
//    @State private var navigateToMap = false
//    @State private var showHintPopup = false
//
//    private var store: GameDataStore {
//      // if you bootstrap in MainMenuView, this will never be nil at runtime
//      gameData.first!
//    }
//
//    private var player: Player {
//      store.player
//    }
//
//
//    /// The actual Level model we’re playing
//    private var currentLevelModel: Level {
//      store.levels.first { $0.id == levelID }!
//    }
//
//    /// The integer “level number” for question lookup, progress, etc.
//    private var currentLevelNumber: Int {
//      currentLevelModel.levelNumber
//    }
//    var body: some View {
//      
//            ZStack {
//                NavigationLink("", destination: MainMenuView(), isActive: $navigateToMainMenu).hidden()
//                NavigationLink(
//                         destination: MetroMapView(),
//                         isActive: $navigateToMap
//                     ) {
//                         EmptyView()
//                     }
//                     .hidden()
//                Color.black.opacity(0.6).edgesIgnoringSafeArea(.all).blur(radius: showHintPopup ? 5 : 0)
//                Image("bg").resizable().edgesIgnoringSafeArea(.all)
//
//                VStack(spacing: 5) {
//                    Button(action: { showExitPopup = true }) {
//                        Image(systemName: "chevron.backward.circle.fill")
//                            .font(.title)
//                            .foregroundColor(.c3)
//                            .frame(width: 50, height: 50)
//                            .background(Color.white.opacity(0.15))
//                            .clipShape(Circle())
//                    }
//                    .alert("هل تريد الخروج من اللعبة؟", isPresented: $showExitPopup) {
//                        Button("نعم", role: .destructive) { navigateToMainMenu = true }
//                        Button("إلغاء", role: .cancel) {}
//                    }
//                 
//                    
////                    NavigationLink(destination: MapView(), isActive: $navigateToMap) { EmptyView() }.hidden()
//
//                    Button(action: { showWalletPopup = true }) {
//                        HStack {
//                            Image(systemName: "wallet.bifold.fill").foregroundColor(.white)
//                            Text("\(player.coins)").foregroundColor(.white).font(.headline)
//                        }
//                        .padding(8).background(Color.white.opacity(0.19)).cornerRadius(12)
//                    }
//                    .alert("رصيدك الحالي هو: \(player.coins) نقطة", isPresented: $showWalletPopup) {
//                        Button("موافق", role: .cancel) {}
//                    }
//
//                    Button(action: { showAttemptsPopup = true }) {
//                        HStack {
//                            Image(systemName: "pawprint.fill").foregroundColor(.white)
//                            Text(" \(max(player.attempts, 0))x      ").foregroundColor(.white).font(.headline)
//                        }
//                        .padding(8).background(Color.white.opacity(0.19)).cornerRadius(12)
//                    }
//                    .alert("لديك \(player.attempts) محاولات متبقية", isPresented: $showAttemptsPopup) {
//                        Button("موافق", role: .cancel) {}
//                    }
//                }
//                .padding(.leading, -410)
//                .padding(.bottom, 190)
//
//                HStack(alignment: .top, spacing: -40) {
//                    ZStack {
//                        RoundedRectangle(cornerRadius: 20)
//                            .fill(.ultraThinMaterial)
//                            .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.c3.opacity(0.8), lineWidth: 1.8))
//                            .shadow(color: Color.c3.opacity(0.3), radius: 10, x: 0, y: 5)
//
//                        VStack(alignment: .leading, spacing: 5) {
//                            Text("Mission \(currentLevelModel.levelNumber) — Caesar Decryption")
//                                .font(.system(size: 18, weight: .bold, design: .monospaced)).foregroundColor(.white)
//                            Text("Encrypted messages : \(selectedQuestion.questionText)")
//                                .font(.system(size: 16, design: .monospaced)).foregroundColor(.white.opacity(0.9))
//                            Text("the Key : \(selectedQuestion.key)")
//                                .font(.system(size: 16, design: .monospaced)).foregroundColor(.white.opacity(0.9))
//                        }
//                        .padding().offset(x: animationOffset)
//                        .onAppear {
//                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.5)) {
//                                animationOffset = 0
//                            }
//                        }
//                        .frame(width: 500, height: 100)
//
//                        Button(action: {
//                            if selectedQuestion.hintUsesAllowed > selectedQuestion.hintUsed {
//                                showHintPopup = true
//                                selectedQuestion.hintUsed += 1
//                            }
//                        }) {
//                            ZStack {
//                                Circle().fill(Color.c21.opacity(0.99)).frame(width: 50, height: 50)
//                                Image(systemName: "lightbulb.fill").font(.title).foregroundColor(.white)
//                            }
//                        }
//                        .padding(.leading, -320)
//                        .padding(.bottom, 50)
//                    }
//                    .frame(width: 500, height: 130)
//
//                    Image("robot_zero")
//                        .resizable()
//                        .frame(width: 200, height: 200)
//                        .padding(.leading, -20)
//                        .offset(x: animationOffset)
//                        .onAppear {
//                            withAnimation(.spring(response: 0.6, dampingFraction: 0.7, blendDuration: 0.5)) {
//                                animationOffset = 0
//                            }
//                        }
//                }
//                .frame(maxWidth: .infinity, alignment: .trailing)
//                .padding(.trailing, -40).padding(.bottom, 140)
//                .alert("💡 تلميح المهمة", isPresented: $showHintPopup) {
//                    Button("موافق") {}
//                } message: {
//                    Text(selectedQuestion.hint)
//                }
//
//                VStack(spacing: -15) {
//                    Text(slots.joined()).font(.system(size: 20, weight: .medium, design: .rounded))
//                        .foregroundColor(.white.opacity(0.8)).padding()
//                        .frame(maxWidth: 250).background(.ultraThinMaterial).cornerRadius(12)
//
//                    HStack(alignment: .top, spacing: 5) {
//                        ForEach(slots.indices, id: \ .self) { index in
//                            InfiniteLetterPicker(selectedLetter: $slots[index])
//                        }
//                    }
//
//                    Button("Submit") {
//                      let result = slots.joined()
//
//                      if result == selectedQuestion.correctAnswer {
//                        showWinPopup = true
//                        //  connect it with the points of the achievments
//                        player.playerScore += 100
//                        player.coins       += 50
//                        store.currentLevel = currentLevelNumber + 1
//                        currentLevelModel.isCompleted = true
//                            
//                        
//                      } else {
//                        // refill after 24h if needed
//                        if let last = player.lastAttemptsReset,
//                           Calendar.current.dateComponents([.hour],
//                             from: last, to: Date()).hour! >= 24 {
//                          player.attempts = 3
//                          player.lastAttemptsReset = Date()
//                        } else if player.lastAttemptsReset == nil {
//                          player.lastAttemptsReset = Date()
//                        }
//
//                        // **this now really mutates the persisted Player**
//                        player.attempts = max(player.attempts - 1, 0)
//                        try? context.save()
//                        showLosePopup = true
//                      }
//
//                      try? context.save()
//                    }
//                    .padding().background(Color.c3.opacity(0.9)).foregroundColor(.white).cornerRadius(12)
//                    .padding(.leading, 500)
//                    
//                   
//                }
//                .padding(.top, 150)
//                //
//                WinPopUp(winPopup: $showWinPopup, navigateToMap: $navigateToMap,navigateToMainMenu: $navigateToMainMenu)
//             
//                FailPopUp(player: player, failPopup: $showLosePopup, navigateToMainMenu: $navigateToMainMenu)
//
//            }
//            .navigationBarBackButtonHidden(true)
//            .navigationBarHidden(true)
//        
//        .onAppear {
//            // lookup by the integer level number
//            // ✅ now we pull right off the Level model
//            if let q = currentLevelModel.questions.first {
//                selectedQuestion = q
//            }
//
//            // عند الدخول تأكد من تعبئة المحاولات إذا مرت 24 ساعة
//            if let last = player.lastAttemptsReset {
//                let hoursPassed = Calendar.current.dateComponents([.hour], from: last, to: Date()).hour ?? 0
//                if hoursPassed >= 24 {
//                    player.attempts = 3
//                    player.lastAttemptsReset = Date()
//                    try? context.save()
//                }
//            } else {
//                player.lastAttemptsReset = Date()
//                try? context.save()
//            }
//        }
//    }
//}
//
