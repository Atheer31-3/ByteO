
import SwiftUI
struct WinPopup: View {
    @Binding var isPresented: Bool
    var attemptsUsed: Int
    var onContinue: () -> Void
    var onMainMenu: () -> Void

    var filledStars: Int {
        switch attemptsUsed {
        case 0: return 3
        case 1: return 2
        case 2: return 1
        default: return 0
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            // النجوم حسب المحاولات
            HStack(spacing: 10) {
                ForEach(0..<3, id: \.self) { i in
                    Image(systemName: i < filledStars ? "star.fill" : "star")
                        .foregroundColor(.yellow)
                        .font(.system(size: 30))
                        .shadow(radius: 1)
                }
            }

            // القطة و البانر
            ZStack {
                Image("cat_avatar")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .offset(y: -20)

                Image("YellowBanner")
                    .resizable()
                    .frame(width: 180, height: 40)
                    .offset(y: 50)

                Text("Congratulations")
                    .font(.headline)
                    .foregroundColor(.white)
                    .offset(y: 45)
            }

            // الأزرار
            HStack(spacing: 30) {
                Button(action: {
                    isPresented = false
                    onMainMenu()
                }) {
                    Image(systemName: "arrowshape.turn.up.left.fill")
                        .font(.system(size: 22))
                        .frame(width: 50, height: 50)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                }

                Button(action: {
                    isPresented = false
                    onContinue()
                }) {
                    Image(systemName: "chevron.forward.2")
                        .font(.system(size: 22))
                        .frame(width: 50, height: 50)
                        .background(Color.black.opacity(0.4))
                        .cornerRadius(12)
                }
            }
            .padding(.top, 10)
        }
        .padding()
        .frame(width: 350, height: 340)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .shadow(radius: 10)
    }
}




/// هذا يو اي بس عشان اخذ الديزاين منه
//struct WinPopUp: View {
//    @AppStorage("currentLevel") var currentLevel: Int = 0
//
//    @Binding var winPopup: Bool
//    @Binding var navigateToMap: Bool
//    @Binding var navigateToMainMenu: Bool
//    @State private var showExitPopup = false
//
//
//    var body: some View {
//                // Pop-up view when the user pass the mission 
//                if winPopup {
//                    VStack {
//                        Spacer()
//
//                        VStack(spacing: 20) {
//                         
//
//                            HStack(spacing: 70) {
//                                ZStack {
//                                    Image("background") // استبدل "background" باسم صورة الخلفية
//                                        .resizable()
//                                        .scaledToFit()
//                                        .frame(width: 300, height: 300)
//                                        .clipped()
//                                        .offset(y: -30)
//                                 
//                                    VStack {
//                                        HStack(spacing: 5) {
//                                            Image(systemName: "star.fill")
//                                                .foregroundColor(.yellow)
//                                                .font(.system(size: 30))
//                                                .rotationEffect(.degrees(-30))
//
//                                            Image(systemName: "star.fill")
//                                                .foregroundColor(.yellow)
//                                                .font(.system(size: 40))
//                                                .rotationEffect(.degrees(0))
//                                                .offset(y: -10)
//
//                                            Image(systemName: "star.fill")
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
//                                            Text("Congratulations") // النص الذي سيظهر فوق الصورة
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
//                                                
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
//                                            // close Win pop-up
//                                                winPopup = false
//                                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
//                                                    //navigate to map 
//                                                  navigateToMap = true
//                                                }
//                                            }) {
//                                                HStack(spacing: 5) {
//                                                    Image("fast-forward")
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
//                                            }
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
//                        .background(.ultraThinMaterial)
//                        .background(
//                            ZStack {
//                                Color.black.opacity(0.5)
//                                    .cornerRadius(20)
//                                
//                            }
//                        )
//                        .cornerRadius(20)
//                        .padding()
//                    }
//                    .transition(.move(edge: .bottom))
//                }
//
//        
//    
//        }
//    }
//
//
//struct WinPopUp_Previews: PreviewProvider {
//    static var previews: some View {
//        WinPopUp(winPopup:.constant(true), navigateToMap:.constant(false), navigateToMainMenu: .constant(false))
//    }
//}
