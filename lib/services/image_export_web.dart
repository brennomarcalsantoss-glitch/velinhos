import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Resultado do compartilhamento.
enum ExportResult { shared, downloaded, cancelled }

/// Compartilha a imagem PNG. Tenta a Web Share API com arquivo (celulares:
/// abre o seletor com WhatsApp, Telegram, etc.). Se o navegador não suportar,
/// baixa o PNG para o aparelho.
Future<ExportResult> sharePng(
  Uint8List bytes, {
  required String filename,
  required String title,
  required String text,
}) async {
  final parts = <JSAny>[bytes.toJS].toJS;

  try {
    final file = web.File(
      parts,
      filename,
      web.FilePropertyBag(type: 'image/png'),
    );
    final data = web.ShareData(
      files: <web.File>[file].toJS,
      title: title,
      text: text,
    );
    if (web.window.navigator.canShare(data)) {
      await web.window.navigator.share(data).toDart;
      return ExportResult.shared;
    }
  } catch (e) {
    // AbortError = a pessoa fechou o seletor de compartilhamento.
    if (e.toString().contains('AbortError')) return ExportResult.cancelled;
    // Qualquer outro erro: cai para o download.
  }

  _download(parts, filename);
  return ExportResult.downloaded;
}

void _download(JSArray<JSAny> parts, String filename) {
  final blob = web.Blob(parts, web.BlobPropertyBag(type: 'image/png'));
  final url = web.URL.createObjectURL(blob);
  final anchor = web.HTMLAnchorElement()
    ..href = url
    ..download = filename;
  anchor.click();
  web.URL.revokeObjectURL(url);
}
