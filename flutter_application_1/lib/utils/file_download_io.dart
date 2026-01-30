import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Saves bytes to the application's Documents directory and returns the saved path.
Future<String> saveFile(List<int> bytes, String fileName) async {
  final dir = await getApplicationDocumentsDirectory();
  final filePath = '${dir.path}${Platform.pathSeparator}$fileName';
  final file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);
  return filePath;
}
