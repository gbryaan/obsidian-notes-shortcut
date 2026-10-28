import SwiftUI

struct NotaView: View {
    @Bindable var nota: Nota
    let fechar: () -> Void
    @FocusState private var focado: Bool

    var body: some View {
        VStack(spacing: 8) {
            Picker("Modo", selection: $nota.modo) {
                ForEach(Nota.Modo.allCases, id: \.self) { Text($0.rawValue) }
            }
            .pickerStyle(.segmented)
            .labelsHidden()

            TextEditor(text: $nota.texto)
                .font(.body)
                .scrollContentBackground(.hidden)
                .focused($focado)
                .onKeyPress(.escape) {
                    fechar()
                    return .handled
                }

            if let erro = nota.erro {
                Text(erro).font(.caption).foregroundStyle(.red)
            } else {
                Text("Salvo automaticamente no Inbox · Esc fecha")
                    .font(.caption).foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.top, 28)
        .padding(.bottom, 10)
        .background(.regularMaterial)
        .onChange(of: nota.aberturas, initial: true) { focado = true }
    }
}
