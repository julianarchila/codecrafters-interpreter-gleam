import gleam/io
import gleam/string
import scanner.{scan_tokens}

import argv
import simplifile

pub fn main() {
  let args = argv.load().arguments

  case args {
    ["tokenize", filename] -> {
      case simplifile.read(filename) {
        Ok(contents) -> run(contents)
        Error(error) -> {
          io.println_error("Error: " <> simplifile.describe_error(error))
          exit(1)
        }
      }
    }
    _ -> {
      io.println_error("Usage: ./your_program.sh tokenize <filename>")
      exit(1)
    }
  }
}

@external(erlang, "erlang", "halt")
pub fn exit(code: Int) -> Nil

pub fn run(source: String) {
  case string.length(source) {
    0 -> io.println("EOF  null")
    _ -> scanner.new(source) |> scan_tokens |> scanner.print_tokens
  }
}
