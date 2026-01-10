// CompleteDocumentAppFinalData.swift (Final Data page with titles in squares)

import SwiftUI
import UIKit
import PhotosUI
import AVFoundation
import LocalAuthentication

// MARK: - Main App Structure
struct CompleteDocumentApp: View {
    @State private var showingDetailView = false
    @State private var showingDataView = false
    @State private var showingHomeView = true // Start on home page
    @State private var currentView = "Início" // Start with home view
    @State private var showingSideMenu = false // Side menu state
    @State private var biometricLoginEnabled = false // Biometric setting
    @State private var isAuthenticated = false // Authentication state
    @State private var showingBiometricAuth = false // Biometric auth screen
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Check if biometric auth is needed
                if biometricLoginEnabled && !isAuthenticated {
                    BiometricAuthView(
                        isAuthenticated: $isAuthenticated,
                        biometricLoginEnabled: $biometricLoginEnabled
                    )
                } else {
                    // Main content
                    if showingHomeView {
                        HomeView(showingHomeView: $showingHomeView, showingDetailView: $showingDetailView, showingDataView: $showingDataView, currentView: $currentView, showingSideMenu: $showingSideMenu, biometricLoginEnabled: $biometricLoginEnabled)
                            .navigationBarHidden(true)
                    } else if showingDetailView {
                        DocumentDetailView(showingDetailView: $showingDetailView, currentView: $currentView, showingDataView: $showingDataView, showingHomeView: $showingHomeView, showingSideMenu: $showingSideMenu, biometricLoginEnabled: $biometricLoginEnabled)
                            .navigationBarHidden(true)
                    } else if showingDataView {
                        DataView(showingDataView: $showingDataView, currentView: $currentView, showingHomeView: $showingHomeView, showingSideMenu: $showingSideMenu, biometricLoginEnabled: $biometricLoginEnabled)
                            .navigationBarHidden(true)
                    } else {
                        DocumentWalletView(showingDetailView: $showingDetailView, showingDataView: $showingDataView, showingHomeView: $showingHomeView, currentView: $currentView, showingSideMenu: $showingSideMenu, biometricLoginEnabled: $biometricLoginEnabled)
                            .navigationBarHidden(true)
                    }
                    
                    // Side menu overlay
                    if showingSideMenu {
                        SideMenuView(showingSideMenu: $showingSideMenu, biometricLoginEnabled: $biometricLoginEnabled, isAuthenticated: $isAuthenticated)
                            .transition(.move(edge: .leading))
                            .zIndex(1)
                    }
                }
            }
        }
        .onAppear {
            // Check if biometric auth should be required on app start
            if biometricLoginEnabled {
                isAuthenticated = false
            } else {
                isAuthenticated = true
            }
        }
    }
}

// MARK: - Document Wallet View (Main Screen)
struct DocumentWalletView: View {
    @Binding var showingDetailView: Bool
    @Binding var showingDataView: Bool
    @Binding var showingHomeView: Bool
    @Binding var currentView: String
    @Binding var showingSideMenu: Bool
    @Binding var biometricLoginEnabled: Bool
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top logo section
                HStack {
                    Image("your_logo")
                        .resizable()
                        .frame(width: 64, height: 24)
                        .padding(.leading, 16)
                    
                    Spacer()
                    
                    // Profile photo - CLICKABLE for Data page
                    Button(action: {
                        currentView = "Data"
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingDataView = true
                        }
                    }) {
                        Image("profile_photo")
                            .resizable()
                            .scaledToFill()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color.white)
                
                // Navigation bar
                HStack {
                    Button(action: {
                        // Back action
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    Text("Carteira de documentos")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 30)
                        .padding(.trailing, 16)
                }
                .frame(height: 64)
                .background(Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0))
                
                // Content area
                ScrollView {
                    VStack(spacing: 20) {
                        // ID Card
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingDetailView = true
                            }
                        }) {
                            IDCardView()
                        }
                        .buttonStyle(PlainButtonStyle())
                        .padding(.horizontal, 32)
                        .padding(.top, 10)
                        
                        Spacer(minLength: 100)
                    }
                }
                .background(Color.white)
                
                Spacer()
                
                // Add Document Button
                VStack {
                    Button(action: {
                        print("Adicionar Documento tapped")
                    }) {
                        Text("Adicionar Documento")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth:250)
                            .padding(.vertical, 16)
                            .background(Color(red: 0x15/255.0, green: 0x8c/255.0, blue: 0x26/255.0))
                            .cornerRadius(25)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
                .background(Color.white)
            }
        }
        .overlay(BottomNavBarView(showingDataView: $showingDataView, showingDetailView: $showingDetailView, showingHomeView: $showingHomeView, currentView: $currentView, showingSideMenu: $showingSideMenu), alignment: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .preferredColorScheme(.light)
        .onAppear {
            currentView = "Carteira"
        }
    }
}

