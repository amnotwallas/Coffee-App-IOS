import SwiftUI

struct SkeletonView: View {
    @State private var opacity = 0.3
    
    var body: some View {
        Rectangle()
            .fill(Color.gray.opacity(opacity))
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    opacity = 0.1
                }
            }
    }
}

struct ProductCardSkeleton: View {
    var body: some View {
        ZStack(alignment: .top) {
            // Fondo de la tarjeta
            VStack(alignment: .leading, spacing: 8) {
                Spacer().frame(height: 150)
                
                // Intensidad y Precio
                HStack {
                    SkeletonView()
                        .frame(width: 80, height: 14)
                        .cornerRadius(4)
                    Spacer()
                    SkeletonView()
                        .frame(width: 60, height: 20)
                        .cornerRadius(4)
                }
                .padding(.horizontal, 16)
                
                // Rating (Placeholder)
                SkeletonView()
                    .frame(width: 40, height: 10)
                    .cornerRadius(4)
                    .padding(.horizontal, 16)
                    .padding(.top, -4)
                
                // Nombre
                SkeletonView()
                    .frame(width: 160, height: 18)
                    .cornerRadius(4)
                    .padding(.horizontal, 16)
                    .padding(.top, 2)
                
                // Descripción
                VStack(alignment: .leading, spacing: 4) {
                    SkeletonView()
                        .frame(height: 10)
                        .cornerRadius(2)
                    SkeletonView()
                        .frame(width: 120, height: 10)
                        .cornerRadius(2)
                }
                .padding(.horizontal, 16)
                
                // Nutrición y Botón
                HStack(alignment: .bottom) {
                    HStack(spacing: 4) {
                        SkeletonView()
                            .frame(width: 40, height: 14)
                            .cornerRadius(7)
                        SkeletonView()
                            .frame(width: 40, height: 14)
                            .cornerRadius(7)
                        SkeletonView()
                            .frame(width: 40, height: 14)
                            .cornerRadius(7)
                    }
                    
                    Spacer()
                    
                    SkeletonView()
                        .frame(width: 36, height: 34)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .background(BrandColors.accent.opacity(0.2))
            .cornerRadius(22)
            .padding(.top, 50)
            
            // Imagen
            Circle()
                .fill(Color.gray.opacity(0.1))
                .frame(width: 220, height: 220)
        }
        .frame(width: 260)
    }
}

struct WelcomeHeaderSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SkeletonView()
                    .frame(width: 100, height: 24)
                    .cornerRadius(6)
                Spacer()
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 28, height: 28)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                SkeletonView()
                    .frame(height: 14)
                    .cornerRadius(4)
                SkeletonView()
                    .frame(width: 200, height: 14)
                    .cornerRadius(4)
            }
            
            SkeletonView()
                .frame(width: 150, height: 16)
                .cornerRadius(4)
                .padding(.top, 5)
        }
        .padding(25)
        .background(BrandColors.accent.opacity(0.3))
        .cornerRadius(30)
        .padding(.horizontal)
    }
}
