//// Main entry point for the tokenizer application.
//// Handles command-line arguments and file processing.

import argv
import gleam/io
import gleam/result
import gleam/string
import scanner.{type ScanError}
import simplifile

pub type AppError {
  FileError(simplifile.FileError)
  ScanError(ScanError)
  UsageError
}

pub fn main() {
  let args = argv.load().arguments

  case process_args(args) {
    Ok(_) -> Nil
    Error(error) -> {
      print_error(error)
      exit(get_exit_code(error))
    }
  }
}

fn process_args(args: List(String)) -> Result(Nil, AppError) {
  case args {
    ["tokenize", filename] -> process_file(filename)
    _ -> Error(UsageError)
  }
}

fn process_file(filename: String) -> Result(Nil, AppError) {
  use contents <- result.try(
    simplifile.read(filename)
    |> result.map_error(FileError),
  )

  use _ <- result.try(
    tokenize_source(contents)
    |> result.map_error(ScanError),
  )

  Ok(Nil)
}

fn tokenize_source(source: String) -> Result(Nil, ScanError) {
  case string.length(source) {
    0 -> {
      io.println("EOF  null")
      Ok(Nil)
    }
    _ -> {
      let scan_result = scanner.scan(source)
      scanner.print_tokens(scan_result.tokens)

      case scan_result.had_error {
        True -> Error(scanner.GenericScanError)
        False -> Ok(Nil)
      }
    }
  }
}

fn print_error(error: AppError) -> Nil {
  let message = case error {
    FileError(file_error) -> "Error: " <> simplifile.describe_error(file_error)
    ScanError(scan_error) -> scanner.format_error(scan_error)
    UsageError -> "Usage: ./your_program.sh tokenize <filename>"
  }

  io.println_error(message)
}

fn get_exit_code(error: AppError) -> Int {
  case error {
    FileError(_) -> 1
    ScanError(_) -> 65
    UsageError -> 1
  }
}

@external(erlang, "erlang", "halt")
pub fn exit(code: Int) -> Nil