// MARK: - Data View (Personal Data Page) - FINAL VERSION
struct DataView: View {
    @Binding var showingDataView: Bool
    @Binding var currentView: String
    @Binding var showingHomeView: Bool
    @Binding var showingSideMenu: Bool
    @Binding var biometricLoginEnabled: Bool
    @State private var scrollOffset: CGFloat = 0
    @State private var showEditButton = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top logo section
                HStack {
                    Image("your_logo")
                        .resizable()
                        .frame(width: 64, height: 24)
                        .padding(.leading, 16)
                    
                    Spacer()
                    
                    // Profile photo
                    Image("profile_photo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .padding(.trailing, 16)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color.white)
                
                // Navigation bar
                HStack {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingDataView = false
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                    }
                    .padding(.leading, 16)
                    
                    Spacer()
                    
                    Text("Dados pessoais")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Color.clear
                        .frame(width: 30)
                        .padding(.trailing, 16)
                }
                .frame(height: 64)
                .background(Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0))
                
                // Content with scroll detection
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(spacing: 0) {
                            // Large profile photo section
                            ZStack {
                                Image("profile_photo")
                                    .resizable()
                                    .scaledToFill()
                                    .frame(height: 300)
                                    .clipped()
                            }
                            .background(
                                // Fallback if image doesn't load
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .overlay(
                                        Image(systemName: "person.fill")
                                            .font(.system(size: 80))
                                            .foregroundColor(.gray.opacity(0.6))
                                    )
                            )
                            
                            // Data sections with floating squares - TITLES INSIDE SQUARES
                            VStack(spacing: 24) {
                                // FIRST FLOATING SQUARE - Dados básicos (TITLE INSIDE + BOLD)
                                VStack(spacing: 0) {
                                    // Title inside the square - BOLD
                                    HStack {
                                        Text("Dados básicos")
                                            .font(.system(size: 18, weight: .bold)) // MADE BOLD
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 20)
                                    .padding(.bottom, 16)
                                    
                                    // Data rows - NO DIVIDERS
                                    DataRowView(
                                        icon: "person.fill",
                                        iconColor: .blue,
                                        label: "Nome",
                                        value: "ARTHUR GOMES"
                                    )
                                    
                                    DataRowView(
                                        icon: "calendar",
                                        iconColor: .blue,
                                        label: "Nascimento",
                                        value: "16/02/2007"
                                    )
                                    
                                    DataRowView(
                                        icon: "location.fill",
                                        iconColor: .blue,
                                        label: "Naturalidade",
                                        value: "FLORIANOPOLIS/SC"
                                    )
                                    
                                    DataRowView(
                                        icon: "person.fill",
                                        iconColor: .blue,
                                        label: "Nome da Mãe",
                                        value: "CELIA REGINA GONCALVES GOMES"
                                    )
                                    
                                    DataRowView(
                                        icon: "creditcard.fill",
                                        iconColor: .blue,
                                        label: "CPF",
                                        value: "137.244.887-00"
                                    )
                                    .padding(.bottom, 20) // Bottom padding for last item
                                }
                                .background(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 16)
                                .padding(.top, 24)
                                
                                // SECOND FLOATING SQUARE - Dados de contato (TITLE INSIDE + BOLD)
                                VStack(spacing: 0) {
                                    // Title inside the square - BOLD
                                    HStack {
                                        Text("Dados de contato")
                                            .font(.system(size: 18, weight: .bold)) // MADE BOLD
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 20)
                                    .padding(.bottom, 16)
                                    
                                    // Data rows - NO DIVIDERS
                                    DataRowView(
                                        icon: "phone.fill",
                                        iconColor: .blue,
                                        label: "Telefone",
                                        value: "(41) 99234-8889"
                                    )
                                    
                                    DataRowView(
                                        icon: "envelope.fill",
                                        iconColor: .blue,
                                        label: "E-mail",
                                        value: "arthurmalucelli89@gmail.com"
                                    )
                                    
                                    DataRowView(
                                        icon: "location.circle.fill",
                                        iconColor: .blue,
                                        label: "Endereço",
                                        value: "Não encontrado"
                                    )
                                    .padding(.bottom, 20) // Bottom padding for last item
                                }
                                .background(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 16)
                                
                                // Bottom spacer to trigger edit button
                                Color.clear
                                    .frame(height: 200)
                                    .id("bottom")
                            }
                        }
                        .background(
                            GeometryReader { geometry in
                                Color.clear.preference(
                                    key: ScrollOffsetPreferenceKey.self,
                                    value: geometry.frame(in: .named("scroll")).minY
                                )
                            }
                        )
                    }
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        // Show edit button when scrolled near bottom
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showEditButton = value < -400 // Adjust threshold as needed
                        }
                    }
                }
                .background(Color.white)
            }
            
            // Edit button - ONLY APPEARS WHEN SCROLLED TO BOTTOM
            if showEditButton {
                VStack {
                    Spacer()
                    Button(action: {
                        print("Editar tapped")
                    }) {
                        Text("Editar")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0))
                            .cornerRadius(8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                    .background(Color.white)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .overlay(BottomNavBarView(showingDataView: $showingDataView, showingDetailView: .constant(false), showingHomeView: $showingHomeView, currentView: $currentView, showingSideMenu: $showingSideMenu), alignment: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .preferredColorScheme(.light)
        .onAppear {
            currentView = "Dados"
        }
    }
}

// MARK: - Scroll Offset Preference Key
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

// MARK: - Data Row Component (Updated - NO DIVIDERS)
struct DataRowView: View {
    let icon: String
    let iconColor: Color
    let label: String
    let value: String
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 20, weight: .medium))
                .foregroundColor(Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0))
                .frame(width: 24, height: 24)
            
            // Content
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0).opacity(0.7))
                
                Text(value)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
            }
            
            Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12) // Reduced padding since no dividers
    }
}

