////  FailPopUp.swift
////  ByteO
////  Created by Shatha Almukhaild on 18/11/1446 AH.
//

import SwiftUI
import SwiftData
// ✅ FailPopup الجديد بشكل القط مع النجوم والمتجر


struct FailPopup: View {
    @Binding var isPresented: Bool
    var attemptsRemaining: Int
    var onRetry: () -> Void
    var onWait: () -> Void
    var onBuyCoins: () -> Void
    var navigateToMainMenu: () -> Void

    var body: some View {
        if isPresented {
            ZStack {
                Color.black.opacity(0.3)
                    .edgesIgnoringSafeArea(.all)

              VStack(spacing: 20) {
                    // ⭐ النجوم المرتبطة بعدد المحاولات
                    HStack(spacing: 15) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < attemptsRemaining ? "star.fill" : "star")
                                .resizable()
                                .frame(width: 28, height: 28)
                                .foregroundColor(i < attemptsRemaining ? .yellow : .gray)
                                .shadow(radius: i < attemptsRemaining ? 4 : 0)
                        }
                    }
                    .padding(.bottom, 5)

                    // 🐱 صورة القطة والبنر
                    ZStack {
                        Image("cat_avatar")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 140, height: 140)

                        Image("YellowBanner")
                            .resizable()
                            .frame(width: 160, height: 38)
                            .offset(y: 60)

                        Text("FAILED !")
                            .font(.headline)
                            .foregroundColor(.white)
                            .offset(y: 55)
                    } .offset(y: 30)

                    // 🐾 المحاولات
                    HStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { i in
                            Image(systemName: i < attemptsRemaining ? "pawprint.fill" : "pawprint")
                                .resizable()
                                .frame(width: 25, height: 25)
                                .foregroundColor(i < attemptsRemaining ? .white : .gray)
                        }
                    }.offset(y: 28)

                    // 📦 أزرار الخيارات
                    HStack(spacing: 20) {
                        Button(action: navigateToMainMenu) {
                            Image(systemName: "xmark")
                                .font(.system(size: 20))
                                .frame(width: 60, height: 50)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(10)
                        }

                        Button(action: {
                            if attemptsRemaining > 0 {
                                isPresented = false
                                onRetry()
                            } else {
                                onBuyCoins()
                            }
                        }) {
                            Image(systemName: "arrow.clockwise")
                                .font(.system(size: 22))
                                .frame(width: 60, height: 50)
                                .background(Color.black.opacity(0.4))
                                .cornerRadius(10)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
                .frame(width: 350, height: 350)
                //.background(.ultraThinMaterial)
//                .cornerRadius(25)
//                .shadow(radius: 10)
//                .padding()
//                .frame(width: 320, height: 400)
//                .background(.ultraThinMaterial)
//                .cornerRadius(25)
//                .shadow(radius: 10)
                .background(
                    ZStack{
                        Color.black.opacity(0.5)
                            .cornerRadius(20)
                            //.background(.ultraThinMaterial)
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.3),lineWidth: 0.3)
                            .shadow(color: Color.blue.opacity(0.3), radius: 50, x: 10, y: 10)
                    }
                    )
            }
        }
    }
}

