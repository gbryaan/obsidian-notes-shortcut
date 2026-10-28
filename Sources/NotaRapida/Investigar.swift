import Foundation

/// Acrescenta trechos selecionados em "00 - Investigar" (o que não entendi e quero estudar depois).
enum Investigar {
    // ponytail: caminho fixo da vault, como Nota.inbox; virar preferência se a vault mudar de lugar.
    static let nota = URL(filePath: NSHomeDirectory()).appending(path: "dev/Pessoal/Obsidian/Notas/00 - Investigar.md")

    /// Vira um item de lista; linhas extras ficam recuadas para continuar no mesmo item.
    static func adicionar(_ texto: String, em arquivo: URL = nota) throws {
        let item = texto.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n", with: "\n  ")
        guard !item.isEmpty else { return }
        // Se o arquivo existe e não lê, falha em vez de sobrescrever com só o item novo.
        var atual = FileManager.default.fileExists(atPath: arquivo.path) ? try String(contentsOf: arquivo, encoding: .utf8) : ""
        if !atual.isEmpty, !atual.hasSuffix("\n") { atual += "\n" }
        try (atual + "- \(item)\n").write(to: arquivo, atomically: true, encoding: .utf8)
    }
}
