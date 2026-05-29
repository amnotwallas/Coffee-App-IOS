import SwiftUI

struct OrderHistoryView: View {
    @StateObject private var viewModel = OrderHistoryViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var selectedOrderId: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                BrandColors.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    HStack {
                        Text("Mis Pedidos")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundStyle(BrandColors.darkContrast)
                        Spacer()
                        Button(action: { dismiss() }) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.system(size: 24))
                                .foregroundStyle(BrandColors.accent.opacity(0.3))
                        }
                    }
                    .padding(.horizontal, 25)
                    .padding(.top, 20)
                    .padding(.bottom, 20)
                    
                    if viewModel.isLoading && viewModel.orders.isEmpty {
                        ProgressView()
                            .frame(maxHeight: .infinity)
                    } else if viewModel.orders.isEmpty {
                        emptyState
                    } else {
                        ScrollView {
                            VStack(spacing: 20) {
                                ForEach(viewModel.orders) { order in
                                    OrderHistoryCard(order: order) {
                                        selectedOrderId = order.id
                                    }
                                }
                            }
                            .padding(.horizontal, 25)
                            .padding(.bottom, 30)
                        }
                        .refreshable {
                            viewModel.loadOrders()
                        }
                    }
                }
            }
            .navigationBarHidden(true)
            .onAppear {
                viewModel.loadOrders()
            }
            .sheet(item: Binding(
                get: { selectedOrderId.map { IdentifiableString(id: $0) } },
                set: { selectedOrderId = $0?.id }
            )) { item in
                OrderTrackingView(orderId: item.id)
            }
        }
    }
    
    private var emptyState: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "cup.and.saucer")
                .font(.system(size: 80))
                .foregroundStyle(BrandColors.accent.opacity(0.1))
            
            Text("Aún no tienes pedidos")
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(BrandColors.darkContrast)
            
            Text("¡Anímate a probar algo de nuestro menú!")
                .font(.system(size: 16))
                .foregroundStyle(BrandColors.accent)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
    }
}

#Preview {
    OrderHistoryView()
}