// MARK: - Corner Ribbon Component
struct CornerRibbon: View {
    let text: String
    let size: CGFloat
    
    var body: some View {
        ZStack {
            // Main triangle
            Path { path in
                path.move(to: CGPoint(x: 0, y: 0))
                path.addLine(to: CGPoint(x: size, y: 0))
                path.addLine(to: CGPoint(x: 0, y: size))
                path.closeSubpath()
            }
            .fill(Color.yellow)
            
            // Small fold effect triangle (darker)
            Path { path in
                let foldSize: CGFloat = size * 0.15
                path.move(to: CGPoint(x: 0, y: foldSize))
                path.addLine(to: CGPoint(x: foldSize, y: 0))
                path.addLine(to: CGPoint(x: 0, y: 0))
                path.closeSubpath()
            }
            .fill(Color.yellow.opacity(0.7))
            
            // Text - GREEN COLOR
            Text(text)
                .font(.system(size: size * 0.3, weight: .bold))
                .foregroundColor(.green)
                .offset(x: -size * 0.20, y: -size * 0.15)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - ID Card Component
struct IDCardView: View {
    var body: some View {
        VStack(spacing: 0) {
            // Card header with light blue background
            ZStack {
                // Banner background image
                Image("BannerCarteira")
                    .resizable()
                    .scaledToFill()
                    .scaleEffect(1.9)
                    .frame(height: UIScreen.main.bounds.height * 0.173)
                    .offset(x: -147, y:71)
                    .clipped()
                
                // Corner Ribbon with ID
                VStack {
                    HStack {
                        CornerRibbon(text: "ID", size: 40)
                        Spacer()
                    }
                    Spacer()
                }
                
                // Card content - MOVED LEFT AND UP
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Carteira de Identidade")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.black)
                        
                        Text("ARTHUR GOMES")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.gray)
                    }
                    .offset(x: 10, y: -35)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                
                // Brazilian coat of arms watermark
                HStack {
                    Spacer()
                    VStack {
                        Spacer()
                        Image(systemName: "shield.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white.opacity(0.1))
                            .padding(.trailing, 20)
                            .padding(.bottom, 10)
                    }
                }
            }
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 20,
                    bottomLeadingRadius: 0,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 20
                )
            )
            
            // Card footer with CPF info
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("CPF")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.gray)
                        
                        Text("137.244.887-00")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.black)
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .frame(height: UIScreen.main.bounds.height * 0.0865)
            .background(Color.white)
            .clipShape(
                UnevenRoundedRectangle(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 20,
                    topTrailingRadius: 0
                )
            )
        }
        .background(Color.white)
        .cornerRadius(20)
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Document Detail View
struct DocumentDetailView: View {
    @Binding var showingDetailView: Bool
    @Binding var currentView: String
    @Binding var showingDataView: Bool
    @Binding var showingHomeView: Bool
    @Binding var showingSideMenu: Bool
    @Binding var biometricLoginEnabled: Bool
    
    // State management
    @State private var currentPage = 0
    @State private var idCardImages: [UIImage] = [
        UIImage(named: "id_card2"),
        UIImage(named: "id_card3"),
        UIImage(named: "id_card4"),
        UIImage(named: "id_card5")
    ].compactMap { $0 }
    @State private var selectedPhotoItem: PhotosPickerItem? = nil
    @State private var isPickerShowing = false
    @State private var isZooming = false
    @State private var isMenuExpanded = false
    
