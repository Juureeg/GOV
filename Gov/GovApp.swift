import SwiftUI

@main
struct GovApp: App {
    @StateObject private var userManager = UserManager.shared
    
    var body: some Scene {
        WindowGroup {
            if userManager.isLoading && !userManager.isLoggedIn {
                LoadingView()
            } else if userManager.isLoggedIn {
                CompleteDocumentApp()
                    .environmentObject(userManager)
            } else {
                LoginView()
            }
        }
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0),
                    Color(red: 0x1a/255.0, green: 0x4a/255.0, blue: 0x8a/255.0)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Text("gov.br")
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(.white)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
    }
}
