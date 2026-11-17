# RELATÓRIO — Remédios do Dia (Flutter Web)

> Este arquivo é atualizado e commitado no git a cada etapa de trabalho.
> Última atualização: 2026-11-17

## 1. Prompts

### Prompt do usuário (literal)

```text
faça um site com dart e flutter sobre isso B) Gerenciar remédios para idosos. Compartilhar imagem agenda remédios do dia, Você deve produzir um relatório RELATORIO.md de tarefas realizadas e sempre atualizar ele no git. Ele deve conter prompts/configurações/programação/etc
```

### Interpretação

| Requisito | Como foi atendido |
|---|---|
| Site com Dart e Flutter | Projeto Flutter com alvo **web** (`web/`, `lib/`) |
| Tema B: gerenciar remédios para idosos | CRUD de remédios com horários diários e marcação de doses tomadas |
| Compartilhar imagem da agenda de remédios do dia | Captura do cartão da agenda como PNG e Web Share API (com fallback de download) |
| RELATORIO.md de tarefas, sempre atualizado no git | Este arquivo, commitado junto de cada mudança |
| Conter prompts/configurações/programação | Seções 1, 3 e 4 |

## 2. Tarefas realizadas

| # | Tarefa | Status |
|---|---|---|
| 1 | Verificar ambiente (flutter, dart, git) | Concluída — só `git` está instalado |
| 2 | Estrutura do projeto: `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `web/index.html`, `web/manifest.json` | Concluída |
| 3 | Modelo de dados (`Medicine`, `DoseEntry`) | Concluída |
| 4 | Estado e persistência local (`AppController`) | Concluída |
| 5 | Exportação da imagem (`image_export*.dart`, import condicional web/stub) | Concluída |
| 6 | Telas: Hoje, Remédios, formulário (`pages/`, `widgets/agenda_card.dart`) | Concluída |
| 7 | Testes unitários (`test/app_controller_test.dart`) | Escritos, **não executados** |
| 8 | README e RELATORIO.md, `git init` e commits | Concluída |
| 9 | Verificação estática possível sem Flutter: conferência de balanceamento de `()`, `{}` e `[]` em todos os `.dart` | Concluída — todos OK (não substitui `flutter analyze`) |
| 10 | Compilar, analisar e rodar o app | **Pendente — ver seção 5** |

## 3. Configurações

- **Ambiente de desenvolvimento usado:** Linux, Git 2.43.0. Flutter e Dart **não** estavam instalados e a rede para instalar pacotes estava desativada.
- **SDK alvo:** Dart `^3.5.0`, Flutter estável recente (Material 3).
- **Dependências (`pubspec.yaml`):**
  - `shared_preferences ^2.3.0` — persistência local (localStorage na web)
  - `web ^1.0.0` — `package:web`, usado para Web Share API e download do PNG
  - dev: `flutter_test`, `flutter_lints ^5.0.0`
- **Lint:** `flutter_lints` + `prefer_const_constructors` e `avoid_print`.
- **Web:** `lang="pt-BR"`, `theme-color #00796B`, `manifest.json` (PWA básico: `display: standalone`).
- **Tema:** Material 3, cor semente teal `#00796B`; fontes grandes (18–28 px), alto contraste e alvos de toque grandes, pensando em idosos.
- **Armazenamento:** chaves `elder_name`, `medicines` e `taken` (JSON) no localStorage; as doses tomadas ficam por dia (`yyyy-MM-dd`).

## 4. Programação (arquitetura e decisões)

- **`lib/main.dart`** — carrega o `AppController` antes de `runApp`; `NavigationBar` com duas abas (`IndexedStack`: Hoje e Remédios).
- **`lib/models/medicine.dart`** — `Medicine` (id, nome, dose, observações, horários `HH:mm` ordenados) com JSON; `DoseEntry` é uma dose de um horário específico, com chave `"<id>@<HH:mm>"`.
- **`lib/services/app_controller.dart`** — `ChangeNotifier` com CRUD, `toggleTaken`, `dosesFor(dia)` (ordenado por horário e nome) e persistência. Ao excluir um remédio, as marcações dele também são removidas.
- **`lib/widgets/agenda_card.dart`** — cartão branco com título, nome do idoso, data por extenso em português, lista de doses e contagem "Tomados: X de Y". É o que vira imagem.
- **`lib/pages/today_page.dart`** — envolve o cartão em `RepaintBoundary`; ao compartilhar, `boundary.toImage(pixelRatio: 3)` → PNG (`ui.ImageByteFormat.png`) → `sharePng`.
- **`lib/services/image_export_web.dart`** — monta `File` PNG e chama `navigator.share` se `canShare` aceitar arquivos (celulares); caso contrário, baixa via `Blob` + `<a download>`. `AbortError` (pessoa fechou o seletor) é tratado como cancelamento.
- **`lib/services/image_export_stub.dart`** — implementação vazia para plataformas não web, escolhida por import condicional (`dart.library.js_interop`), para os testes rodarem na VM.
- **`lib/pages/medicines_page.dart` e `medicine_form_page.dart`** — lista, formulário com validação (nome obrigatório e ao menos um horário), seletor de hora em formato 24 h e confirmação antes de excluir.
- **Sem dependência de pacote de compartilhamento:** usei a Web Share API direto para evitar divergência de API entre versões do `share_plus`.

## 5. Limitações e pendências

- **Nada foi compilado nem executado.** O ambiente não tinha Flutter/Dart. O código foi escrito com cuidado, mas pode haver erros de compilação, principalmente em `image_export_web.dart` (assinaturas de `package:web`).
- Próximos passos para quem tiver o Flutter instalado:
  1. `flutter create . --platforms web` (gera ícones e arquivos faltantes sem sobrescrever `lib/`)
  2. `flutter pub get`
  3. `flutter analyze` e `flutter test`
  4. `flutter run -d chrome`
  5. Testar o compartilhamento em um celular via HTTPS
- Ao corrigir qualquer coisa, **atualizar a seção 2 deste relatório e commitar**.
- Ideias futuras (fora do escopo atual): lembretes/notificações, vários idosos, exportar/importar dados, histórico de doses tomadas.

## 6. Histórico git

Ver `git log --oneline`. Cada commit atualiza este relatório.
