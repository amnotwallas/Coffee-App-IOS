import SwiftUI

struct CatalogView: View {
    @StateObject private var viewModel = CatalogViewModel()
    @ObservedObject var notificationViewModel: NotificationViewModel
    @EnvironmentObject var appContext: AppContext
    @State private var selectedProductId: String? = nil
    @State private var showNotifications = false
    @State private var badgeScale: CGFloat = 1.0
    @State private var isSearchExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header Estático
            staticHeader
            
            // Lista de Productos Desplazable
            productList
        }
        .sheet(isPresented: $showNotifications) {
            NotificationView(viewModel: notificationViewModel)
        }
        .sheet(item: Binding(
            get: { selectedProductId.map { IdentifiableString(id: $0) } },
            set: { selectedProductId = $0?.id }
        )) { item in
            ProductDetailView(productId: item.id)
        }
        .background(BrandColors.background)
        .onAppear {
            viewModel.loadProducts()
        }
        .onChange(of: notificationViewModel.unreadCount) { _, newValue in
            if newValue == 0 {
                withAnimation { badgeScale = 1.0 }
            }
        }
    }
    
    private var staticHeader: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                if !isSearchExpanded {
                    Text("Elige tu orden")
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(BrandColors.primaryText)
                        .transition(.move(edge: .leading).combined(with: .opacity))
                }
                
                Spacer()
                
                searchSection
                
                if !isSearchExpanded {
                    notificationButton
                        .transition(.move(edge: .trailing).combined(with: .opacity))
                }
            }
            .padding(.horizontal)
            .padding(.top, 20)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSearchExpanded)
            
            Text("Bebidas con café")
                .font(.system(size: 16, weight: .bold))
                .foregroundStyle(BrandColors.darkContrast)
                .padding(.horizontal)
            
            categorySelector
        }
        .background(BrandColors.background)
    }
    
    private var searchSection: some View {
        HStack {
            if isSearchExpanded {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(BrandColors.accent)
                    
                    TextField("Busca tu café...", text: $viewModel.searchQuery)
                        .font(.system(size: 15))
                        .autocorrectionDisabled()
                    
                    Button(action: {
                        withAnimation {
                            isSearchExpanded = false
                            viewModel.searchQuery = ""
                        }
                    }) {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(BrandColors.accent)
                    }
                }
                .padding(.horizontal, 15)
                .padding(.vertical, 8)
                .background(Color.white)
                .clipShape(Capsule())
                .shadow(color: Color.black.opacity(0.03), radius: 5, x: 0, y: 2)
                .transition(.asymmetric(insertion: .scale.combined(with: .move(edge: .trailing)), removal: .opacity))
            } else {
                Button(action: {
                    withAnimation { isSearchExpanded = true }
                }) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 24))
                        .foregroundStyle(BrandColors.accent)
                        .padding(8)
                }
            }
        }
    }
    
    private var notificationButton: some View {
        Button(action: {
            if TokenManager.shared.getToken() != nil {
                showNotifications = true
            } else {
                appContext.showLoginPrompt = true
            }
        }) {
            ZStack(alignment: .topTrailing) {
                Image(systemName: "bell.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(BrandColors.accent)
                
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
    }
    
    private var categorySelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                CategoryItem(title: "Frías", isSelected: viewModel.selectedCategoryId == 1)
                    .onTapGesture { viewModel.selectCategory(1) }
                
                CategoryItem(title: "Calientes", isSelected: viewModel.selectedCategoryId == 2)
                    .onTapGesture { viewModel.selectCategory(2) }
                
                CategoryItem(title: "Sin Café", isSelected: viewModel.selectedCategoryId == 3)
                    .onTapGesture { viewModel.selectCategory(3) }
                
                CategoryItem(title: "Postres", isSelected: viewModel.selectedCategoryId == 4)
                    .onTapGesture { viewModel.selectCategory(4) }
                
                CategoryItem(title: "Snacks", isSelected: viewModel.selectedCategoryId == 5)
                    .onTapGesture { viewModel.selectCategory(5) }
            }
            .padding(.horizontal)
        }
        .padding(.bottom, 15)
    }
    
    private var productList: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 60) {
                    // ID invisible para referencia del top
                    Color.clear
                        .frame(height: 1)
                        .id("top")
                    
                    if viewModel.isLoading && viewModel.products.isEmpty {
                        ForEach(0..<3) { _ in
                            ProductCardSkeleton()
                        }
                    } else if viewModel.products.isEmpty && viewModel.errorMessage != nil {
                        VStack(spacing: 20) {
                            Image(systemName: "wifi.slash")
                                .font(.system(size: 50))
                                .foregroundStyle(BrandColors.accent)
                            Text("Parece que no tienes conexión")
                                .font(.system(size: 18, weight: .bold))
                            Button("Reintentar") {
                                viewModel.loadProducts()
                            }
                            .padding()
                            .background(BrandColors.primaryText)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                        }
                        .padding(.top, 100)
                    } else {
                        ForEach(viewModel.products) { product in
                            ProductCardView(product: product) {
                                selectedProductId = product.id
                            }
                            .onTapGesture {
                                selectedProductId = product.id
                            }
                            .scrollTransition { content, phase in
                                content
                                    .scaleEffect(phase.isIdentity ? 1.0 : 0.85)
                                    .opacity(phase.isIdentity ? 1.0 : 0.6)
                            }
                        }
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 20)
                .padding(.bottom, 30)
                .scrollTargetLayout()
            }
            .applyScrollSnapping(isEnabled: !viewModel.products.isEmpty)
            .onChange(of: viewModel.selectedCategoryId) { _, _ in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    proxy.scrollTo("top", anchor: .top)
                }
            }
        }
    }
}

extension View {
    @ViewBuilder
    func applyScrollSnapping(isEnabled: Bool) -> some View {
        if isEnabled {
            self.scrollTargetBehavior(.viewAligned)
        } else {
            self
        }
    }
}

struct CategoryItem: View {
    let title: String
    let isSelected: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundStyle(isSelected ? BrandColors.primaryText : BrandColors.accent)
            
            if isSelected {
                RoundedRectangle(cornerRadius: 20)
                    .fill(BrandColors.accent)
                    .frame(width: 21, height: 2)
            } else {
                Spacer()
                    .frame(height: 2)
            }
        }
    }
}

#Preview {
    CatalogView(notificationViewModel: NotificationViewModel())
        .environmentObject(AppContext.shared)
}
