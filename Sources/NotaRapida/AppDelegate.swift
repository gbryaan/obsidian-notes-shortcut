import AppKit
import Carbon.HIToolbox
import ServiceManagement
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    private let nota = Nota()
    private var statusItem: NSStatusItem!
    private var painel: Painel!

    func applicationDidFinishLaunching(_ notification: Notification) {
        painel = Painel()
        painel.contentView = NSHostingView(rootView: NotaView(nota: nota) { [weak self] in self?.fechar() })

        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        statusItem.button?.image = NSImage(systemSymbolName: "square.and.pencil", accessibilityDescription: "Nota Rápida")
        let menu = NSMenu()
        menu.addItem(withTitle: "Nova nota (⌃⌥N)", action: #selector(novaNota), keyEquivalent: "")
        menu.addItem(withTitle: "Continuar a última", action: #selector(continuarUltima), keyEquivalent: "")
        menu.addItem(.separator())
        let login = menu.addItem(withTitle: "Abrir ao iniciar sessão", action: #selector(alternarLogin), keyEquivalent: "")
        login.state = SMAppService.mainApp.status == .enabled ? .on : .off
        menu.addItem(withTitle: "Sair", action: #selector(NSApplication.terminate), keyEquivalent: "q")
        statusItem.menu = menu

        registrarAtalho()
        NSApp.servicesProvider = self
    }

    /// Serviço "Adicionar em Investigar" (NSServices no Info.plist): recebe a seleção do app em primeiro plano.
    @objc func adicionarInvestigar(_ pasteboard: NSPasteboard, userData: String, error erro: AutoreleasingUnsafeMutablePointer<NSString>) {
        guard let texto = pasteboard.string(forType: .string) else {
            erro.pointee = "Nenhum texto selecionado."
            return
        }
        do {
            try Investigar.adicionar(texto)
            NSSound(named: "Pop")?.play()
        } catch {
            erro.pointee = "Não foi possível salvar em Investigar: \(error.localizedDescription)" as NSString
        }
    }

    @objc func novaNota() { mostrar(.nova) }
    @objc func continuarUltima() { mostrar(.continuar) }

    func mostrar(_ modo: Nota.Modo) {
        nota.modo = modo
        painel.makeKeyAndOrderFront(nil)
    }

    private func fechar() {
        nota.fechar()
        painel.orderOut(nil)
    }

    @objc private func alternarLogin(_ item: NSMenuItem) {
        let servico = SMAppService.mainApp
        try? servico.status == .enabled ? servico.unregister() : servico.register()
        item.state = servico.status == .enabled ? .on : .off
    }

    /// ⌃⌥N global via Carbon: não exige permissão de Acessibilidade.
    private func registrarAtalho() {
        var tipo = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { _, _, _ in
            // Carbon entrega eventos de teclado na main thread.
            MainActor.assumeIsolated { (NSApp.delegate as? AppDelegate)?.novaNota() }
            return noErr
        }, 1, &tipo, nil, nil)

        var ref: EventHotKeyRef?
        let id = EventHotKeyID(signature: OSType(0x4E52_5044), id: 1) // "NRPD"
        RegisterEventHotKey(UInt32(kVK_ANSI_N), UInt32(controlKey | optionKey), id, GetApplicationEventTarget(), 0, &ref)
    }
}

/// Painel flutuante que recebe teclado sem ativar o app (como o Spotlight).
final class Painel: NSPanel {
    init() {
        super.init(contentRect: NSRect(x: 0, y: 0, width: 460, height: 320),
                   styleMask: [.titled, .closable, .resizable, .fullSizeContentView, .nonactivatingPanel],
                   backing: .buffered, defer: false)
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isMovableByWindowBackground = true
        level = .floating
        hidesOnDeactivate = false
        isReleasedWhenClosed = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        center()
        setFrameAutosaveName("NotaRapida")
    }

    override var canBecomeKey: Bool { true }

    /// App sem menu principal (só barra de menus): os atalhos de edição não chegam sozinhos ao editor.
    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let mods = event.modifierFlags.intersection(.deviceIndependentFlagsMask)
        guard mods.subtracting(.shift) == .command, let tecla = event.charactersIgnoringModifiers?.lowercased() else {
            return super.performKeyEquivalent(with: event)
        }
        let acao: Selector? = switch (tecla, mods.contains(.shift)) {
        case ("a", false): #selector(NSText.selectAll(_:))
        case ("c", false): #selector(NSText.copy(_:))
        case ("v", false): #selector(NSText.paste(_:))
        case ("x", false): #selector(NSText.cut(_:))
        case ("z", false): Selector(("undo:"))
        case ("z", true): Selector(("redo:"))
        default: nil
        }
        if let acao, NSApp.sendAction(acao, to: nil, from: self) { return true }
        return super.performKeyEquivalent(with: event)
    }
}