    let photoArea = CGRect(x: 109, y: 45, width: 280, height: 210)

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header with logo
                HStack {
                    Image("your_logo")
                        .resizable()
                        .frame(width: 64, height: 24)
                        .padding(.leading, 16)
                        .onLongPressGesture(minimumDuration: 2) {
                            print("Logo long-pressed, showing photo picker.")
                            isPickerShowing = true
                        }
                    
                    Spacer()
                    
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showingDetailView = false
                        }
                    }) {
                        Image(systemName: "xmark").foregroundColor(Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0)).padding(8)
                            .background(Color.white.opacity(0.8)).clipShape(Circle())
                    }.padding(.trailing, 16)
                }.padding(.top, 8)

                // gov.br banner
                Text("DOCUMENTO DE IDENTIFICAÇÃO").font(.system(size: 9)).foregroundColor(.green)
                    .padding(.horizontal, 8).padding(.vertical, 4).background(Color.yellow)
                    .padding(.top, 8)

                // Image Carousel
                TabView(selection: $currentPage) {
                    ForEach(0..<idCardImages.count, id: \.self) { index in
                        Image(uiImage: idCardImages[index])
                            .resizable().scaledToFit().padding(.horizontal, 24)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(height: 530).padding(.vertical, 16)

                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<idCardImages.count, id: \.self) { index in
                        Circle().fill(index == currentPage ? Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0) : Color.gray.opacity(0.3))
                            .frame(width: 10, height: 10)
                    }
                }.padding(.bottom, 16)

                Spacer()
                Color.clear.frame(height: 80)
            }

            // Floating Buttons
            VStack {
                Spacer()
                HStack(alignment: .bottom) {
                    // Zoom Button
                    Button(action: { isZooming = true }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(Color.white)
                                .frame(width: 48, height: 48)
                                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
                            Image(systemName: "plus.magnifyingglass").resizable().scaledToFit()
                                .frame(width: 28, height: 28)
                                .foregroundColor(Color.gray)
                        }
                    }.padding(.leading, 16)

                    Spacer()

                    // Main floating action button
                    HStack {
                        Spacer()
                        
                        Button(action: {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isMenuExpanded.toggle()
                            }
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(isMenuExpanded ? Color(red: 0x15/255.0, green: 0x8c/255.0, blue: 0x26/255.0).opacity(0.7) : Color(red: 0x15/255.0, green: 0x8c/255.0, blue: 0x26/255.0))
                                    .frame(width: 48, height: 48)
                                    .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                                
                                Image(systemName: "ellipsis")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.white)
                                    .rotationEffect(.degrees(90))
                            }
                        }
                        .padding(.trailing, 16)
                    }
                }
                .padding(.bottom, 110)
            }

            // Dark overlay when menu is expanded
            if isMenuExpanded {
                Color.black.opacity(0.6)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isMenuExpanded = false
                        }
                    }
            }

            // Menu buttons
            if isMenuExpanded {
                VStack {
                    Spacer()
                    
                    HStack {
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 10) {
                            FloatingMenuButton(icon: "trash.fill", title: "Remover documento") {
                                print("Remover documento tapped")
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isMenuExpanded = false
                                }
                            }
                            
                            FloatingMenuButton(icon: "square.and.arrow.up", title: "Compartilhar documento") {
                                print("Compartilhar documento tapped")
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isMenuExpanded = false
                                }
                            }
                            
                            FloatingMenuButton(icon: "star.fill", title: "Favoritar documento") {
                                print("Favoritar documento tapped")
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    isMenuExpanded = false
                                }
                            }
                            
                            Color.clear.frame(height: 48)
                        }
                        .padding(.trailing, 16)
                    }
                    .padding(.bottom, 110)
                }
            }
        }
        .overlay(BottomNavBarView(showingDataView: $showingDataView, showingDetailView: $showingDetailView, showingHomeView: $showingHomeView, currentView: $currentView, showingSideMenu: $showingSideMenu), alignment: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .photosPicker(isPresented: $isPickerShowing, selection: $selectedPhotoItem, matching: .images)
        .onChange(of: selectedPhotoItem) { _, newItem in
            Task {
                guard let data = try? await newItem?.loadTransferable(type: Data.self) else { return }
                guard let userPhoto = UIImage(data: data) else { return }
                
                guard let rotatedUserPhoto = rotate(image: userPhoto) else {
                    print("Failed to rotate image.")
                    return
                }
                
                let templateName = "id_card\(currentPage + 2)"
                guard let idTemplate = UIImage(named: templateName) else { return }

                if let finalUIImage = composite(idTemplate: idTemplate, with: rotatedUserPhoto, in: photoArea) {
                    idCardImages[currentPage] = finalUIImage
                }
            }
        }
        .fullScreenCover(isPresented: $isZooming) {
            SimpleZoomView(image: idCardImages[currentPage], isPresented: $isZooming)
        }
        .onAppear {
            currentPage = 0
            currentView = "Detail"
        }
        .preferredColorScheme(.light)
    }
}

// MARK: - Simple Zoom View
struct SimpleZoomView: View {
    let image: UIImage
    @Binding var isPresented: Bool
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Color.black.ignoresSafeArea()
            
