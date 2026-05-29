import SwiftUI

struct AddressPickerView: View {
    @EnvironmentObject var appContext: AppContext
    @Environment(\.dismiss) var dismiss
    var onSelect: (Address) -> Void
    @State private var showAddAddress = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Selecciona una dirección")
                    .font(.system(size: 20, weight: .bold))
                    .foregroundStyle(BrandColors.darkContrast)
                Spacer()
                
                Button(action: { showAddAddress = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(BrandColors.primaryBrand)
                }
                .padding(.trailing, 10)
                
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(BrandColors.accent.opacity(0.5))
                }
            }
            .padding(25)
            
            if let addresses = appContext.currentUser?.direcciones, !addresses.isEmpty {
                ScrollView {
                    VStack(spacing: 15) {
                        ForEach(addresses, id: \.id) { address in
                            Button(action: {
                                onSelect(address)
                                dismiss()
                            }) {
                                HStack(spacing: 15) {
                                    Image(systemName: "mappin.and.ellipse")
                                        .font(.system(size: 20))
                                        .foregroundStyle(BrandColors.primaryBrand)
                                        .frame(width: 40, height: 40)
                                        .background(BrandColors.primaryBrand.opacity(0.1))
                                        .clipShape(Circle())
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(address.calle)
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundStyle(BrandColors.darkContrast)
                                        Text("\(address.ciudad), \(address.codigoPostal)")
                                            .font(.system(size: 13))
                                            .foregroundStyle(BrandColors.accent)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14))
                                        .foregroundStyle(BrandColors.accent.opacity(0.5))
                                }
                                .padding()
                                .background(Color.white)
                                .cornerRadius(15)
                                .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                            }
                        }
                    }
                    .padding(.horizontal, 25)
                }
            } else {
                VStack(spacing: 20) {
                    Image(systemName: "house.and.flag.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(BrandColors.accent.opacity(0.2))
                    
                    Text("No tienes direcciones guardadas")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(BrandColors.accent)
                    
                    Button(action: {
                        showAddAddress = true
                    }) {
                        Text("Agregar dirección")
                            .font(.system(size: 14, weight: .bold))
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(BrandColors.primaryBrand)
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                .frame(maxHeight: .infinity)
            }
            
            Spacer()
        }
        .background(BrandColors.background)
        .sheet(isPresented: $showAddAddress) {
            AddressFormView { calle, ciudad, cp, ref, isDefault in
                UserService.shared.addAddress(calle: calle, ciudad: ciudad, codigoPostal: cp, referencia: ref, esDefault: isDefault) { result in
                    if case .success(let newAddress) = result {
                        // Opcional: Seleccionar automáticamente la nueva dirección
                        onSelect(newAddress)
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AddressPickerView(onSelect: { _ in })
        .environmentObject(AppContext.shared)
}
