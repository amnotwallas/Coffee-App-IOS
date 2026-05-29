import SwiftUI

struct WelcomeView: View {
    @StateObject private var viewModel = WelcomeViewModel()
    @StateObject private var notificationViewModel = NotificationViewModel()
    @EnvironmentObject var appContext: AppContext
    @State private var selectedProductId: String? = nil
    @State private var badgeScale: CGFloat = 1.0
    var onExploreMenu: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 25) {
                    // AI Barista Header Card
                    if viewModel.isLoading && viewModel.welcomeMessage.isEmpty {
                        WelcomeHeaderSkeleton()
                            .padding(.top, 20)
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Al Barista")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundStyle(BrandColors.primaryText)

                                Spacer()

                                // Icono de campana con animación (Solo visual en Welcome)
                                ZStack(alignment: .topTrailing) {
                                    Image(systemName: "bell.fill")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.white)

                                    if TokenManager.shared.getToken() != nil && notificationViewModel.unreadCount > 0 {
                                        Circle()
                                            .fill(.red)
                                            .frame(width: 10, height: 10)
                                            .offset(x: 2, y: -2)
                                            .scaleEffect(badgeScale)
                                            .onAppear {
                                                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                                                    badgeScale = 1.3
                                                }
                                            }
                                    }
                                }
                            }
                            
                            Text(viewModel.welcomeMessage)
                                .font(.system(size: 14))
                                .foregroundStyle(BrandColors.primaryText.opacity(0.76))
                                .lineSpacing(4)
                            
                            Text("Te recomiendo probar:")
                                .font(.system(size: 14, weight: .bold))
                                .foregroundStyle(BrandColors.primaryText)
                                .padding(.top, 5)
                        }
                        .padding(25)
                        .background(BrandColors.accent)
                        .clipShape(RoundedRectangle(cornerRadius: 30))
                        .padding(.horizontal)
                        .padding(.top, 20)
                    }
                    
                    // Recommendations List
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Recomendaciones para ti")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(BrandColors.primaryText)
                            .padding(.horizontal)
                        
                        if viewModel.isLoading && viewModel.recommendations.isEmpty {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 20) {
                                    ForEach(0..<3) { _ in
                                        ProductCardSkeleton()
                                    }
                                }
                                .padding(.horizontal, 30)
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.viewAligned)
                        } else if viewModel.recommendations.isEmpty && viewModel.errorMessage != nil {
                            VStack(spacing: 10) {
                                Image(systemName: "wifi.slash")
                                    .foregroundStyle(BrandColors.accent)
                                Text("No pudimos cargar las recomendaciones")
                                    .font(.system(size: 14))
                                Button("Reintentar") {
                                    viewModel.loadWelcomeData()
                                }
                                .font(.system(size: 12, weight: .bold))
                                .foregroundStyle(BrandColors.primaryText)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 20)
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(alignment: .top, spacing: 20) {
                                    ForEach(viewModel.recommendations) { product in
                                        ProductCardView(product: product) {
                                            selectedProductId = product.id
                                        }
                                        .onTapGesture {
                                            selectedProductId = product.id
                                        }
                                        .scrollTransition { content, phase in
                                            content
                                                .scaleEffect(phase.isIdentity ? 1.0 : 0.8)
                                                .opacity(phase.isIdentity ? 1.0 : 0.5)
                                        }
                                    }
                                }
                                .padding(.horizontal, 30) // Más padding lateral para que la primera tarjeta no esté pegada
                                .padding(.bottom, 20)
                                .scrollTargetLayout() // Marca el layout para snapping
                            }
                            .scrollTargetBehavior(.viewAligned) // Hace que las tarjetas se centren al hacer scroll
                        }
                    }
                }
            }
            
            // Botón Estático Abajo
            VStack {
                Button(action: onExploreMenu) {
                    HStack {
                        Text("Ver menú completo")
                        Image(systemName: "arrow.right")
                    }
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(BrandColors.primaryText)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .opacity(viewModel.isLoading ? 0.5 : 1.0)
                }
                .disabled(viewModel.isLoading)
                .padding(.horizontal)
                .padding(.top, 15)
                .padding(.bottom, 30)
            }
            .background(BrandColors.background)
            .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
        }
        .sheet(item: Binding(
            get: { selectedProductId.map { IdentifiableString(id: $0) } },
            set: { selectedProductId = $0?.id }
        )) { item in
            ProductDetailView(productId: item.id)
        }
        .background(BrandColors.background)
        .onAppear {
            viewModel.loadWelcomeData()
            if TokenManager.shared.getToken() != nil {
                notificationViewModel.loadNotifications()
            }
        }
    }
}

#Preview {
    WelcomeView(onExploreMenu: {})
        .environmentObject(AppContext.shared)
}