            Image(uiImage: image)
                .resizable()
                .scaledToFit()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                            .onChanged { value in
                                scale = lastScale * value
                            }
                            .onEnded { _ in
                                lastScale = scale
                                if scale < 1.0 {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        scale = 1.0
                                        lastScale = 1.0
                                        offset = .zero
                                        lastOffset = .zero
                                    }
                                } else if scale > 5.0 {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        scale = 5.0
                                        lastScale = 5.0
                                    }
                                }
                            },
                        DragGesture()
                            .onChanged { value in
                                offset = CGSize(
                                    width: lastOffset.width + value.translation.width,
                                    height: lastOffset.height + value.translation.height
                                )
                            }
                            .onEnded { _ in
                                lastOffset = offset
                            }
                    )
                )
                .onTapGesture(count: 2) {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        if scale > 1.0 {
                            scale = 1.0
                            lastScale = 1.0
                            offset = .zero
                            lastOffset = .zero
                        } else {
                            scale = 2.0
                            lastScale = 2.0
                        }
                    }
                }
            
            Button(action: { isPresented = false }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()
            }
        }
    }
}

// MARK: - Floating Menu Button Component
struct FloatingMenuButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .frame(width: 20, height: 20)
                
                Text(title)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.9))
                    .lineLimit(1)
                    .fixedSize()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.black.opacity(0.3))
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(.ultraThinMaterial.opacity(0.5))
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Home View (gov.br Interface)
struct HomeView: View {
    @Binding var showingHomeView: Bool
    @Binding var showingDetailView: Bool
    @Binding var showingDataView: Bool
    @Binding var currentView: String
    @Binding var showingSideMenu: Bool
    @Binding var biometricLoginEnabled: Bool
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top logo section
                HStack {
                    Image("your_logo")
                        .resizable()
                        .frame(width: 80, height: 30)
                        .padding(.leading, 16)
                    
                    Spacer()
                    
                    // Notification and profile
                    HStack(spacing: 12) {
                        // Notification bell with green badge
                        ZStack {
                            Image(systemName: "bell.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.gray)
                            
                            // Green notification badge
                            Circle()
                                .fill(Color.green)
                                .frame(width: 20, height: 20)
                                .overlay(
                                    Text("1")
                                        .font(.system(size: 12, weight: .bold))
                                        .foregroundColor(.white)
                                )
                                .offset(x: 8, y: -8)
                        }
                        
                        // Profile photo - clickable for Data page
                        Button(action: {
                            currentView = "Dados"
                            withAnimation(.easeInOut(duration: 0.3)) {
                                showingHomeView = false
                                showingDataView = true
                            }
                        }) {
                            Image("profile_photo")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        }
                    }
                    .padding(.trailing, 16)
                }
                .padding(.top, 8)
                .padding(.bottom, 16)
                .background(Color.white)
                
                ScrollView {
                    VStack(spacing: 0) {
                        // Blue banner section
                        ZStack {
                            // Blue solid background
                            Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0)
                            .frame(height: 125)
                            
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Olá, ARTHUR")
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("SUA CONTA É NÍVEL OURO")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.white.opacity(0.9))
                                    
                                    // Progress bars
                                    HStack(spacing: 8) {
                                        ForEach(0..<3) { index in
                                            RoundedRectangle(cornerRadius: 2)
                                                .fill(Color.yellow)
                                                .frame(height: 6)
                                        }
                                    }
                                    .padding(.top, 8)
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                        
                        // Search bar section
                        VStack(spacing: 20) {
                            HStack {
                                HStack {
                                    Text("Encontre serviços do Governo do Br...")
                                        .foregroundColor(.gray)
                                        .font(.system(size: 16))
                                    
                                    Spacer()
                                    
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0))
                                        .font(.system(size: 18))
                                }
                                .padding(.horizontal, 16)
                                .padding(.vertical, 12)
                                .background(Color.gray.opacity(0.1))
                            }
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                            
                            // Services section with floating squares
                            VStack(spacing: 24) {
                                // FIRST FLOATING SQUARE - Serviços (TITLE INSIDE + BOLD)
                                VStack(spacing: 0) {
                                    // Title inside the square - BOLD
                                    HStack {
                                        Text("Serviços")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 20)
                                    .padding(.bottom, 16)
                                    
                                    // Service items - WITH DIVIDERS
                                    ServiceItemView(
                                        icon: "calendar.badge.plus",
                                        title: "Agenda gov.br",
                                        badge: .novo
                                    )
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.horizontal, 16)
                                    
                                    ServiceItemView(
                                        icon: "envelope.fill",
                                        title: "Caixa Postal",
                                        badge: .novo
                                    )
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.horizontal, 16)
                                    
                                    ServiceItemView(
                                        icon: "creditcard.fill",
                                        title: "Carteira de documentos",
                                        badge: .number(3)
                                    ) {
                                        // Navigate to wallet
                                        currentView = "Carteira"
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showingHomeView = false
                                        }
                                    }
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.horizontal, 16)
                                    
                                    ServiceItemView(
                                        icon: "signature",
                                        title: "Assinar documentos digitalmente",
                                        badge: .none
                                    )
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.horizontal, 16)
                                    
                                    ServiceItemView(
                                        icon: "magnifyingglass",
                                        title: "Consultar serviços solicitados",
                                        badge: .none
                                    )
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.horizontal, 16)
                                    
                                    ServiceItemView(
                                        icon: "doc.text.fill",
                                        title: "Baixar certidões",
                                        badge: .none
                                    )
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.horizontal, 16)
                                    
                                    ServiceItemView(
                                        icon: "qrcode",
                                        title: "Login sem senha (QR code)",
                                        badge: .none
                                    )
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.horizontal, 16)
                                    
                                    ServiceItemView(
                                        icon: "person.badge.shield.checkmark.fill",
                                        title: "Prova de vida",
                                        badge: .none
                                    )
                                    .padding(.bottom, 20) // Bottom padding for last item
                                }
                                .background(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 16)
                                
                                // SECOND FLOATING SQUARE - Minha conta (TITLE INSIDE + BOLD)
                                VStack(spacing: 0) {
                                    // Title inside the square - BOLD
                                    HStack {
                                        Text("Minha conta")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.gray)
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.top, 20)
                                    .padding(.bottom, 16)
                                    
                                    // Account items - WITH DIVIDERS
                                    ServiceItemView(
                                        icon: "person.text.rectangle.fill",
                                        title: "Dados pessoais",
                                        badge: .none
                                    ) {
                                        // Navigate to data page
                                        currentView = "Dados"
                                        withAnimation(.easeInOut(duration: 0.3)) {
                                            showingHomeView = false
                                            showingDataView = true
                                        }
                                    }
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.horizontal, 16)
                                    
                                    ServiceItemView(
                                        icon: "shield.lefthalf.filled",
                                        title: "Segurança da conta",
                                        badge: .none
                                    )
                                    
                                    Divider()
                                        .background(Color.gray.opacity(0.3))
                                        .padding(.horizontal, 16)
                                    
                                    ServiceItemView(
                                        icon: "lock.fill",
                                        title: "Privacidade",
                                        badge: .none
                                    )
                                    .padding(.bottom, 20) // Bottom padding for last item
                                }
                                .background(Color.white)
                                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
                                .padding(.horizontal, 16)
                            }
                            
                            Spacer(minLength: 100)
                        }
                    }
                }
            }
        }
        .overlay(BottomNavBarView(showingDataView: $showingDataView, showingDetailView: $showingDetailView, showingHomeView: $showingHomeView, currentView: $currentView, showingSideMenu: $showingSideMenu), alignment: .bottom)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .preferredColorScheme(.light)
        .onAppear {
            currentView = "Início"
        }
    }
}

