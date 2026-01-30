// Conditional export: use web implementation when compiled for the browser, otherwise use IO implementation.
export 'file_download_io.dart' if (dart.library.html) 'file_download_web.dart';

// This makes a top-level `saveFile(List<int>, String)` function available to importers.
