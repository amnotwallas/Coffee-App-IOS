import SwiftUI

struct OrderHistoryCard: View {
    let order: Order
    var onTrack: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            // Cabecera: ID y Fecha
            HStack {
                Text("#\(order.id.suffix(6).uppercased())")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundStyle(BrandColors.darkContrast)
                
                Spacer()
                
                Text(formatDate(order.fecha))
                    .font(.system(size: 12))
                    .foregroundStyle(BrandColors.accent)
            }
            
            // Contenido: Productos
            VStack(alignment: .leading, spacing: 6) {
                if let items = order.items, !items.isEmpty {
                    Text(items.prefix(1).map { $0.nombre ?? "" }.joined() + (items.count > 1 ? " + \(items.count - 1) más" : ""))
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(BrandColors.darkContrast.opacity(0.8))
                }
                
                HStack {
                    Text("Total: $\(String(format: "%.2f", order.total))")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(BrandColors.primaryBrand)
                    
                    Spacer()
                    
                    // Badge de Estatus
                    statusBadge
                }
            }
            
            // Botón de Seguimiento (Solo si está activo)
            if isActive {
                Button(action: onTrack) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Ver Seguimiento")
                    }
                    .font(.system(size: 13, weight: .bold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 38)
                    .background(BrandColors.primaryBrand)
                    .cornerRadius(10)
                }
                .padding(.top, 5)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
    
    private var isActive: Bool {
        let s = order.orderStatus
        return s != .delivered && s != .cancelled
    }
    
    private var statusBadge: some View {
        let status = order.orderStatus
        let color: Color
        let text: String
        
        switch status {
        case .ready:
            color = .green
            text = "¡Listo!"
        case .cancelled:
            color = .red
            text = "Cancelado"
        case .pending, .preparing:
            color = .orange
            text = "En proceso"
        case .shipped:
            color = .blue
            text = "En camino"
        case .delivered:
            color = .gray
            text = "Entregado"
        }
        
        return Text(text)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .foregroundStyle(color)
            .clipShape(Capsule())
    }
    
    private func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let date = formatter.date(from: dateString) {
            let outputFormatter = DateFormatter()
            outputFormatter.dateStyle = .medium
            outputFormatter.timeStyle = .short
            outputFormatter.locale = Locale(identifier: "es_MX")
            return outputFormatter.string(from: date)
        }
        return dateString
    }
}
