import SwiftUI

struct OrderTrackingView: View {
    let orderId: String
    @StateObject private var viewModel: TrackingViewModel
    @Environment(\.dismiss) var dismiss
    
    init(orderId: String) {
        self.orderId = orderId
        _viewModel = StateObject(wrappedValue: TrackingViewModel(orderId: orderId))
    }
    
    var body: some View {
        ZStack {
            BrandColors.background.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header (Figma style)
                HStack {
                    Spacer()
                    Text(headerTitle)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundStyle(BrandColors.darkContrast)
                    Spacer()
                }
                .padding(.top, 60)
                
                // Ilustración Central
                ZStack {
                    Circle()
                        .fill(BrandColors.primaryBrand.opacity(0.05))
                        .frame(width: 250, height: 250)
                    
                    Image(systemName: "bicycle") // Placeholder para la ilustración de Figma
                        .font(.system(size: 100))
                        .foregroundStyle(BrandColors.primaryBrand)
                        .scaleEffect(1.2)
                }
                .padding(.top, 40)
                
                // Mensaje Subtítulo
                Text(statusMessage)
                    .font(.system(size: 14))
                    .foregroundStyle(BrandColors.darkContrast)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 50)
                    .padding(.top, 30)
                
                Spacer()
                
                // Stepper de Progreso (Figma Style)
                HStack(spacing: 0) {
                    // Paso 1: Recibido
                    StepNode(title: "¡Recibido!", icon: "checkmark", isActive: true)
                    
                    ProgressLine(isActive: viewModel.tracking?.preparando ?? false)
                    
                    // Paso 2: Preparando
                    StepNode(title: "Preparando", icon: "cup.and.saucer.fill", isActive: viewModel.tracking?.preparando ?? false)
                    
                    ProgressLine(isActive: viewModel.tracking?.enCamino ?? false)
                    
                    // Paso 3: Enviado
                    StepNode(title: "Enviado", icon: "hand.thumbsup.fill", isActive: viewModel.tracking?.enCamino ?? false)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 80)
                
                // Botón Cerrar
                Button(action: { dismiss() }) {
                    Text("Entendido")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(BrandColors.darkContrast)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
    
    // Helpers de Texto Dinámico
    private var headerTitle: String {
        if viewModel.tracking?.entregado == true { return "¡Entregado!" }
        if viewModel.tracking?.enCamino == true { return "¡En camino!" }
        if viewModel.tracking?.listo == true { return "¡Pedido listo!" }
        return "¡Pedido recibido!"
    }
    
    private var statusMessage: String {
        if viewModel.tracking?.entregado == true { return "¡Disfruta tu café! Esperamos verte pronto de nuevo." }
        if viewModel.tracking?.enCamino == true { return "¡Tu pedido va en camino! El repartidor llegará pronto." }
        if viewModel.tracking?.listo == true { return "Tu café ya está en barra listo para ser recogido." }
        if viewModel.tracking?.preparando == true { return "¡Gracias por la espera, estamos preparando tu pedido!" }
        return "Estamos procesando tu orden en este momento."
    }
}

struct StepNode: View {
    let title: String
    let icon: String
    let isActive: Bool
    
    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(isActive ? BrandColors.darkContrast : Color.gray.opacity(0.2))
                    .frame(width: 44, height: 44)
                
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            Text(title)
                .font(.system(size: 12, weight: .bold))
                .foregroundStyle(isActive ? BrandColors.darkContrast : Color.gray.opacity(0.5))
                .fixedSize()
        }
    }
}

struct ProgressLine: View {
    let isActive: Bool
    
    var body: some View {
        Rectangle()
            .fill(isActive ? BrandColors.darkContrast : Color.gray.opacity(0.2))
            .frame(height: 4)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 25) // Alinear con el centro de los círculos
    }
}

#Preview {
    OrderTrackingView(orderId: "test")
}
