import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var showEditProfile = false
    @State private var showAddresses = false
    @State private var showHistory = false
    
    var body: some View {
        NavigationView {
            ZStack {
                BrandColors.background.ignoresSafeArea()
                
                // Fondo decorativo
                Image("bean")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(-15))
                    .opacity(0.04)
                    .offset(x: -150, y: -200)
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 1. Cabecera de Usuario
                        userInfoHeader
                        
                        // 2. Acciones de Sistema
                        systemActions
                        
                        // 3. Preferencias
                        preferencesSection
                        
                        Spacer()
                            .frame(height: 100)
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                }
                .refreshable {
                    viewModel.loadProfile()
                }
            }
            .navigationBarHidden(true)
            // Modales
            .sheet(isPresented: $showEditProfile) {
                if let profile = viewModel.userProfile {
                    EditProfileFormView(
                        currentNombre: profile.nombre ?? "",
                        currentTelefono: profile.telefono ?? "",
                        onSave: { nombre, telefono in
                            viewModel.updateInfo(nombre: nombre, telefono: telefono)
                        }
                    )
                }
            }
            .fullScreenCover(isPresented: $showAddresses) {
                ManageAddressesView()
            }
            .fullScreenCover(isPresented: $showHistory) {
                OrderHistoryView()
            }
        }
        .onAppear {
            viewModel.loadProfile()
        }
    }
    
    // MARK: - Módulos de UI
    
    private var userInfoHeader: some View {
        VStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(BrandColors.primaryBrand.opacity(0.1))
                    .frame(width: 100, height: 100)
                
                Text(viewModel.userProfile?.nombre?.prefix(1).uppercased() ?? "U")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(BrandColors.primaryBrand)
            }
            
            VStack(spacing: 4) {
                Text(viewModel.userProfile?.nombre ?? "Usuario")
                    .font(.system(size: 22, weight: .bold))
                    .foregroundStyle(BrandColors.darkContrast)
                
                Text(viewModel.userProfile?.email ?? "email@ejemplo.com")
                    .font(.system(size: 14))
                    .foregroundStyle(BrandColors.accent)
                
                if let tel = viewModel.userProfile?.telefono {
                    Text(tel)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(BrandColors.primaryBrand)
                        .padding(.top, 2)
                }
            }
            
            Button(action: { showEditProfile = true }) {
                Text("Actualizar Perfil")
                    .font(.system(size: 14, weight: .bold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(BrandColors.darkContrast)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
    }
    
    private var preferencesSection: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Preferencias")
                .font(.system(size: 18, weight: .bold))
                .foregroundStyle(BrandColors.darkContrast)
            
            VStack(spacing: 0) {
                ToggleRow(icon: "bell.badge", title: "Notificaciones Push", isOn: .constant(true))
                Divider().padding(.leading, 50)
                InfoRow(icon: "drop.fill", title: "Leche favorita", value: viewModel.userProfile?.preferencias?.tipoLecheFavorita ?? "No definida")
            }
            .background(Color.white.opacity(0.6))
            .cornerRadius(15)
        }
    }
    
    private var systemActions: some View {
        VStack(spacing: 12) {
            // Botón Mis Direcciones
            Button(action: { showAddresses = true }) {
                HStack {
                    Image(systemName: "mappin.and.ellipse")
                    Text("Mis Direcciones")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 16, weight: .bold))
                .padding()
                .background(BrandColors.darkContrast)
                .foregroundStyle(.white)
                .cornerRadius(15)
            }

            Button(action: { showHistory = true }) {
                HStack {
                    Image(systemName: "clock.arrow.circlepath")
                    Text("Historial de Pedidos")
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .font(.system(size: 16, weight: .bold))
                .padding()
                .background(BrandColors.darkContrast)
                .foregroundStyle(.white)
                .cornerRadius(15)
            }
            
            Button(action: { viewModel.logout() }) {
                HStack {
                    Image(systemName: "power")
                    Text("Cerrar Sesión")
                }
                .font(.system(size: 16, weight: .bold))
                .padding()
                .frame(maxWidth: .infinity)
                .foregroundStyle(.red)
                .background(Color.red.opacity(0.1))
                .cornerRadius(15)
            }
        }
    }
}

// MARK: - Helper Views

struct ToggleRow: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundStyle(BrandColors.accent)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(BrandColors.darkContrast)
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden().tint(BrandColors.primaryBrand)
        }
        .padding()
    }
}

struct InfoRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundStyle(BrandColors.accent)
                .frame(width: 24)
            Text(title)
                .font(.system(size: 15))
                .foregroundStyle(BrandColors.darkContrast)
            Spacer()
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundStyle(BrandColors.primaryBrand)
        }
        .padding()
    }
}

#Preview {
    ProfileView()
}
