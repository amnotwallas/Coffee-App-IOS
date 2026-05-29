import SwiftUI

struct NotificationView: View {
    @ObservedObject var viewModel: NotificationViewModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        VStack(spacing: 0) {
            // Header Premium
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notificaciones")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(BrandColors.darkContrast)
                    if viewModel.unreadCount > 0 {
                        Text("Tienes \(viewModel.unreadCount) por leer")
                            .font(.system(size: 14))
                            .foregroundStyle(BrandColors.primaryBrand)
                    }
                }
                
                Spacer()
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(BrandColors.accent.opacity(0.3))
                }
            }
            .padding(.horizontal, 25)
            .padding(.top, 25)
            .padding(.bottom, 20)
            
            if !viewModel.notifications.isEmpty {
                HStack {
                    Spacer()
                    Button(action: {
                        withAnimation { viewModel.markAllAsRead() }
                    }) {
                        Text("Marcar todas como leídas")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundStyle(BrandColors.primaryBrand)
                    }
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 10)
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            if viewModel.isLoading && viewModel.notifications.isEmpty {
                loadingState
            } else if viewModel.notifications.isEmpty {
                emptyState
            } else {
                notificationsList
            }
        }
        .background(BrandColors.background)
        .onAppear {
            viewModel.loadNotifications()
        }
    }
    
    private var notificationsList: some View {
        List {
            ForEach(viewModel.notifications) { notification in
                NotificationRow(notification: notification)
                    .onTapGesture {
                        withAnimation {
                            viewModel.markAsRead(notification: notification)
                        }
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                    .listRowInsets(EdgeInsets(top: 5, leading: 20, bottom: 5, trailing: 20))
            }
        }
        .listStyle(.plain)
        .refreshable {
            viewModel.loadNotifications()
        }
    }
    
    private var loadingState: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(BrandColors.primaryBrand)
            Text("Cargando tus avisos...")
                .font(.system(size: 14))
                .foregroundStyle(BrandColors.accent)
                .padding(.top, 10)
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(BrandColors.primaryBrand.opacity(0.05))
                    .frame(width: 120, height: 120)
                Image(systemName: "bell.slash.fill")
                    .font(.system(size: 45))
                    .foregroundStyle(BrandColors.accent.opacity(0.2))
            }
            
            VStack(spacing: 8) {
                Text("Todo al día")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(BrandColors.darkContrast)
                Text("Te avisaremos cuando tu café esté listo o tengamos promos para ti.")
                    .font(.system(size: 14))
                    .foregroundStyle(BrandColors.accent)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

struct NotificationRow: View {
    let notification: CoffeeNotification
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // Icono Dinámico
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 48, height: 48)
                
                Image(systemName: iconName)
                    .font(.system(size: 20))
                    .foregroundStyle(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(notification.titulo)
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(BrandColors.darkContrast)
                    
                    Spacer()
                    
                    if !notification.leida {
                        Circle()
                            .fill(BrandColors.primaryBrand)
                            .frame(width: 8, height: 8)
                    }
                }
                
                Text(notification.mensaje)
                    .font(.system(size: 13))
                    .foregroundStyle(BrandColors.darkContrast.opacity(0.7))
                    .lineLimit(2)
                
                Text(formatRelativeDate(notification.fecha))
                    .font(.system(size: 11, weight: .medium))
                    .foregroundStyle(BrandColors.accent.opacity(0.6))
                    .padding(.top, 2)
            }
        }
        .padding(15)
        .background(notification.leida ? Color.white.opacity(0.4) : Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 4)
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(notification.leida ? Color.clear : BrandColors.primaryBrand.opacity(0.1), lineWidth: 1)
        )
    }
    
    private var iconName: String {
        switch notification.notificationType {
        case .orderStatus: return "bag.fill"
        case .promo: return "tag.fill"
        case .info: return "info.circle.fill"
        }
    }
    
    private var iconColor: Color {
        switch notification.notificationType {
        case .orderStatus: return BrandColors.primaryBrand
        case .promo: return Color.orange
        case .info: return Color.blue
        }
    }
    
    private var iconBackgroundColor: Color {
        iconColor.opacity(0.1)
    }
    
    private func formatRelativeDate(_ dateString: String) -> String {
        // Formato simplificado para propósitos del UI
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        
        if let date = formatter.date(from: dateString) {
            let relativeFormatter = RelativeDateTimeFormatter()
            relativeFormatter.unitsStyle = .full
            relativeFormatter.locale = Locale(identifier: "es_MX")
            return relativeFormatter.localizedString(for: date, relativeTo: Date())
        }
        return "Hace un momento"
    }
}

#Preview {
    NotificationView(viewModel: NotificationViewModel())
}
