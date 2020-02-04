#if os(Linux)
import Glibc
#else
import Darwin
#endif
import EnumProperties
import Foundation
import SwiftSyntax

let allFlags: Set = ["-h", "--help", "-n", "--dry-run", "--version"]
let version = "0.1.0"

var window = winsize()

let command = URL(fileURLWithPath: CommandLine.arguments[0]).lastPathComponent
let arguments = CommandLine.arguments.dropFirst()
let flags = Set(arguments.filter { $0.starts(with: "-") })
let unrecognized = flags.subtracting(allFlags)
let usage = """
Generate enum properties (version \(version)).

usage: \(command) [--help|-h] [--dry-run|-n] [<file>...]

    -h, --help
        Print this message.

    -n, --dry-run
        Don't update files in place. Print to stdout instead.

    --version
        Print the version.

"""

guard unrecognized.isEmpty else {
  fputs(
    """
    Unrecognized flags: \(unrecognized.sorted().joined(separator: ", "))

    \(usage)

    """,
    stderr
  )
  exit(1)
}

let helpFlag = flags.contains(where: { $0 == "-h" || $0 == "--help" })
  || arguments.isEmpty
let dryRunFlag = flags.contains(where: { $0 == "-n" || $0 == "--dry-run" })
let versionFlag = flags.contains(where: { $0 == "--version" })

guard !helpFlag else {
  fputs("\(usage)\n", stderr)
  exit(1)
}

guard !versionFlag else {
  print(version)
  exit(0)
}

let files = arguments
  .lazy
  .filter { !$0.starts(with: "-") }
  .map { URL(fileURLWithPath: $0) }

for (n, url) in Array(zip(1..., files)) {
  if !dryRunFlag {
    var message = files.count == 1
      ? "Updating "
      : "[\(n)/\(files.count)] Updating "

    #if os(Linux)
    message.append(url.relativePath)
    #else
    if
      files.count != 1,
      ioctl(STDOUT_FILENO, TIOCGWINSZ, &window) == 0,
      window.ws_col > 1,
      message.count + url.relativePath.count > Int(window.ws_col)
    {
      message.insert(contentsOf: "\u{001B}[0K\r", at: message.startIndex)
      message.append("…" + String(url.relativePath.suffix(Int(window.ws_col) - message.count - 1)))
    } else {
      message.append(url.relativePath)
    }
    #endif

    fputs(message, stderr)
  }
  let source = try SyntaxParser.parse(url)
  let rewriter = EnumPropertyRewriter()
  let updatedSource = rewriter.visit(source).description
  if dryRunFlag {
    if files.count != 1 {
      fputs("// \(url.path)\n", stderr)
    }
    if updatedSource != source.description {
      print(updatedSource.description)
    } else {
      fputs("(No changes.)\n", stderr)
    }
  } else {
    if updatedSource != source.description {
      try updatedSource.description.write(to: url, atomically: true, encoding: .utf8)
    }
    if n == files.count {
      fputs("\n", stderr)
    } else {
      fputs("\u{001B}[0K\r", stderr)
    }
  }
}
