import gleam/io
import gleam/string
import scanner

import argv
import simplifile

pub fn main() {
  let args = argv.load().arguments

  case args {
    ["tokenize", filename] -> {
      case simplifile.read(filename) {
        Ok(contents) ->
          case run(contents) {
            Ok(_) -> Nil
            Error(_) -> exit(65)
          }
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

pub fn run(source: String) -> Result(Nil, Bool) {
  case string.length(source) {
    0 -> io.println("EOF  null") |> Ok
    _ ->
      scanner.scan(source)
      |> fn(res) {
        scanner.print_tokens(res)
        case res.had_error {
          True -> Error(res.had_error)
          False -> Ok(Nil)
        }
      }
  }
}
