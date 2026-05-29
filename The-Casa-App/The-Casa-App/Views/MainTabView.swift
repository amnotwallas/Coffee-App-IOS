import SwiftUI

enum Tab: String, CaseIterable {
    case home = "house.fill"
    case favorites = "heart.fill"
    case cart = "cart.fill"
    case profile = "person.fill"
}

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @EnvironmentObject var appContext: AppContext
    @Environment(\.scenePhase) var scenePhase
    @State private var glowScale: CGFloat = 1.0
    @State private var glowOpacity: Double = 0.5
    
    // IA Chat State
    @StateObject private var chatViewModel = ChatViewModel()
    @State private var isChatOpen: Bool = false
    
    // Shared States
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var notificationViewModel = NotificationViewModel()
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Contenido de las pestañas
            Group {
                switch selectedTab {
                case .home:
                    CatalogView(notificationViewModel: notificationViewModel)
                case .favorites:
                    FavoritesView()
                case .cart:
                    CartView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.bottom, 75)
            
            // Chat Overlay (Aparece encima del contenido pero debajo de la Tab Bar si es necesario)
            // Usamos zIndex para asegurar que esté al frente
            if isChatOpen {
                Color.black.opacity(0.1) // Dimmer suave de fondo
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.spring()) { isChatOpen = false }
                    }
                
                ChatOverlayView(viewModel: chatViewModel)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 110) // Ajustado para flotar arriba de la barra y el botón
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.1, anchor: .bottom).combined(with: .opacity),
                        removal: .scale(scale: 0.1, anchor: .bottom).combined(with: .opacity)
                    ))
                    .zIndex(10)
            }
            
            // Tab Bar personalizada (Tipo Cápsula Flotante)
            customTabBar
                .padding(.horizontal, 20)
                .padding(.bottom, 15)
                .zIndex(11) // Asegurar que la barra esté siempre al frente del overlay
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .background(BrandColors.background)
        .onAppear {
            // Carga proactiva al iniciar la App
            if TokenManager.shared.getToken() != nil {
                // Sincronizar Perfil (incluye direcciones para el checkout)
                UserService.shared.fetchProfile()
                // Sincronizar Carrito
                CartService.shared.fetchCart()
                // Sincronizar Favoritos (para que los corazones del catálogo salgan rojos de una vez)
                UserService.shared.fetchFavorites()
                
                // Iniciar polling de notificaciones solo para usuarios autenticados
                notificationViewModel.startPolling()
            }
        }
        .onDisappear {
            notificationViewModel.stopPolling()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("JumpToProfile"))) { _ in
            withAnimation {
                selectedTab = .profile
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("JumpToCart"))) { _ in
            withAnimation {
                selectedTab = .cart
            }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            if newPhase == .active && TokenManager.shared.getToken() != nil {
                print("📱 App activa: Forzando refresco de datos...")
                notificationViewModel.refresh()
                CartService.shared.fetchCart()
            }
        }
    }
    
    private var customTabBar: some View {
        ZStack(alignment: .top) {
            // Fondo de la barra
            HStack(spacing: 0) {
                tabItem(for: .home)
                tabItem(for: .favorites)
                
                Spacer()
                    .frame(width: 80)
                
                // Pestaña Carrito con Badge Dinámico (Usando el contexto global para asegurar sincronización)
                ZStack(alignment: .topTrailing) {
                    tabItem(for: .cart)
                    
                    if let count = appContext.activeCart?.itemsCount, count > 0 {
                        Text("\(count)")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 18, height: 18)
                            .background(Color.red)
                            .clipShape(Circle())
                            .offset(x: -15, y: 10)
                            .transition(.scale.combined(with: .opacity))
                            .id("cart-badge-\(count)") // Forzar re-render cuando cambia el número
                    }
                }
                
                tabItem(for: .profile)
            }
            .frame(height: 65)
            .background(BrandColors.accent.opacity(0.95))
            .clipShape(CustomTabBarShape())
            .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
            
            // Botón Flotante Central (AI Barista)
            Button(action: {
                if TokenManager.shared.getToken() != nil {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        isChatOpen.toggle()
                    }
                } else {
                    appContext.showLoginPrompt = true
                }
            }) {
                ZStack {
                    // Capa de Resplandor Animada
                    Circle()
                        .stroke(BrandColors.primaryBrand.opacity(glowOpacity), lineWidth: 4)
                        .frame(width: 60, height: 60)
                        .scaleEffect(glowScale)
                    
                    Circle()
                        .fill(BrandColors.primaryBrand)
                        .frame(width: 60, height: 60)
                        .shadow(color: BrandColors.primaryBrand.opacity(0.3), radius: 8, x: 0, y: 4)
                    
                    Image(systemName: isChatOpen ? "xmark" : "cup.and.saucer.fill")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundStyle(.white)
                        .rotationEffect(.degrees(isChatOpen ? 90 : 0))
                }
            }
            .offset(y: -25)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: false)) {
                    glowScale = 1.6
                    glowOpacity = 0
                }
            }
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func tabItem(for tab: Tab) -> some View {
        Button(action: {
            if tab != .home && TokenManager.shared.getToken() == nil {
                appContext.showLoginPrompt = true
            } else {
                selectedTab = tab
                if isChatOpen {
                    withAnimation(.spring()) { isChatOpen = false }
                }
            }
        }) {
            VStack {
                Spacer()
                Image(systemName: tab.rawValue)
                    .font(.system(size: 24))
                    .foregroundStyle(selectedTab == tab ? .white : BrandColors.background.opacity(0.7))
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func placeholderView(_ title: String) -> some View {
        VStack {
            Text(title)
                .font(.system(size: 24, weight: .bold))
                .foregroundStyle(BrandColors.primaryText)
            Text("Próximamente")
                .font(.system(size: 16))
                .foregroundStyle(BrandColors.accent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColors.background)
    }
}

// Forma personalizada con las 4 esquinas redondeadas y hueco central
struct CustomTabBarShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        let holeWidth: CGFloat = 100
        let holeHeight: CGFloat = 35
        let cornerRadius: CGFloat = 25
        let center = rect.width / 2
        
        // Empezar: Esquina superior izquierda
        path.move(to: CGPoint(x: 0, y: cornerRadius))
        path.addArc(center: CGPoint(x: cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .degrees(180), endAngle: .degrees(270), clockwise: false)
        
        // Hueco central para el botón
        path.addLine(to: CGPoint(x: center - holeWidth / 2, y: 0))
        path.addQuadCurve(to: CGPoint(x: center + holeWidth / 2, y: 0),
                          control: CGPoint(x: center, y: holeHeight))
        
        // Esquina superior derecha
        path.addLine(to: CGPoint(x: rect.width - cornerRadius, y: 0))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: cornerRadius), radius: cornerRadius, startAngle: .degrees(270), endAngle: .degrees(360), clockwise: false)
        
        // Esquina inferior derecha
        path.addLine(to: CGPoint(x: rect.width, y: rect.height - cornerRadius))
        path.addArc(center: CGPoint(x: rect.width - cornerRadius, y: rect.height - cornerRadius), radius: cornerRadius, startAngle: .degrees(0), endAngle: .degrees(90), clockwise: false)
        
        // Esquina inferior izquierda
        path.addLine(to: CGPoint(x: cornerRadius, y: rect.height))
        path.addArc(center: CGPoint(x: cornerRadius, y: rect.height - cornerRadius), radius: cornerRadius, startAngle: .degrees(90), endAngle: .degrees(180), clockwise: false)
        
        path.closeSubpath()
        
        return path
    }
}

#Preview {
    MainTabView()
        .environmentObject(AppContext.shared)
}
