import 'dart:io';

import 'package:args/args.dart';
import 'package:get_todos/get_todos.dart';

void main(List<String> arguments) {
  final parser = ArgParser();

  ArgResults argResults = parser.parse(arguments);
  final paths = argResults.rest;

  final path = paths.isNotEmpty ? paths.first : Directory.current.path;

  getTodos(Directory(path));
}
