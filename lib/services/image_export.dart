// Seleciona a implementação certa conforme a plataforma:
// na web usa Web Share API / download; em outras plataformas, um stub.
export 'image_export_stub.dart'
    if (dart.library.js_interop) 'image_export_web.dart';