// MARK: - Service Item Component
struct ServiceItemView: View {
    let icon: String
    let title: String
    let badge: ServiceBadge
    var action: (() -> Void)? = nil
    
    enum ServiceBadge {
        case none
        case novo
        case number(Int)
    }
    
    var body: some View {
        Button(action: {
            action?()
        }) {
            HStack(spacing: 16) {
                // Icon
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0))
                    .frame(width: 30, height: 30)
                
                // Title
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                // Badge
                switch badge {
                case .none:
                    EmptyView()
                case .novo:
                    Text("NOVO")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.green)
                        .cornerRadius(12)
                case .number(let num):
                    Text("\(num)")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                        .frame(width: 24, height: 24)
                        .background(Color.green)
                        .clipShape(Circle())
                }
                
                // Arrow
                Image(systemName: "chevron.right")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12) // Reduced padding since no dividers
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - Side Menu View
struct SideMenuView: View {
    @Binding var showingSideMenu: Bool
    @Binding var biometricLoginEnabled: Bool
    @Binding var isAuthenticated: Bool
    
    var body: some View {
        ZStack {
            // Background overlay
            Color.black.opacity(0.3)
                .ignoresSafeArea()
                .onTapGesture {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showingSideMenu = false
                    }
                }
            
            // Side menu content
            HStack {
                VStack(spacing: 0) {
                    // Header section
                    VStack(spacing: 16) {
                        HStack {
                            Spacer()
                            
                            Button(action: {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    showingSideMenu = false
                                }
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 20, weight: .medium))
                                    .foregroundColor(Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0))
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        
                        // gov.br logo and version
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("gov.br")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            
                            HStack {
                                Text("Versão 3.7.31 (build 1)")
                                    .font(.system(size: 14))
                                    .foregroundColor(.gray)
                                Spacer()
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    
                    // Divider
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                        .padding(.horizontal, 20)
                    
                    // Menu items
                    VStack(spacing: 0) {
                        // Biometric login toggle
                        SideMenuItemView(
                            icon: "touchid",
                            title: "Ativar login com biometria do celular",
                            hasToggle: true,
                            toggleValue: $biometricLoginEnabled
                        ) {
                            // When biometric is disabled, automatically authenticate
                            if !biometricLoginEnabled {
                                isAuthenticated = true
                            }
                        }
                        
                        SideMenuDivider()
                        
                        // Reset app screens
                        SideMenuItemView(
                            icon: "arrow.clockwise",
                            title: "Rever telas de entrada do aplicativo"
                        )
                        
                        SideMenuDivider()
                        
                        // Terms and privacy
                        SideMenuItemView(
                            icon: "shield.fill",
                            title: "Termo de Uso e Aviso de Privacidade"
                        )
                        
                        SideMenuDivider()
                        
                        // Logout
                        SideMenuItemView(
                            icon: "person.crop.circle.badge.minus",
                            title: "Sair e desvincular sua conta deste aparelho"
                        )
                    }
                    .padding(.top, 20)
                    
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width * 0.85)
                .background(Color.white)
                .ignoresSafeArea()
                
                Spacer()
            }
        }
    }
}

