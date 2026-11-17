import 'dart:typed_data';

/// Resultado do compartilhamento.
enum ExportResult { shared, downloaded, cancelled }

/// Fora da web não há implementação (o app alvo é o navegador).
Future<ExportResult> sharePng(
  Uint8List bytes, {
  required String filename,
  required String title,
  required String text,
}) {
  throw UnsupportedError('Compartilhar imagem só é suportado na web.');
}
