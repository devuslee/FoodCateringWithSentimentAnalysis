import 'dart:async';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LexiconStorage {
  Future<Directory> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/test.txt');
  }

  Future<String> readLexicon() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      return contents;
    } catch (e) {
      return 'Error: $e';
    }
  }
}