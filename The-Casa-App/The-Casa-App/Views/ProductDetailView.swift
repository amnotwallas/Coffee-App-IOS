import SwiftUI

struct ProductDetailView: View {
    let productId: String
    @StateObject private var viewModel = ProductDetailViewModel()
    @EnvironmentObject var appContext: AppContext
    @Environment(\.dismiss) var dismiss
    
    private var isFavorite: Bool {
        appContext.favoriteProductIds.contains(productId)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header con imagen
                ZStack(alignment: .topLeading) {
                    if let imageUrl = viewModel.product?.principalImagenUrl {
                        AsyncImage(url: URL(string: imageUrl)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        } placeholder: {
                            Color.gray.opacity(0.1)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 300)
                        .background(BrandColors.accent.opacity(0.2))
                    }
                    
                    HStack {
                        Button(action: { dismiss() }) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .bold))
                                .padding()
                                .background(.white.opacity(0.8))
                                .clipShape(Circle())
                                .foregroundStyle(BrandColors.primaryText)
                        }
                        
                        Spacer()
                        
                        // BOTÓN DE CORAZÓN (Unificado)
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                                UserService.shared.toggleFavorite(productId: productId)
                            }
                        }) {
                            ZStack {
                                Circle()
                                    .fill(.white.opacity(0.8))
                                    .frame(width: 44, height: 44)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                
                                Image(systemName: isFavorite ? "heart.fill" : "heart")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(isFavorite ? BrandColors.primaryBrand : BrandColors.primaryText.opacity(0.6))
                                    .scaleEffect(isFavorite ? 1.1 : 1.0)
                            }
                        }
                    }
                    .padding(.top, 50)
                    .padding(.horizontal, 20)
                }
                
                if viewModel.isLoading {
                    HStack {
                        Spacer()
                        ProgressView()
                        Spacer()
                    }
                    .padding(.top, 50)
                } else if let product = viewModel.product {
                    VStack(alignment: .leading, spacing: 15) {
                        // Nombre y Precio
                        HStack {
                            Text(product.nombre)
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(BrandColors.primaryText)
                            
                            Spacer()
                            
                            Text("$\(String(format: "%.1f", product.precio))")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(BrandColors.primaryText)
                        }
                        
                        // Rating y Reseñas
                        if let rating = product.rating_avg {
                            HStack(spacing: 5) {
                                HStack(spacing: 2) {
                                    ForEach(0..<5) { index in
                                        Image(systemName: index < Int(rating.rounded()) ? "star.fill" : "star")
                                            .font(.system(size: 14))
                                            .foregroundStyle(.yellow)
                                    }
                                }
                                
                                Text(String(format: "%.1f", rating))
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundStyle(BrandColors.primaryText)
                                
                                if let reviews = product.reviews_count {
                                    Text("(\(reviews) reseñas)")
                                        .font(.system(size: 14))
                                        .foregroundStyle(BrandColors.accent.opacity(0.7))
                                }
                            }
                        }
                        
                        // Descripción
                        Text(product.descripcion ?? "")
                            .font(.system(size: 16))
                            .foregroundStyle(BrandColors.accent)
                            .lineSpacing(4)
                        
                        // Intensidad
                        if let intensidad = product.intensidad {
                            HStack {
                                Text("Intensidad:")
                                    .font(.system(size: 14, weight: .bold))
                                HStack(spacing: 6) {
                                    ForEach(0..<intensidad, id: \.self) { _ in
                                        Image("bean")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 16, height: 16)
                                    }
                                }
                            }
                            .foregroundStyle(BrandColors.primaryText)
                        }
                        
                        // Valores Nutricionales
                        if let nutricion = product.valores_nutricionales {
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Información Nutricional")
                                    .font(.system(size: 16, weight: .bold))
                                    .foregroundStyle(BrandColors.primaryText)
                                
                                HStack(spacing: 15) {
                                    NutricionBadge(label: "Cal", value: "\(nutricion.calorias ?? 0)")
                                    NutricionBadge(label: "Prot", value: "\(String(format: "%.1fg", nutricion.proteinas ?? 0))")
                                    NutricionBadge(label: "Grasa", value: "\(String(format: "%.1fg", nutricion.grasas ?? 0))")
                                    NutricionBadge(label: "Carb", value: "\(String(format: "%.1fg", nutricion.carbohidratos ?? 0))")
                                }
                            }
                            .padding(.vertical, 5)
                        }
                        
                        Divider()
                        
                        // Personalizaciones
                        if let personalizaciones = product.personalizaciones {
                            ForEach(personalizaciones, id: \.tipo) { section in
                                VStack(alignment: .leading, spacing: 10) {
                                    Text(section.tipo)
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundStyle(BrandColors.primaryText)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 20) {
                                            ForEach(section.opciones, id: \.nombre) { opcion in
                                                let isSelected = viewModel.selectedOptions[section.tipo] == opcion.nombre
                                                let isSize = section.tipo == "Tamaño"
                                                
                                                Button(action: {
                                                    viewModel.selectedOptions[section.tipo] = opcion.nombre
                                                }) {
                                                    VStack(spacing: 8) {
                                                        if isSize {
                                                            let size: CGFloat = {
                                                                switch opcion.nombre.lowercased() {
                                                                case "chico": return 45
                                                                case "mediano": return 65
                                                                case "grande": return 85
                                                                default: return 65
                                                                }
                                                            }()
                                                            
                                                            Image(opcion.nombre.lowercased())
                                                                .resizable()
                                                                .aspectRatio(contentMode: .fit)
                                                                .frame(width: size, height: size)
                                                                .grayscale(isSelected ? 0.0 : 1.0)
                                                                .scaleEffect(isSelected ? 1.05 : 1.0)
                                                                .frame(height: 85, alignment: .bottom) // Mantener base alineada con más aire
                                                        }
                                                        
                                                        Text(opcion.nombre)
                                                            .font(.system(size: 14, weight: isSelected ? .bold : .regular))
                                                            .padding(.horizontal, isSize ? 0 : 16)
                                                            .padding(.vertical, isSize ? 0 : 8)
                                                            .background(isSize ? Color.clear : (isSelected ? BrandColors.primaryText : Color.white))
                                                            .foregroundStyle(isSize ? (isSelected ? BrandColors.primaryText : .gray) : (isSelected ? .white : BrandColors.primaryText))
                                                            .clipShape(Capsule())
                                                            .overlay(
                                                                isSize ? nil : Capsule().stroke(BrandColors.primaryText, lineWidth: 1)
                                                            )
                                                    }
                                                    .padding(isSize ? 10 : 0)
                                                    .background(isSize && isSelected ? BrandColors.accent.opacity(0.1) : Color.clear)
                                                    .clipShape(RoundedRectangle(cornerRadius: 15))
                                                }
                                            }
                                        }
                                    }
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        
                        // Botón Añadir
                        Button(action: {
                            viewModel.addToCart()
                            // Feedback háptico y visual
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.success)
                            appContext.showFeedback(viewModel.product?.nombre ?? "Producto", imageUrl: viewModel.product?.principalImagenUrl)
                            dismiss()
                        }) {
                            Text("Añadir al Carrito")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .frame(height: 55)
                                .background(BrandColors.primaryText)
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                        }
                        .padding(.top, 20)
                    }
                    .padding(25)
                }
            }
        }
        .background(BrandColors.background)
        .ignoresSafeArea(edges: .top)
        .onAppear {
            viewModel.loadProduct(id: productId)
        }
    }
}

struct NutricionBadge: View {
    let label: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(BrandColors.primaryText)
            Text(label)
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(BrandColors.accent)
        }
        .frame(minWidth: 60)
        .padding(.vertical, 8)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(BrandColors.accent.opacity(0.3), lineWidth: 1)
        )
    }
}
