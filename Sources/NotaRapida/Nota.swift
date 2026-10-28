import Foundation
import Observation

/// Nota sendo editada no painel. Salva a cada alteração; não há "OK".
@Observable
final class Nota {
    enum Modo: String, CaseIterable { case nova = "Nova", continuar = "Continuar a última" }

    // ponytail: caminho fixo da vault; virar preferência se a vault mudar de lugar.
    static let inbox = URL(filePath: NSHomeDirectory()).appending(path: "dev/Pessoal/Obsidian/Inbox")

    var modo = Modo.nova { didSet { carregar() } }
    var texto = "" { didSet { salvar() } }
    private(set) var erro: String?
    /// Muda a cada abertura do painel, para a view devolver o foco ao editor.
    private(set) var aberturas = 0
    private var arquivo: URL?
    /// Só notas criadas nesta abertura podem ser descartadas; nota existente nunca é apagada.
    private var criadaAgora = false

    private func carregar() {
        descartarSeVazia()
        aberturas += 1
        arquivo = modo == .continuar ? Self.ultimaNota() : nil
        criadaAgora = false
        texto = arquivo.flatMap { try? String(contentsOf: $0, encoding: .utf8) } ?? ""
    }

    func fechar() { descartarSeVazia() }

    private func salvar() {
        guard !texto.isEmpty || arquivo != nil else { return }
        let destino = arquivo ?? Self.urlNova()
        do {
            try texto.write(to: destino, atomically: true, encoding: .utf8)
            if arquivo == nil { criadaAgora = true }
            arquivo = destino
            erro = nil
        } catch {
            erro = "Não foi possível salvar: \(error.localizedDescription)"
        }
    }

    private func descartarSeVazia() {
        if criadaAgora, let arquivo, texto.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            try? FileManager.default.trashItem(at: arquivo, resultingItemURL: nil)
        }
    }

    /// Nome pela data; nunca reaproveita um arquivo existente (duas notas no mesmo segundo).
    private static func urlNova() -> URL {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd HH-mm-ss"
        let base = f.string(from: .now)
        var url = inbox.appending(path: base + ".md")
        var n = 2
        while FileManager.default.fileExists(atPath: url.path) {
            url = inbox.appending(path: "\(base) \(n).md")
            n += 1
        }
        return url
    }

    static func ultimaNota() -> URL? {
        let chave = URLResourceKey.creationDateKey
        let arquivos = (try? FileManager.default.contentsOfDirectory(at: inbox, includingPropertiesForKeys: [chave])) ?? []
        return arquivos
            .filter { $0.pathExtension == "md" }
            .max { criacao($0) < criacao($1) }

        func criacao(_ url: URL) -> Date {
            (try? url.resourceValues(forKeys: [chave]).creationDate) ?? .distantPast
        }
    }
}
