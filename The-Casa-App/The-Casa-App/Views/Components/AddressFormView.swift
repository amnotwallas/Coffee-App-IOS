import SwiftUI

struct AddressFormView: View {
    var onSave: (String, String, String, String?, Bool) -> Void
    @Environment(\.dismiss) var dismiss
    
    @State private var calle: String = ""
    @State private var ciudad: String = ""
    @State private var codigoPostal: String = ""
    @State private var referencia: String = ""
    @State private var esDefault: Bool = false
    
    var body: some View {
        ZStack {
            BrandColors.background.ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                HStack {
                    Text("Nueva Dirección")
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
                
                ScrollView {
                    VStack(spacing: 20) {
                        FormField(label: "Calle y Número", placeholder: "Ej. Av. Reforma 123", text: $calle)
                        FormField(label: "Ciudad", placeholder: "Ej. CDMX", text: $ciudad)
                        FormField(label: "Código Postal", placeholder: "5 dígitos", text: $codigoPostal)
                            .keyboardType(.numberPad)
                        FormField(label: "Referencia (Opcional)", placeholder: "Ej. Portón café", text: $referencia)
                        
                        Toggle("Dirección Principal", isOn: $esDefault)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(BrandColors.darkContrast)
                            .tint(BrandColors.primaryBrand)
                            .padding(.top, 10)
                    }
                    .padding(25)
                    .background(.ultraThinMaterial)
                    .cornerRadius(25)
                }
                
                Spacer()
                
                // Botón Guardar
                Button(action: {
                    onSave(calle, ciudad, codigoPostal, referencia.isEmpty ? nil : referencia, esDefault)
                    dismiss()
                }) {
                    Text("Guardar Dirección")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(BrandColors.darkContrast)
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                }
                .disabled(calle.isEmpty || ciudad.isEmpty || codigoPostal.isEmpty)
            }
            .padding(25)
        }
    }
}

struct FormField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(BrandColors.accent)
            
            TextField(placeholder, text: $text)
                .keyboardType(keyboardType)
                .padding()
                .background(Color.white.opacity(0.8))
                .cornerRadius(15)
                .overlay(RoundedRectangle(cornerRadius: 15).stroke(BrandColors.accent.opacity(0.1), lineWidth: 1))
        }
    }
}
