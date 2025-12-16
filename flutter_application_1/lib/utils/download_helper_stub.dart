import 'dart:typed_data';

Future<void> saveAsFile(Uint8List bytes, String filename) async {
  // Not implemented on this platform — fall back to other behavior by the caller.
  throw UnsupportedError('saveAsFile is only supported on web');
}
