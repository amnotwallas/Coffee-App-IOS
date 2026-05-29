import SwiftUI

struct FavoriteMasonryCard: View {
    let product: Product
    var onRemove: () -> Void
    var onSelect: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Imagen con overlay de corazón
            ZStack(alignment: .topTrailing) {
                if let urlString = product.principalImagenUrl, let url = URL(string: urlString) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            Rectangle()
                                .fill(BrandColors.accent.opacity(0.1))
                                .frame(minHeight: 150)
                                .overlay(ProgressView().scaleEffect(0.5))
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit) // Cambiamos a fit para ver la imagen completa sea cual sea su forma
                        case .failure:
                            Rectangle()
                                .fill(BrandColors.accent.opacity(0.1))
                                .frame(height: 150)
                                .overlay(
                                    Image(systemName: "photo")
                                        .foregroundStyle(BrandColors.accent.opacity(0.5))
                                )
                        @unknown default:
                            EmptyView()
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .background(Color.white.opacity(0.05)) // Fondo sutil para cuando es fit
                    .clipped()
                } else {
                    Rectangle()
                        .fill(BrandColors.accent.opacity(0.1))
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                        .overlay(
                            Image(systemName: "photo")
                                .foregroundStyle(BrandColors.accent.opacity(0.5))
                        )
                }
                
                // Botón Quitar Favorito
                Button(action: onRemove) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(8)
                        .background(BrandColors.primaryBrand)
                        .clipShape(Circle())
                        .shadow(radius: 4)
                }
                .padding(10)
            }
            .cornerRadius(20)
            
            // Info del Producto
            VStack(alignment: .leading, spacing: 4) {
                Text(product.nombre)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundStyle(BrandColors.darkContrast)
                    .lineLimit(2)
                
                HStack {
                    Text("$\(product.precio, specifier: "%.2f")")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(BrandColors.primaryBrand)
                    
                    Spacer()
                    
                    // Botón Personalizar/Comprar
                    Button(action: onSelect) {
                        Image(systemName: "plus")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(.white)
                            .padding(6)
                            .background(BrandColors.darkContrast)
                            .clipShape(Circle())
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
        }
        .background(.ultraThinMaterial)
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .onTapGesture(perform: onSelect)
    }
}
