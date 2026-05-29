import SwiftUI

struct FavoritesView: View {
    @StateObject private var viewModel = FavoritesViewModel()
    @State private var selectedProduct: Product?
    
    var body: some View {
        NavigationView {
            ZStack {
                BrandColors.background.ignoresSafeArea()
                
                // Fondo con "Beans" decorativos (reusando estilo global)
                ZStack {
                    Image("bean")
                        .resizable()
                        .frame(width: 300, height: 300)
                        .rotationEffect(.degrees(-15))
                        .opacity(0.05)
                        .offset(x: -150, y: -200)
                    
                    Image("bean")
                        .resizable()
                        .frame(width: 250, height: 250)
                        .rotationEffect(.degrees(45))
                        .opacity(0.05)
                        .offset(x: 180, y: 300)
                }
                
                VStack(alignment: .leading, spacing: 20) {
                    // Header
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Tus Favoritos")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(BrandColors.darkContrast)
                            Text("Tus antojos de siempre en un solo lugar")
                                .font(.system(size: 14))
                                .foregroundStyle(BrandColors.accent)
                        }
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    if viewModel.isLoading {
                        loadingGrid
                    } else if viewModel.favoriteProducts.isEmpty {
                        emptyState
                    } else {
                        favoritesGrid
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadFavorites()
            }
            // Navegación al detalle para personalización
            .sheet(item: $selectedProduct) { product in
                ProductDetailView(productId: product.id)
            }
        }
    }
    
    private var favoritesGrid: some View {
        ScrollView {
            MasonryLayout(columns: 2, spacing: 15) {
                ForEach(viewModel.favoriteProducts) { product in
                    FavoriteMasonryCard(
                        product: product,
                        onRemove: {
                            viewModel.removeFavorite(id: product.id)
                        },
                        onSelect: {
                            selectedProduct = product
                        }
                    )
                }
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 100)
        }
    }
    
    private var loadingGrid: some View {
        ScrollView {
            MasonryLayout(columns: 2, spacing: 15) {
                ForEach(0..<6) { _ in
                    RoundedRectangle(cornerRadius: 20)
                        .fill(BrandColors.accent.opacity(0.1))
                        .frame(height: CGFloat.random(in: 200...300))
                }
            }
            .padding(.horizontal, 20)
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            
            ZStack {
                Circle()
                    .fill(BrandColors.primaryBrand.opacity(0.05))
                    .frame(width: 160, height: 160)
                
                Image(systemName: "heart.slash.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(BrandColors.primaryBrand.opacity(0.3))
            }
            
            VStack(spacing: 8) {
                Text("Aún no tienes favoritos")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(BrandColors.darkContrast)
                
                Text("Explora nuestro menú y guarda los cafés que más te gusten.")
                    .font(.system(size: 15))
                    .foregroundStyle(BrandColors.accent)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    FavoritesView()
}
