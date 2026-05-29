import SwiftUI

struct CheckoutView: View {
    @StateObject private var viewModel = CheckoutViewModel()
    @State private var showAddressPicker = false
    @State private var showTracking = false
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            BrandColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
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
                    
                    Text("Checkout")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(BrandColors.darkContrast)
                    
                    Spacer()
                    
                    Color.clear.frame(width: 40, height: 40)
                }
                .padding(.horizontal, 25)
                .padding(.top, 10)
                
                ScrollView {
                    VStack(alignment: .leading, spacing: 30) {
                        
                        // Alerta de Teléfono Faltante (Capa 3: Operativa)
                        if viewModel.isPhoneRequired {
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    Image(systemName: "phone.badge.plus")
                                        .font(.system(size: 22))
                                    Text("Teléfono Requerido")
                                        .font(.system(size: 18, weight: .bold))
                                }
                                .foregroundStyle(.white)
                                
                                Text("Necesitamos un número de contacto para coordinar la entrega de tu pedido.")
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white.opacity(0.9))
                                
                                Button(action: {
                                    // Navegar a perfil o cerrar checkout para que el usuario vaya
                                    dismiss()
                                    // Aquí podríamos usar un NotificationCenter o AppContext para saltar al Tab de Perfil
                                    NotificationCenter.default.post(name: NSNotification.Name("JumpToProfile"), object: nil)
                                }) {
                                    Text("Ir a Actualizar Perfil")
                                        .font(.system(size: 14, weight: .bold))
                                        .padding(.horizontal, 15)
                                        .padding(.vertical, 8)
                                        .background(.white)
                                        .foregroundStyle(BrandColors.darkContrast)
                                        .clipShape(Capsule())
                                }
                            }
                            .padding()
                            .background(Color.orange.opacity(0.9))
                            .cornerRadius(15)
                            .shadow(radius: 5)
                        }

                        // Sección 1: Método de Entrega
                        VStack(alignment: .leading, spacing: 15) {
                            Text("¿Cómo quieres recibirlo?")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(BrandColors.darkContrast)
                            
                            ForEach(viewModel.shippingMethods) { method in
                                Button(action: {
                                    withAnimation { viewModel.selectedMethod = method }
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(method.nombre)
                                                .font(.system(size: 16, weight: .semibold))
                                                .foregroundStyle(BrandColors.darkContrast)
                                            if method.costo > 0 {
                                                Text("+$\(String(format: "%.2f", method.costo))")
                                                    .font(.system(size: 14))
                                                    .foregroundStyle(BrandColors.primaryBrand)
                                            }
                                        }
                                        Spacer()
                                        Circle()
                                            .strokeBorder(BrandColors.primaryBrand, lineWidth: 2)
                                            .background(
                                                Circle()
                                                    .fill(viewModel.selectedMethod?.id == method.id ? BrandColors.primaryBrand : Color.clear)
                                                    .padding(4)
                                            )
                                            .frame(width: 24, height: 24)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(15)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                            .stroke(viewModel.selectedMethod?.id == method.id ? BrandColors.primaryBrand : Color.clear, lineWidth: 1)
                                    )
                                }
                            }
                        }
                        
                        // Sección 2: Dirección (Solo si es Enviar a domicilio ID 2)
                        if viewModel.selectedMethod?.id == 2 {
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Dirección de entrega")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundStyle(BrandColors.darkContrast)
                                
                                Button(action: { showAddressPicker = true }) {
                                    HStack {
                                        Image(systemName: "mappin.circle.fill")
                                            .font(.system(size: 24))
                                            .foregroundStyle(BrandColors.primaryBrand)
                                        
                                        if let address = viewModel.selectedAddress {
                                            VStack(alignment: .leading, spacing: 4) {
                                                Text(address.calle)
                                                    .font(.system(size: 15, weight: .semibold))
                                                    .foregroundStyle(BrandColors.darkContrast)
                                                Text("\(address.ciudad), \(address.codigoPostal)")
                                                    .font(.system(size: 13))
                                                    .foregroundStyle(BrandColors.accent)
                                            }
                                        } else {
                                            Text("Selecciona una dirección")
                                                .font(.system(size: 15))
                                                .foregroundStyle(BrandColors.accent)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.down")
                                            .font(.system(size: 14))
                                            .foregroundStyle(BrandColors.accent)
                                    }
                                    .padding()
                                    .background(Color.white)
                                    .cornerRadius(15)
                                }
                            }
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Sección 3: Resumen de Costos
                        VStack(spacing: 15) {
                            CostRow(label: "Total de pedido", value: viewModel.subtotal)
                            if let method = viewModel.selectedMethod, method.costo > 0 {
                                CostRow(label: "Costo de envío", value: method.costo)
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.3))
                                .padding(.vertical, 5)
                            
                            HStack {
                                Text("Total")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(BrandColors.darkContrast)
                                Spacer()
                                Text("$\(String(format: "%.2f", viewModel.total))")
                                    .font(.system(size: 22, weight: .bold))
                                    .foregroundStyle(BrandColors.primaryBrand)
                            }
                        }
                        .padding()
                        .background(Color(red: 167/255, green: 140/255, blue: 119/255).opacity(0.15))
                        .cornerRadius(20)
                    }
                    .padding(25)
                    .padding(.bottom, 100)
                }
                
                // Botón Final
                VStack {
                    Button(action: { viewModel.confirmOrder() }) {
                        if viewModel.isLoading {
                            ProgressView()
                                .tint(.white)
                        } else {
                            Text("Confirmar Pedido")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(viewModel.canConfirm ? Color(red: 74/255, green: 44/255, blue: 33/255) : Color.gray)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .disabled(!viewModel.canConfirm || viewModel.isLoading)
                    .padding(.horizontal, 25)
                    .padding(.bottom, 40)
                }
                .background(BrandColors.background)
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showAddressPicker) {
            AddressPickerView { address in
                viewModel.selectedAddress = address
            }
        }
        .fullScreenCover(isPresented: $showTracking) {
            if let success = viewModel.orderSuccess {
                OrderTrackingView(orderId: success.orderId)
            }
        }
        .onChange(of: showTracking) { oldVal, newVal in
            // Si showTracking pasa de true a false, significa que el usuario cerró el seguimiento
            // Cerramos el Checkout inmediatamente sin esperar a que termine la animación del cover
            if oldVal == true && newVal == false {
                dismiss()
            }
        }
        .alert(isPresented: Binding<Bool>(
            get: { viewModel.orderSuccess != nil || viewModel.errorMessage != nil },
            set: { _ in 
                if viewModel.orderSuccess != nil {
                    showTracking = true
                }
                viewModel.errorMessage = nil
            }
        )) {
            if let success = viewModel.orderSuccess {
                return Alert(
                    title: Text("¡Pedido Recibido!"),
                    message: Text("Tu pedido #\(success.orderId.suffix(6)) ha sido registrado. Te avisaremos cuando esté listo."),
                    dismissButton: .default(Text("Ver seguimiento"))
                )
            } else {
                return Alert(
                    title: Text("Error"),
                    message: Text(viewModel.errorMessage ?? "Algo salió mal"),
                    dismissButton: .default(Text("Reintentar"))
                )
            }
        }
    }
}

struct CostRow: View {
    let label: String
    let value: Double
    
    var body: some View {
        HStack {
            Text(label)
                .font(.system(size: 16))
                .foregroundStyle(BrandColors.accent)
            Spacer()
            Text("$\(String(format: "%.2f", value))")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(BrandColors.darkContrast)
        }
    }
}

#Preview {
    NavigationView {
        CheckoutView()
    }
}
