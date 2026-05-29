import SwiftUI

struct ProductCardView: View {
    let product: Product
    var onAdd: () -> Void
    
    @EnvironmentObject var appContext: AppContext
    
    private var isFavorite: Bool {
        appContext.favoriteProductIds.contains(product.id)
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            // Fondo de la tarjeta
            VStack(alignment: .leading, spacing: 8) {
                Spacer()
                    .frame(height: 150) // Espacio para la imagen
                
                // Fila 1: Intensidad y Precio
                HStack(alignment: .center) {
                    HStack(spacing: 3) {
                        ForEach(0..<(product.intensidad ?? 0), id: \.self) { _ in
                            Image("bean")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 14, height: 14)
                        }
                    }
                    
                    Spacer()
                    
                    Text("$\(String(format: "%.1f", product.precio))")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundStyle(BrandColors.primaryText)
                }
                .padding(.horizontal, 16)
                
                // Fila 2: Rating (Debajo de intensidad)
                if let rating = product.rating_avg {
                    HStack(spacing: 3) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 9))
                        Text(String(format: "%.1f", rating))
                            .font(.system(size: 10, weight: .bold))
                    }
                    .foregroundStyle(BrandColors.rating)
                    .padding(.horizontal, 16)
                    .padding(.top, -4)
                }
                
                // Fila 3: Nombre
                Text(product.nombre)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(BrandColors.primaryText)
                    .lineLimit(2)
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
                
                // Fila 4: Descripción
                Text(product.descripcion ?? "")
                    .font(.system(size: 11))
                    .foregroundStyle(BrandColors.accent)
                    .padding(.horizontal, 16)
                    .fixedSize(horizontal: false, vertical: true)
                
                // Fila 5: Nutrición y Botón Añadir
                HStack(alignment: .bottom) {
                    if let nutricion = product.valores_nutricionales {
                        HStack(spacing: 4) {
                            NutricionMiniBadge(icon: "flame.fill", value: "\(nutricion.calorias ?? 0)")
                            NutricionMiniBadge(icon: "leaf.fill", value: "\(String(format: "%.2f", nutricion.proteinas ?? 0))g")
                            NutricionMiniBadge(icon: "drop.fill", value: "\(String(format: "%.2f", nutricion.grasas ?? 0))g")
                        }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        onAdd()
                        // Feedback háptico y visual
                        let generator = UINotificationFeedbackGenerator()
                        generator.notificationOccurred(.success)
                        appContext.showFeedback(product.nombre, imageUrl: product.principalImagenUrl)
                    }) {
                        Image(systemName: "chevron.right")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 36, height: 34)
                            .background(Color(red: 44/255, green: 54/255, blue: 56/255))
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .frame(width: 260) // Tarjeta más grande
            .background(BrandColors.accent.opacity(0.35))
            .clipShape(RoundedRectangle(cornerRadius: 22))
            .padding(.top, 50)
            
            // Imagen del producto
            AsyncImage(url: URL(string: product.principalImagenUrl ?? "")) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Circle()
                    .fill(Color.gray.opacity(0.1))
                    .frame(width: 180, height: 180)
            }
            .frame(width: 220, height: 220) // Imagen más grande
            .shadow(color: .black.opacity(0.12), radius: 12, x: 0, y: 6)
            .offset(y: 10)
            .grayscale(product.disponible == false ? 1.0 : 0.0)
            .opacity(product.disponible == false ? 0.6 : 1.0)
            
            // BOTÓN DE CORAZÓN (Favoritos rápido)
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    UserService.shared.toggleFavorite(productId: product.id)
                }
            }) {
                ZStack {
                    Circle()
                        .fill(.white)
                        .frame(width: 35, height: 35)
                        .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                    
                    Image(systemName: isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(isFavorite ? BrandColors.primaryBrand : .gray.opacity(0.6))
                        .scaleEffect(isFavorite ? 1.1 : 1.0)
                }
            }
            .offset(x: 100, y: 65) // Posicionado arriba a la derecha de la tarjeta
        }
    }
}

struct NutricionMiniBadge: View {
    let icon: String
    let value: String
    
    var body: some View {
        HStack(spacing: 3) {
            Image(systemName: icon)
                .font(.system(size: 7))
            Text(value)
                .font(.system(size: 8.5, weight: .bold))
        }
        .foregroundStyle(BrandColors.primaryBrand)
        .padding(.horizontal, 5)
        .padding(.vertical, 3)
        .background(BrandColors.background.opacity(0.9))
        .clipShape(Capsule())
    }
}