// MARK: - Side Menu Item Component
struct SideMenuItemView: View {
    let icon: String
    let title: String
    var hasToggle: Bool = false
    @Binding var toggleValue: Bool
    var action: (() -> Void)? = nil
    
    init(icon: String, title: String, hasToggle: Bool = false, toggleValue: Binding<Bool> = .constant(false), action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.hasToggle = hasToggle
        self._toggleValue = toggleValue
        self.action = action
    }
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            Image(systemName: icon)
                .font(.system(size: 24, weight: .medium))
                .foregroundColor(Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0))
                .frame(width: 30, height: 30)
            
            // Title
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            // Toggle or arrow
            if hasToggle {
                Toggle("", isOn: $toggleValue)
                    .labelsHidden()
                    .scaleEffect(0.8)
                    .onChange(of: toggleValue) { _, newValue in
                        action?()
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(Color.white)
        .onTapGesture {
            if hasToggle {
                toggleValue.toggle()
            } else {
                action?()
            }
        }
    }
}

// MARK: - Side Menu Divider
struct SideMenuDivider: View {
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.2))
            .frame(height: 1)
            .padding(.horizontal, 20)
    }
}

// MARK: - Biometric Authentication View
struct BiometricAuthView: View {
    @Binding var isAuthenticated: Bool
    @Binding var biometricLoginEnabled: Bool
    @State private var errorMessage: String?
    
