import SwiftUI

struct CartItemRow: View {
    let item: CartItem
    var onIncrease: () -> Void
    var onDecrease: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Imagen del producto (Prioridad: API -> Fallback: Local)
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(BrandColors.primaryBrand.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                if let imageUrl = item.imagen, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        default:
                            localFallbackImage
                        }
                    }
                    .frame(width: 55, height: 55)
                } else {
                    localFallbackImage
                }
            }
            .padding(.leading, 12)
            
            VStack(alignment: .leading, spacing: 4) {
                // Permitimos que el nombre se expanda a varias líneas para no truncar
                Text(item.nombre ?? "Producto")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(Color(red: 44/255, green: 54/255, blue: 56/255))
                    .fixedSize(horizontal: false, vertical: true)
                
                if let specs = item.personalizaciones, !specs.isEmpty {
                    // Unimos las especificaciones de forma segura, permitiendo múltiples líneas
                    Text(specs.values.map { $0 }.joined(separator: ", "))
                        .font(.system(size: 10))
                        .foregroundStyle(Color(red: 93/255, green: 70/255, blue: 37/255))
                        .fixedSize(horizontal: false, vertical: true)
                }
                
                // Controles de cantidad (Figma Style)
                HStack(spacing: 15) {
                    Button(action: onDecrease) {
                        Image(systemName: "minus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(red: 70/255, green: 48/255, blue: 11/255))
                    }
                    
                    Text("\(item.cantidad ?? 0)")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color(red: 70/255, green: 48/255, blue: 11/255))
                        .frame(minWidth: 20)
                    
                    Button(action: onIncrease) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 22))
                            .foregroundStyle(Color(red: 70/255, green: 48/255, blue: 11/255))
                    }
                }
                .padding(.top, 5)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.1f", (item.subtotal ?? 0)))")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(Color(red: 70/255, green: 48/255, blue: 11/255))
                .padding(.trailing, 15)
        }
        .frame(maxWidth: .infinity)
        .frame(minHeight: 100)
        .padding(.vertical, 10)
        .background(Color(red: 167/255, green: 140/255, blue: 119/255).opacity(0.43))
        .cornerRadius(15)
    }

    private var localFallbackImage: some View {
        Image(getImageName(for: item.nombre ?? ""))
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 55, height: 55)
    }

    private func getImageName(for productName: String) -> String {
        let name = productName.lowercased()
        if name.contains("cold brew") {
            return "cold-brew-cup"
        } else if name.contains("frappe") || name.contains("frappé") {
            return "chico"
        } else if name.contains("capuchino") || name.contains("espresso") {
            return "espresso-cup"
        } else {
            return "espresso-cup"
        }
    }
}

#Preview {
    CartItemRow(item: CartItem(
        cartItemId: "1",
        productId: "uuid-001",
        nombre: "Frappé Mocha Blanco",
        imagen: nil,
        precio: 89.0,
        cantidad: 2,
        personalizaciones: ["Leche": "Almendra", "Tamaño": "Grande"],
        subtotal: 178.0
    ), onIncrease: {}, onDecrease: {})
    .padding()
}
