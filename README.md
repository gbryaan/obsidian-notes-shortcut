# Nota Rápida

App de barra de menus para macOS que salva notas rápidas direto na sua vault do Obsidian. Sem Dock e sem janela principal: um atalho global abre um painel flutuante (como o Spotlight), você digita e a nota já fica salva.

## Requisitos

- macOS 15 ou mais novo
- Swift 6.2 (Xcode 26 ou as Command Line Tools)
- Uma vault do Obsidian em `~/dev/Pessoal/Obsidian` (veja [Configuração](#configuração))

## Instalação

```bash
./instalar.sh
```

O script compila em release, monta o app em `~/Applications/NotaRapida.app`, assina (ad-hoc) e abre. Rode de novo para atualizar. O ícone aparece na barra de menus.

## Como usar

### Nota nova

Pressione **⌃⌥N** (Control + Option + N) de qualquer app. O painel abre com o cursor pronto para digitar.

- A nota é salva **a cada alteração**, não há botão de OK.
- Ela vai para `Inbox/` da vault, com o nome `AAAA-MM-DD HH-mm-ss.md`.
- **Esc** fecha o painel. Se a nota ficou vazia, ela é movida para a Lixeira.

### Continuar a última

No painel, troque o seletor para **Continuar a última** (ou use o menu da barra de menus). Ele carrega a nota mais recente do `Inbox/` e passa a editá-la.

### Adicionar em Investigar

Selecione um texto em qualquer app, abra o menu do app → **Serviços** → **Adicionar em Investigar** (atalho **⌃⌥I**, se o app mostrar). O trecho é acrescentado como item de lista em `Notas/00 - Investigar.md`, e toca um som de confirmação.

Se o atalho ou o serviço não aparecer, ative em **Ajustes do Sistema → Teclado → Atalhos de Teclado → Serviços**.

### Menu da barra de menus

| Item | O que faz |
|---|---|
| Nova nota (⌃⌥N) | Abre o painel com uma nota nova |
| Continuar a última | Abre o painel editando a nota mais recente |
| Abrir ao iniciar sessão | Liga/desliga a abertura automática no login |
| Sair | Fecha o app |

## Configuração

Os caminhos da vault estão fixos no código. Se a sua vault ficar em outro lugar, edite e rode `./instalar.sh` de novo:

- Inbox: `Nota.inbox` em [`Sources/NotaRapida/Nota.swift`](Sources/NotaRapida/Nota.swift)
- Nota Investigar: `Investigar.nota` em [`Sources/NotaRapida/Investigar.swift`](Sources/NotaRapida/Investigar.swift)

A pasta `Inbox/` precisa existir; se não existir, o app mostra "Não foi possível salvar" no rodapé do painel.

O atalho global fica em `registrarAtalho()` em [`Sources/NotaRapida/AppDelegate.swift`](Sources/NotaRapida/AppDelegate.swift). Ele usa Carbon, então **não pede permissão de Acessibilidade**.

## Desenvolvimento

```bash
swift build   # compila
swift run     # roda direto, sem instalar (o serviço Investigar só funciona instalado)
```
