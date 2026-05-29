import SwiftUI

struct EditProfileFormView: View {
    let currentNombre: String
    let currentTelefono: String
    var onSave: (String, String) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var nombre: String = ""
    @State private var telefono: String = ""
    @State private var selectedAreaCode = "+52"
    
    var body: some View {
        ZStack {
            BrandColors.background.ignoresSafeArea()
            
            // "Beans" decorativos de fondo
            ZStack {
                Image("bean")
                    .resizable()
                    .frame(width: 250, height: 250)
                    .rotationEffect(.degrees(20))
                    .opacity(0.04)
                    .offset(x: 150, y: -250)
                
                Image("bean")
                    .resizable()
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-30))
                    .opacity(0.04)
                    .offset(x: -150, y: 250)
            }
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Text("Actualizar Perfil")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(BrandColors.darkContrast)
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundStyle(BrandColors.accent.opacity(0.3))
                    }
                }
                .padding(.top, 20)
                
                // Formulario (Glassmorphism Style)
                VStack(spacing: 20) {
                    // Campo Nombre
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Nombre Completo")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(BrandColors.accent)
                        
                        TextField("Tu nombre", text: $nombre)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(15)
                            .overlay(RoundedRectangle(cornerRadius: 15).stroke(BrandColors.accent.opacity(0.1), lineWidth: 1))
                    }
                    
                    // Campo Teléfono
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Teléfono")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundStyle(BrandColors.accent)
                        
                        HStack(spacing: 10) {
                            Menu {
                                Button("🇲🇽 +52") { selectedAreaCode = "+52" }
                                Button("🇺🇸 +1") { selectedAreaCode = "+1" }
                                Button("🇨🇴 +57") { selectedAreaCode = "+57" }
                                Button("🇪🇸 +34") { selectedAreaCode = "+34" }
                            } label: {
                                Text(selectedAreaCode)
                                    .font(.system(size: 16, weight: .bold))
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 14)
                                    .background(Color.white.opacity(0.8))
                                    .cornerRadius(12)
                                    .foregroundStyle(BrandColors.darkContrast)
                            }
                            
                            TextField("10 dígitos", text: $telefono)
                                .keyboardType(.numberPad)
                                .padding()
                                .background(Color.white.opacity(0.8))
                                .cornerRadius(15)
                                .overlay(RoundedRectangle(cornerRadius: 15).stroke(BrandColors.accent.opacity(0.1), lineWidth: 1))
                        }
                    }
                }
                .padding(25)
                .background(.ultraThinMaterial)
                .cornerRadius(25)
                .shadow(color: .black.opacity(0.05), radius: 15, y: 10)
                
                Spacer()
                
                // Botón Guardar
                Button(action: {
                    onSave(nombre, selectedAreaCode + telefono)
                    dismiss()
                }) {
                    Text("Guardar Cambios")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(BrandColors.darkContrast)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .disabled(nombre.isEmpty || telefono.count < 10)
            }
            .padding(25)
        }
        .onAppear {
            self.nombre = currentNombre
            // Extraer código de área si existe en el teléfono actual
            if currentTelefono.starts(with: "+") {
                // Lógica simple para demo
                if currentTelefono.count >= 13 {
                    self.selectedAreaCode = String(currentTelefono.prefix(3))
                    self.telefono = String(currentTelefono.dropFirst(3))
                }
            } else {
                self.telefono = currentTelefono
            }
        }
    }
}
