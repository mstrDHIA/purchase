import 'dart:convert';
import 'dart:html' as html;

/// Triggers a browser download of the provided bytes and returns a short status string.
Future<String> saveFile(List<int> bytes, String fileName) async {
  final content = base64Encode(bytes);
  final anchor = html.document.createElement('a') as html.AnchorElement;
  anchor.href = 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$content';
  anchor.download = fileName;
  html.document.body!.append(anchor);
  anchor.click();
  anchor.remove();
  return 'downloaded';
}
