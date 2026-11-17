# Remédios do Dia

Site (Flutter Web / Dart) para **gerenciar remédios de idosos** e **compartilhar como imagem a agenda de remédios do dia** (WhatsApp, Telegram etc.).

## Funcionalidades

- Cadastro, edição e exclusão de remédios (nome, dose, observações, vários horários por dia).
- Aba **Hoje**: agenda do dia ordenada por horário, com marcação de dose tomada.
- Botão **Compartilhar imagem**: gera um PNG da agenda (fonte grande, alto contraste) e abre o seletor de compartilhamento do celular; se o navegador não suportar, baixa o PNG.
- Dados salvos localmente no navegador (localStorage via `shared_preferences`), sem servidor.

## Como rodar

Requer [Flutter](https://docs.flutter.dev/get-started/install) (Dart incluso).

```bash
cd remedios_idosos
flutter create . --platforms web   # gera ícones e arquivos web que faltam (não sobrescreve lib/)
flutter pub get
flutter test
flutter run -d chrome              # desenvolvimento
flutter build web --release        # saída em build/web
```

> Compartilhar arquivos pela Web Share API exige **HTTPS** (ou localhost).
> O `flutter run -d chrome` em localhost funciona.

## Estrutura

```
lib/
  main.dart                      # app e navegação (Hoje / Remédios)
  models/medicine.dart           # Medicine, DoseEntry
  services/app_controller.dart   # estado + persistência
  services/image_export*.dart    # compartilhar/baixar PNG (web)
  pages/                         # today_page, medicines_page, medicine_form_page
  widgets/agenda_card.dart       # cartão capturado como imagem
  utils/date_format_pt.dart      # datas em português
test/app_controller_test.dart
RELATORIO.md                     # relatório de tarefas (atualizado a cada commit)
```

Veja o [RELATORIO.md](RELATORIO.md) para o histórico de tarefas, prompts e decisões.
