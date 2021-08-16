#if os(Linux)
import Glibc
#else
import Darwin
#endif
import EnumProperties
import Foundation
import SwiftSyntax
import ArgumentParser

let package_version = "0.1.0"

var window = winsize()

struct GenerateEnumProperties: ParsableCommand {

  static var configuration = CommandConfiguration(
    commandName: "generate-enum-properties",
    abstract: "Generate enum properties (version \(package_version)).")

  @Flag(help: "Print the version.")
  var version: Bool

  @Flag(name: [.customShort("n"), .long], help: "Don't update files in place. Print to stdout instead.")
  var dryRun: Bool
  
  @Flag var includeAll = false

  @Argument(help: "Path(s) to Swift source(s) files(s) containing enum declarations.")
  var sourceFiles: [String]

  func validate() throws {
    if version {
      throw CleanExit.message(package_version)
    }

    if sourceFiles.isEmpty {
      throw CleanExit.helpRequest()
    }
  }

  func run() throws {
    let files = sourceFiles.map { URL.init(fileURLWithPath:$0) }

    for (n, url) in Array(zip(1..., files)) {
      if !dryRun {
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
      let rewriter = EnumPropertyRewriter(includeAll: self.includeAll)
      let updatedSource = rewriter.visit(source).description
      if dryRun {
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
  }

}

GenerateEnumProperties.main()