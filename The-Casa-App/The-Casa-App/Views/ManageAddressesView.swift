import SwiftUI

struct ManageAddressesView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var showAddAddress = false
    
    var body: some View {
        ZStack {
            BrandColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Estilo Pedidos)
                HStack {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(BrandColors.darkContrast)
                            .padding(10)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                    }
                    
                    Spacer()
                    
                    Text("Mis Direcciones")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(BrandColors.darkContrast)
                    
                    Spacer()
                    
                    // Botón para añadir nueva
                    Button(action: { showAddAddress = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 20, weight: .bold))
                            .foregroundStyle(BrandColors.primaryBrand)
                            .padding(10)
                            .background(BrandColors.primaryBrand.opacity(0.1))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 25)
                .padding(.top, 20)
                
                if viewModel.isLoading && (viewModel.userProfile?.direcciones?.isEmpty ?? true) {
                    ProgressView().frame(maxHeight: .infinity)
                } else if let addresses = viewModel.userProfile?.direcciones, !addresses.isEmpty {
                    ScrollView {
                        VStack(spacing: 20) {
                            ForEach(addresses, id: \.id) { address in
                                AddressCard(address: address) {
                                    viewModel.deleteAddress(id: address.id ?? "")
                                }
                            }
                        }
                        .padding(.horizontal, 25)
                        .padding(.top, 30)
                        .padding(.bottom, 30)
                    }
                    .refreshable {
                        viewModel.loadProfile()
                    }
                } else {
                    emptyAddressesState
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddAddress) {
            AddressFormView { calle, ciudad, cp, ref, isDefault in
                UserService.shared.addAddress(calle: calle, ciudad: ciudad, codigoPostal: cp, referencia: ref, esDefault: isDefault) { _ in
                    viewModel.loadProfile()
                }
            }
        }
        .onAppear {
            viewModel.loadProfile()
        }
    }
    
    private var emptyAddressesState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "house.and.flag.fill")
                .font(.system(size: 80))
                .foregroundStyle(BrandColors.accent.opacity(0.1))
            
            Text("No tienes direcciones")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(BrandColors.darkContrast)
            
            Text("Agrega tu casa u oficina para recibir tu café favorito.")
                .font(.system(size: 15))
                .foregroundStyle(BrandColors.accent)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 50)
            
            Button(action: { showAddAddress = true }) {
                Text("Añadir mi primera dirección")
                    .font(.system(size: 14, weight: .bold))
                    .padding(.horizontal, 25)
                    .padding(.vertical, 12)
                    .background(BrandColors.primaryBrand)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            .padding(.top, 10)
            
            Spacer()
        }
    }
}

struct AddressCard: View {
    let address: Address
    var onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 15) {
            ZStack {
                Circle()
                    .fill(BrandColors.primaryBrand.opacity(0.1))
                    .frame(width: 45, height: 45)
                Image(systemName: "house.fill")
                    .foregroundStyle(BrandColors.primaryBrand)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(address.calle)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(BrandColors.darkContrast)
                    
                    if address.esDefault {
                        Text("Principal")
                            .font(.system(size: 10, weight: .bold))
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(BrandColors.primaryBrand.opacity(0.1))
                            .foregroundStyle(BrandColors.primaryBrand)
                            .cornerRadius(5)
                    }
                }
                
                Text("\(address.ciudad), \(address.codigoPostal)")
                    .font(.system(size: 13))
                    .foregroundStyle(BrandColors.accent)
            }
            
            Spacer()
            
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.system(size: 16))
                    .foregroundStyle(.red.opacity(0.7))
                    .padding(10)
                    .background(Color.red.opacity(0.05))
                    .clipShape(Circle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: Color.black.opacity(0.04), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    ManageAddressesView()
}