//
//هذا كود يو اي بس 
//struct FailPopUp: View {
//
//
//    @Environment(\.modelContext) private var context
//    @Bindable var player: Player
//    @AppStorage("currentLevel") var currentLevel: Int = 0
//    @State private var showPurchaseAlert = false
//
//    @Binding var failPopup: Bool // Show pop-up
//    @Binding var navigateToMainMenu: Bool
//    @State private var showExitPopup = false
//    var body: some View {
//    
//            if failPopup {
//                // Pop-up view when the user fail the mission
//                    VStack {
//                        Spacer()
//
//                        VStack(spacing: 20) {
//                            HStack(spacing: 70) {
//                                ZStack {
//                                    VStack {
//                                        HStack(spacing: 5) {
//                                            Image(systemName: "star")
//                                                .foregroundColor(.yellow)
//                                                .font(.system(size: 30))
//                                                .rotationEffect(.degrees(-30))
//
//                                            Image(systemName: "star")
//                                                .foregroundColor(.yellow)
//                                                .font(.system(size: 40))
//                                                .rotationEffect(.degrees(0))
//                                                .offset(y: -10)
//
//                                            Image(systemName: "star")
//                                                .foregroundColor(.yellow)
//                                                .font(.system(size: 30))
//                                                .rotationEffect(.degrees(30))
//                                        }
//                                       // .padding(.bottom,15)
//                                        Spacer()
//                                        ZStack{
//                                            Image("cat_avatar")
//                                                .resizable()
//                                                .aspectRatio(contentMode: .fit)
//                                                .frame(width: 150, height: 150)
//                                                .frame(width: 500)
//                                                .offset(y: -30)
//
//                                            Image("YellowBanner")
//                                                .resizable()
//                                                .frame(width: 180, height: 40)
//                                                .offset(y: 50)
//                                            
//                                            Text("Failed") // النص الذي سيظهر فوق الصورة
//                                                .font(.headline)
//                                                .foregroundColor(.white)
//                                                .padding()
//                                                .background(Color.clear.opacity(0.7)) // خلفية بنية اللون مع شفافية
//                                                //.cornerRadius(10)
//                                                .offset(y: 45) // تحريك النص فوق الصورة
//                                        }
//                                        Spacer()
//                                        HStack{
//                                            Button(action: {
//                                                showExitPopup = true
//
//                                            }) {
//                                                HStack(spacing: 5) {
//                                                    Image("exit")
//                                                        .resizable()
//                                                        .frame(width: 20, height: 20)
//                                                }
//                                                .frame(width: 60, height: 50)
//                                                .background(Color.black.opacity(0.4))
//                                                .cornerRadius(10)
//                                                .overlay(
//                                                    RoundedRectangle(cornerRadius: 15)
//                                                        .stroke(Color.clear, lineWidth: 0.5)
//                                                )
//                                                .shadow(color: .white.opacity(0.9), radius: 10, x: 2, y: 2)
//                                                .offset(y: -30)
//                                            }.alert("هل تريد الخروج من اللعبة؟", isPresented: $showExitPopup) {
//                                                Button("نعم", role: .destructive) { navigateToMainMenu = true }
//                                                Button("إلغاء", role: .cancel) {}
//                                            }
//                                            Button(action: {
//                                                //محاولات متبقية ؟ اغلاق نافذة الخساره وإكمال اللعب
//                                                if player.attempts > 0 {
//                                                    //Dismiss the pop-up
//                                                    failPopup=false
//                                                }
//                                                // خلصت المحاولات ؟ انتظر ٢٤ ساعة او اشتر محاولات
//                                                else {
//                                                    showPurchaseAlert = true
//                                                }}) {
//                                                HStack(spacing: 5) {
//                                                    Image("Replay")
//                                                        .resizable()
//                                                        .frame(width: 20, height: 23)
//                                                }
//                                                .frame(width: 60, height: 50)
//                                                .background(Color.black.opacity(0.4))
//                                                .cornerRadius(10)
//                                                .overlay(
//                                                    RoundedRectangle(cornerRadius: 15)
//                                                        .stroke(Color.clear, lineWidth: 0.5)
//                                                )
//                                                .shadow(color: .white.opacity(0.9), radius: 10, x: 2, y: 2)
//                                                .offset(y: -30)
//                                            }.alert("❌", isPresented: $showPurchaseAlert) {
//                                                if player.attempts <= 0 {
//                                                    Button("Buy an Attempt for 50 coins") {
//                                                        if player.coins >= 50 {
//                                                            player.coins -= 50
//                                                            player.attempts = 1
//                                                            player.lastAttemptsReset = Date()
//                                                        }
//                                                        try? context.save()
//                                                        // Dissmiss the popup
//                                                        failPopup = false
//                                                    }
//                                                    Button("Wait for 24 hours", role: .cancel) {
//                                                        navigateToMainMenu = true
//                                                    }
//                                                }
//                                            } message: {
//                                                VStack(spacing: 12) {
//                                                    Text(player.attempts <= 0 ? "Incorrect Answer !": "You run out of attempts!")
//                                                    HStack {
//                                                        ForEach(0..<3, id: \ .self) { i in
//                                                            Image(systemName: i < player.attempts ? "pawprint.fill" : "pawprint")
//                                                                .foregroundColor(i < player.attempts ? .white : .gray)
//                                                        }
//                                                    }
//                                                }
//                                            }
//
//                                        }
//
//                                    }
//                                }
//                            }
//                            .padding()
//                            .cornerRadius(15)
//                            .shadow(radius: 10)
//                        }
//                        .frame(width: 350, height: 350)
//                        .background(
//                            ZStack {
//                                Color.black.opacity(0.5)
//                                    .cornerRadius(20)
//                                .background(.ultraThinMaterial)
//                            }
//                        )
//                        .cornerRadius(20)
//                        .padding()
//                    }
//                    .transition(.move(edge: .bottom))
//                
//
//            }
//   
//        }
//    }
//
//
////struct FailPopUp_Previews: PreviewProvider {
////    static var previews: some View {
////        FailPopUp(player: player, failPopup:.constant(true) ,navigateToMainMenu: .constant(false))
////    }
////}
