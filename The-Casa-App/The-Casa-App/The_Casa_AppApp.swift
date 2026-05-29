//
//  The_Casa_AppApp.swift
//  The-Casa-App
//
//  Created by Walter Jahir Ambriz Reyna on 12/05/26.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
}

@main
struct The_Casa_AppApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @StateObject private var appContext = AppContext.shared
    @State private var currentPage: AppStep = .loading
    
    enum AppStep {
        case loading
        case login
        case welcome
        case catalog
    }
    
    var body: some Scene {
        WindowGroup {
            Group {
                switch currentPage {
                case .loading:
                    LoadingViewRepresentable()
                        .ignoresSafeArea()
                        .transition(.opacity)
                case .login:
                    LoginViewRepresentable(onLoginSuccess: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentPage = .welcome
                        }
                    }, onCancel: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentPage = .welcome // Si cancela, vuelve a la app (modo invitado)
                        }
                    })
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing),
                        removal: .opacity
                    ))
                case .welcome:
                    WelcomeView(onExploreMenu: {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            currentPage = .catalog
                        }
                    })
                    .id("welcome-view") // Identificador único para forzar re-render si es necesario
                    .transition(.opacity)
                case .catalog:
                    MainTabView()
                        .transition(.move(edge: .trailing))
                }
            }
            .environmentObject(appContext)
            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: currentPage)
            // Overlay de carga global (Logo respirando)
            .overlay {
                if appContext.isLoading {
                    LoadingViewRepresentable()
                        .transition(.opacity)
                }
            }
            // Overlay de Feedback Global (Masterpiece Capsule - Bottom Reachable)
            .overlay(alignment: .bottom) {
                if appContext.showToast {
                    HStack(spacing: 12) {
                        // Imagen del producto miniatura con estilo circular premium
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.15))
                                .frame(width: 44, height: 44)
                            
                            if let imageUrl = appContext.addedProductImageUrl {
                                AsyncImage(url: URL(string: imageUrl)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image.resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .transition(.opacity.animation(.easeIn(duration: 0.2)))
                                    default:
                                        Image(systemName: "cup.and.saucer.fill")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.white.opacity(0.3))
                                    }
                                }
                                .frame(width: 36, height: 32)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 1) {
                            Text("¡Añadido!")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(.white.opacity(0.8))
                                .textCase(.uppercase)
                            
                            Text(appContext.toastMessage)
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.white)
                                .lineLimit(1)
                        }
                        
                        Spacer(minLength: 15)
                        
                        // Botón de acción rápida con estilo contrastado
                        Button(action: {
                            withAnimation(.spring()) {
                                appContext.showToast = false
                                NotificationCenter.default.post(name: NSNotification.Name("JumpToCart"), object: nil)
                            }
                        }) {
                            HStack(spacing: 6) {
                                Text("Ver")
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 10, weight: .bold))
                            }
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 8)
                            .padding(.horizontal, 16)
                            .background(BrandColors.primaryBrand)
                            .clipShape(Capsule())
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.leading, 8)
                    .padding(.trailing, 10)
                    .frame(width: 350)
                    .background(
                        ZStack {
                            RoundedRectangle(cornerRadius: 28)
                                .fill(Color(red: 28/255, green: 28/255, blue: 30/255))
                            
                            RoundedRectangle(cornerRadius: 28)
                                .stroke(BrandColors.primaryBrand.opacity(0.3), lineWidth: 1)
                        }
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    )
                    .padding(.bottom, 110) // Justo arriba de la Tab Bar flotante
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity).combined(with: .scale(scale: 0.8)),
                        removal: .opacity.combined(with: .scale(scale: 0.9))
                    ))
                    .zIndex(100)
                }
            }
            .alert("Inicio de Sesión Requerido", isPresented: $appContext.showLoginPrompt) {
                Button("Iniciar Sesión") {
                    withAnimation {
                        currentPage = .login
                    }
                }
                Button("Cancelar", role: .cancel) { }
            } message: {
                Text("Debes iniciar sesión para realizar esta acción.")
            }
            .onAppear {
                performStartupTasks()
            }
            .onChange(of: appContext.shouldNavigateToLogin) { _, newValue in
                if newValue {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentPage = .login
                        appContext.shouldNavigateToLogin = false
                    }
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("JumpToCart"))) { _ in
                // Si el usuario está en el Welcome, lo movemos al Catálogo (que contiene el TabBar)
                if currentPage == .welcome {
                    withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                        currentPage = .catalog
                    }
                    
                    // RE-POST: Enviamos de nuevo la señal con un pequeño retraso
                    // Esto permite que el MainTabView termine de cargar y registre su propio observer
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        NotificationCenter.default.post(name: NSNotification.Name("JumpToCart"), object: nil)
                    }
                }
            }
        }
    }
    
    private func performStartupTasks() {
        // Verificar si ya existe un token guardado
        let hasToken = TokenManager.shared.getToken() != nil
        
        // Solicitar permisos de notificación al iniciar
        NotificationManager.shared.requestPermissions()
        
        // Siempre esperamos un poco para mostrar el branding (2.5 segundos)
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                if hasToken {
                    currentPage = .welcome
                } else {
                    currentPage = .login
                }
            }
        }
    }
}

// MARK: - Puente para LoginViewController
struct LoginViewRepresentable: UIViewControllerRepresentable {
    var onLoginSuccess: () -> Void
    var onCancel: () -> Void
    
    func makeUIViewController(context: Context) -> LoginViewController {
        let vc = LoginViewController()
        vc.onLoginSuccess = onLoginSuccess
        vc.onCancel = onCancel
        return vc
    }
    
    func updateUIViewController(_ uiViewController: LoginViewController, context: Context) {}
}

// MARK: - Puente para LoadingViewController
struct LoadingViewRepresentable: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> LoadingViewController {
        return LoadingViewController()
    }
    
    func updateUIViewController(_ uiViewController: LoadingViewController, context: Context) {}
}