    var body: some View {
        ZStack {
            Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                // gov.br logo
                VStack(spacing: 16) {
                    Text("gov.br")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Autenticação Biométrica")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                }
                
                // Face ID icon
                Image(systemName: "faceid")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                // Instructions
                VStack(spacing: 16) {
                    Text("Use Face ID para acessar o aplicativo")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    if let error = errorMessage {
                        Text(error)
                            .font(.system(size: 14))
                            .foregroundColor(.red.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                
                // Authenticate button
                Button(action: {
                    authenticateWithBiometrics()
                }) {
                    HStack {
                        Image(systemName: "faceid")
                            .font(.system(size: 20))
                        Text("Autenticar")
                            .font(.system(size: 18, weight: .medium))
                    }
                    .foregroundColor(Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0))
                    .padding(.horizontal, 32)
                    .padding(.vertical, 16)
                    .background(Color.white)
                    .cornerRadius(25)
                }
                
                // Skip biometric button
                Button(action: {
                    biometricLoginEnabled = false
                    isAuthenticated = true
                }) {
                    Text("Desativar autenticação biométrica")
                        .font(.system(size: 16))
                        .foregroundColor(.white.opacity(0.8))
                        .underline()
                }
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            // Auto-trigger biometric authentication when view appears
            authenticateWithBiometrics()
        }
    }
    
    private func authenticateWithBiometrics() {
        let context = LAContext()
        var error: NSError?
        
        // Check if biometric authentication is available
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            let reason = "Autentique-se para acessar o aplicativo gov.br"
            
            context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { success, authenticationError in
                DispatchQueue.main.async {
                    if success {
                        // Authentication successful
                        withAnimation(.easeInOut(duration: 0.5)) {
                            isAuthenticated = true
                        }
                        errorMessage = nil
                    } else {
                        // Authentication failed
                        if let error = authenticationError {
                            switch error {
                            case LAError.userCancel:
                                errorMessage = "Autenticação cancelada pelo usuário"
                            case LAError.userFallback:
                                errorMessage = "Usuário escolheu inserir senha"
                            case LAError.biometryNotAvailable:
                                errorMessage = "Biometria não disponível"
                            case LAError.biometryNotEnrolled:
                                errorMessage = "Biometria não configurada"
                            case LAError.biometryLockout:
                                errorMessage = "Biometria bloqueada. Use a senha do dispositivo"
                            default:
                                errorMessage = "Falha na autenticação biométrica"
                            }
                        }
                    }
                }
            }
        } else {
            // Biometric authentication not available
            errorMessage = "Autenticação biométrica não disponível neste dispositivo"
        }
    }
}

// MARK: - Bottom Navigation Bar
struct BottomNavBarView: View {
    @Binding var showingDataView: Bool
    @Binding var showingDetailView: Bool
    @Binding var showingHomeView: Bool
    @Binding var currentView: String
    @Binding var showingSideMenu: Bool
    @State private var isShowingScanner = false
    @State private var scannedCode: String = ""

    let defaultIconSize: CGFloat = 28
    let commonTextOffset: CGFloat = 2

    var body: some View {
        HStack {
            // Início button
            Button(action: {
                currentView = "Início"
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingDetailView = false
                    showingDataView = false
                    showingHomeView = true
                }
            }) {
                VStack {
                    Image("home")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: 26, height: 26)
                    Text("Início")
                        .font(.caption)
                        .offset(y: commonTextOffset)
                }
                .foregroundColor(currentView == "Início" ? Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0) : .gray)
            }
            
            Spacer()
            
            // Dados button
            Button(action: {
                currentView = "Dados"
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingDetailView = false
                    showingHomeView = false
                    showingDataView = true
                }
            }) {
                VStack {
                    Image("data")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: defaultIconSize, height: defaultIconSize)
                    Text("Dados")
                        .font(.caption)
                        .offset(y: commonTextOffset)
                }
                .foregroundColor(currentView == "Dados" ? Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0) : .gray)
            }
            
            Spacer()
            
            // QR Code button
            Button(action: {
                currentView = "QR Code"
                isShowingScanner = true
            }) {
                VStack {
                    ZStack {
                        Circle().fill(Color(red: 0x15/255.0, green: 0x8c/255.0, blue: 0x26/255.0)).frame(width: 52, height: 52)
                        Image(systemName: "qrcode").foregroundColor(.white).font(.system(size: 24))
                    }
                    Text("QR Code").font(.caption).foregroundColor(currentView == "QR Code" ? Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0) : .gray).offset(y: commonTextOffset)
                }
            }
            .fullScreenCover(isPresented: $isShowingScanner) {
                QRCodeScannerView(isPresented: $isShowingScanner) { code in
                    scannedCode = code
                    print("QR Code scanned: \(code)")
                }
            }
            
            Spacer()
            
            // Carteira button
            Button(action: {
                currentView = "Carteira"
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingDataView = false
                    showingDetailView = false
                    showingHomeView = false
                }
            }) {
                VStack {
                    Image("wallet")
                        .resizable()
                        .renderingMode(.template)
                        .scaledToFit()
                        .frame(width: defaultIconSize, height: defaultIconSize)
                    Text("Carteira")
                        .font(.caption)
                        .offset(y: commonTextOffset)
                }
                .foregroundColor(currentView == "Carteira" ? Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0) : .gray)
            }
            
            Spacer()
            
            // Menu
            Button(action: {
                currentView = "Menu"
                withAnimation(.easeInOut(duration: 0.3)) {
                    showingSideMenu = true
                }
            }) {
                VStack {
                    Image(systemName: "line.3.horizontal")
                        .font(.system(size: defaultIconSize))
                    Text("Menu")
                        .font(.caption)
                        .offset(y: commonTextOffset)
                }
                .foregroundColor(currentView == "Menu" ? Color(red: 0x0e/255.0, green: 0x32/255.0, blue: 0x70/255.0) : .gray)
            }
        }
        .padding(.horizontal, 16).padding(.vertical, 12).background(Color.white)
        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: -1)
    }
}

// MARK: - Preview
struct CompleteDocumentApp_Previews: PreviewProvider {
    static var previews: some View {
        CompleteDocumentApp()
    }
}

// MARK: - Helper Functions
func composite(idTemplate: UIImage, with userPhoto: UIImage, in rect: CGRect) -> UIImage? {
    UIGraphicsBeginImageContextWithOptions(idTemplate.size, false, 0.0)
    idTemplate.draw(in: CGRect(origin: .zero, size: idTemplate.size))
    userPhoto.draw(in: rect)
    let newCompositedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    return newCompositedImage
}

func rotate(image: UIImage) -> UIImage? {
    let radians = CGFloat(90 * Double.pi / 180)
    var newSize = CGRect(origin: .zero, size: image.size).applying(CGAffineTransform(rotationAngle: radians)).size
    newSize.width = floor(newSize.width)
    newSize.height = floor(newSize.height)

    UIGraphicsBeginImageContextWithOptions(newSize, false, image.scale)
    guard let context = UIGraphicsGetCurrentContext() else { return nil }

    context.translateBy(x: newSize.width / 2, y: newSize.height / 2)
    context.rotate(by: radians)
    image.draw(in: CGRect(x: -image.size.width / 2, y: -image.size.height / 2, width: image.size.width, height: image.size.height))

    let newImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()

    return newImage
}

