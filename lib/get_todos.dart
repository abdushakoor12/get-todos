import 'dart:io';

String fileSeparator = Platform.pathSeparator;

// TODO convert this into a class
Future<void> getTodos(Directory dir) async {
  List<ProjectTodo> todos = [];

  final rootEntries = dir.listSync();
  for (final entity in rootEntries) {
    final entityName = entity.path.split(fileSeparator).last;
    if (entityName.startsWith(".")) {
      continue;
    }

    if (await FileSystemEntity.isDirectory(entity.path)) {
      for (final entity in Directory(entity.path).listSync(recursive: true)) {
        final entityName = entity.path.split(fileSeparator).last;

        if (entityName.endsWith(".dart")) {
          final contents = await File(entity.path).readAsString();
          final lines = contents.split("\n");
          for (var i = 0; i < lines.length; i++) {
            final line = lines[i];
            var regex = RegExp(r"//\s*TODO\s*(.*)");
            if (regex.hasMatch(line)) {
              List<String> contentLines = [];

              for (var j = i - 2; j < i; j++) {
                if (j >= 0) {
                  contentLines.add(lines[j]);
                }
              }
              contentLines.add(line);
              for (var j = i + 1; j < i + 3; j++) {
                if (j < lines.length) {
                  contentLines.add(lines[j]);
                }
              }

              todos.add(ProjectTodo(
                lineNumber: i + 1,
                filePath: entity.path,
                todoContent: contentLines.join("\n"),
              ));
            }
          }
        }
      }
    }
  }

  if (todos.isNotEmpty) {
    print("Found ${todos.length} TODOs");
    final htmlString = getHtmlString(todos);
    // make a file in build/get-todos/index.html
    final file = File(
        "${dir.path}${fileSeparator}build${fileSeparator}get-todos${fileSeparator}index.html");
    await file.create(recursive: true);
    await file.writeAsString(htmlString);

    // open the file in the browser
    final url = file.absolute.path;
    print("Opening $url");
    await Process.run("start", [url], runInShell: true);
  } else {
    print("No TODOs found");
  }
}

String getHtmlString(List<ProjectTodo> todo) {
  return """
  <!DOCTYPE html>
  <html>
    <head>
      <title>TODO</title>
        <script src="https://cdn.tailwindcss.com"></script>
    </head>
    <body class="p-8">
      <h1
      class="text-4xl text-center text-blue-500"
      >TODOs</h1>
      ${todo.map((e) {
    return """
            <h2
            class="text-red-500"
            >${e.filePath} - Line ${e.lineNumber}</h2>
            <code
            class="text-sm text-gray-500 bg-gray-100 p-2 rounded-lg block mt-2"
            >
              ${e.todoContent.replaceAll("\n", "<br>")}
            </code>
          """;
  }).join("\n")}   
    </body>
  """;
}

class ProjectTodo {
  final int lineNumber;
  final String filePath;
  final String todoContent;

  ProjectTodo({
    required this.lineNumber,
    required this.filePath,
    required this.todoContent,
  });
}
