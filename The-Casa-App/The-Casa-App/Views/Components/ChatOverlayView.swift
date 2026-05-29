import SwiftUI

struct ChatOverlayView: View {
    @ObservedObject var viewModel: ChatViewModel
    @State private var inputText: String = ""
    @FocusState private var isInputFocused: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text("Barista AI")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundStyle(BrandColors.darkContrast)
                
                Spacer()
                
                // Botón para nueva consulta
                Button(action: {
                    withAnimation {
                        viewModel.clearChat()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle")
                        Text("Nuevo")
                            .font(.system(size: 12, weight: .medium))
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(BrandColors.primaryBrand.opacity(0.1))
                    .foregroundStyle(BrandColors.primaryBrand)
                    .cornerRadius(10)
                }
                .disabled(viewModel.isLoading)
                
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(0.8)
                        .padding(.leading, 8)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 15)
            .padding(.bottom, 10)
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Messages List
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(viewModel.messages) { msg in
                            ChatBubble(message: msg)
                                .id(msg.id)
                        }
                    }
                    .padding(.vertical, 15)
                    .padding(.horizontal, 15)
                }
                .onChange(of: viewModel.messages.last?.text) { _ in
                    if let lastId = viewModel.messages.last?.id {
                        withAnimation {
                            proxy.scrollTo(lastId, anchor: .bottom)
                        }
                    }
                }
            }
            
            // Input Area
            HStack(spacing: 12) {
                TextField("Pregúntame algo...", text: $inputText)
                    .font(.system(size: 15))
                    .padding(12)
                    .background(Color.white.opacity(0.4))
                    .cornerRadius(15)
                    .focused($isInputFocused)
                
                Button(action: sendMessage) {
                    ZStack {
                        Circle()
                            .fill(inputText.isEmpty ? Color.gray.opacity(0.3) : BrandColors.primaryBrand)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "paperplane.fill")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.white)
                    }
                }
                .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || viewModel.isLoading)
            }
            .padding(.horizontal, 15)
            .padding(.bottom, 15)
            .padding(.top, 10)
            .background(Color.white.opacity(0.2))
        }
        .frame(maxWidth: .infinity)
        .frame(height: UIScreen.main.bounds.height * 0.45)
        .background(.ultraThinMaterial)
        .cornerRadius(25)
        .overlay(
            RoundedRectangle(cornerRadius: 25)
                .stroke(Color.white.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.15), radius: 20, x: 0, y: 10)
        // Triángulo indicador (Tooltip tail)
        .overlay(
            TooltipTail()
                .fill(.ultraThinMaterial)
                .frame(width: 20, height: 10)
                .offset(y: 5),
            alignment: .bottom
        )
    }
    
    private func sendMessage() {
        let text = inputText
        inputText = ""
        viewModel.sendMessage(text)
        // No ocultamos el teclado para permitir conversación fluida
    }
}

struct ChatBubble: View {
    let message: ChatMessage
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 8) {
            if message.isUser { Spacer() }
            
            if !message.isUser {
                // Avatar o Icono del Barista
                ZStack {
                    Circle()
                        .fill(BrandColors.primaryBrand.opacity(0.1))
                    Image(systemName: "cup.and.saucer.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(BrandColors.primaryBrand)
                }
                .frame(width: 24, height: 24)
            }
            
            Text(message.text)
                .font(.system(size: 14))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(message.isUser ? BrandColors.primaryBrand : Color.white.opacity(0.6))
                .foregroundStyle(message.isUser ? .white : BrandColors.darkContrast)
                .cornerRadius(18, corners: message.isUser ? [.topLeft, .topRight, .bottomLeft] : [.topLeft, .topRight, .bottomRight])
            
            if !message.isUser { Spacer() }
        }
    }
}

// Helper para redondear esquinas específicas
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// Triángulo para el efecto tooltip
struct TooltipTail: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        ChatOverlayView(viewModel: ChatViewModel())
            .padding()
    }
}
