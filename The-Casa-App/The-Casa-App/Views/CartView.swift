import SwiftUI

struct CartView: View {
    @StateObject private var viewModel = CartViewModel()
    @State private var navigateToCheckout = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                BrandColors.background.ignoresSafeArea()
                
                // Fondo decorativo
                Image("bean")
                    .resizable()
                    .frame(width: 300, height: 300)
                    .rotationEffect(.degrees(-15))
                    .opacity(0.05)
                    .offset(x: -150, y: -200)
                
                VStack(spacing: 0) {
                    // Custom Header
                    HStack {
                        Text("Mi Carrito")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(BrandColors.darkContrast)
                        Spacer()
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    .padding(.bottom, 10)
                    
                    if viewModel.isLoading && (viewModel.cart?.items?.isEmpty ?? true) {
                        ProgressView()
                            .frame(maxHeight: .infinity)
                    } else if let cart = viewModel.cart, let items = cart.items, !items.isEmpty {
                        ZStack(alignment: .bottom) {
                            ScrollView {
                                VStack(spacing: 15) {
                                    ForEach(items) { item in
                                        CartItemRow(
                                            item: item,
                                            onIncrease: { viewModel.updateQuantity(for: item, delta: 1) },
                                            onDecrease: { viewModel.updateQuantity(for: item, delta: -1) }
                                        )
                                    }
                                }
                                .padding(.horizontal, 25)
                                .padding(.top, 10)
                                .padding(.bottom, 220) // Espacio para que el scroll no tape el total
                            }
                            
                            // Resumen y Botón (Fija al fondo)
                            VStack(spacing: 20) {
                                HStack {
                                    Text("Total del pedido")
                                        .font(.system(size: 16))
                                        .foregroundStyle(Color(red: 44/255, green: 54/255, blue: 56/255))
                                    Spacer()
                                    Text("$\(String(format: "%.2f", cart.total ?? 0.0))")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundStyle(Color(red: 70/255, green: 48/255, blue: 11/255))
                                }
                                .padding(.horizontal, 25)
                                
                                Button(action: { navigateToCheckout = true }) {
                                    Text("Continuar al Checkout")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundStyle(.white)
                                        .frame(maxWidth: .infinity)
                                        .frame(height: 55)
                                        .background(Color(red: 74/255, green: 44/255, blue: 33/255))
                                        .clipShape(RoundedRectangle(cornerRadius: 20))
                                        .shadow(color: .black.opacity(0.1), radius: 10, y: 5)
                                        }
                                        .padding(.horizontal, 25)
                                        .padding(.bottom, 40) // Ajustado a 40 para igualar al CheckoutView
                                        }
                                        .padding(.top, 30)
                                        .background(
                                        LinearGradient(
                                        gradient: Gradient(colors: [BrandColors.background.opacity(0), BrandColors.background, BrandColors.background]),
                                        startPoint: .top,
                                        endPoint: .bottom
                                        )
                                        )
                                        }

                    } else {
                        emptyCartState
                    }
                }
            }
            .navigationDestination(isPresented: $navigateToCheckout) {
                CheckoutView()
            }
            .onAppear {
                print("📦 CartView: Ejecutando loadCart...")
                viewModel.loadCart()
            }
        }
    }
    
    private var emptyCartState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "cart.badge.minus")
                .font(.system(size: 80))
                .foregroundStyle(BrandColors.accent.opacity(0.2))
            
            Text("Tu carrito está vacío")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(BrandColors.darkContrast)
            
            Button(action: { viewModel.loadCart() }) {
                Text("Actualizar Carrito")
                    .font(.system(size: 14, weight: .bold))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(BrandColors.primaryBrand)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
            
            Text("¡Agrega algo delicioso del menú!")
                .font(.system(size: 16))
                .foregroundStyle(BrandColors.accent)
            Spacer()
        }
    }
}



