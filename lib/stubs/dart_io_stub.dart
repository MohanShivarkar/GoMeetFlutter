// lib/stubs/dart_io_stub.dart
//
// Web stub for dart:io File and Platform types.
// Selected by conditional import when dart.library.html is available.
// Provides dummy implementations so web-targeted code compiles.

// ignore_for_file: avoid_classes_with_only_static_members

class File {
  final String path;
  const File(this.path);
  Future<List<int>> readAsBytes() async => [];
  Future<String> readAsString() async => '';
  bool existsSync() => false;
  Future<bool> exists() async => false;
  String get uri => path;
}

class Directory {
  final String path;
  const Directory(this.path);
  bool existsSync() => false;
  Future<bool> exists() async => false;
}

class Platform {
  static bool get isAndroid => false;
  static bool get isIOS => false;
  static bool get isMacOS => false;
  static bool get isWindows => false;
  static bool get isLinux => false;
  static bool get isFuchsia => false;
  static String get operatingSystem => 'browser';
}
