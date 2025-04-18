import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import token.{type Token}
import token_type

pub type ScanError {
  UnexpectedCharacter(c: String, line: Int)
}

pub type ScanResult {
  ScanResult(tokens: List(Token), had_error: Bool)
}

pub fn scan(source: String) -> ScanResult {
  string.to_graphemes(source)
  |> InnerScanResult(tokens: [], had_error: False)
  |> inner_scan
  |> fn(res) { ScanResult(tokens: res.tokens, had_error: res.had_error) }
}

type InnerScanResult {
  InnerScanResult(source: List(String), tokens: List(Token), had_error: Bool)
}

fn inner_scan(input: InnerScanResult) -> InnerScanResult {
  case input.source {
    [] ->
      InnerScanResult(
        ..input,
        tokens: list.append(input.tokens, [token.new(token_type.EOF, "", 1)]),
      )
    [c, ..rest] -> {
      case scan_token(c, rest) {
        // If the token could not be scanned, then we have an error.
        Error(msg) -> {
          scanner_error_to_string(msg) |> io.println_error
          InnerScanResult(..input, source: rest, had_error: True)
        }
        Ok(res) -> {
          case res.token {
            None -> InnerScanResult(..input, source: res.new_source)
            Some(token) -> {
              InnerScanResult(
                ..input,
                source: res.new_source,
                tokens: list.append(input.tokens, [token]),
              )
            }
          }
        }
      }
      |> inner_scan
    }
  }
}

type ScanTokenResult {
  ScanTokenResult(token: Option(Token), new_source: List(String))
}

fn scan_token(
  c: String,
  rest: List(String),
) -> Result(ScanTokenResult, ScanError) {
  let line = 1
  case c {
    "(" ->
      token_type.LeftParen
      |> token.new("(", line)
      |> Some
      |> ScanTokenResult(rest)
      |> Ok
    ")" ->
      token_type.RightParen
      |> token.new(")", line)
      |> Some
      |> ScanTokenResult(rest)
      |> Ok
    "{" ->
      token_type.LeftBrace
      |> token.new("{", line)
      |> Some
      |> ScanTokenResult(rest)
      |> Ok
    "}" ->
      token_type.RightBrace
      |> token.new("}", line)
      |> Some
      |> ScanTokenResult(rest)
      |> Ok
    "," ->
      token_type.Comma
      |> token.new(",", line)
      |> Some
      |> ScanTokenResult(rest)
      |> Ok
    "." ->
      token_type.Dot
      |> token.new(".", line)
      |> Some
      |> ScanTokenResult(rest)
      |> Ok
    "-" ->
      token_type.Minus
      |> token.new("-", line)
      |> Some
      |> ScanTokenResult(rest)
      |> Ok
    "+" ->
      token_type.Plus
      |> token.new("+", line)
      |> Some
      |> ScanTokenResult(rest)
      |> Ok
    ";" ->
      token_type.Semicolon
      |> token.new(";", line)
      |> Some
      |> ScanTokenResult(rest)
      |> Ok
    "/" ->
      token_type.Slash
      |> token.new("/", line)
      |> Some
      |> ScanTokenResult(rest)
      |> Ok
    "*" ->
      token_type.Star
      |> token.new("*", line)
      |> Some
      |> ScanTokenResult(rest)
      |> Ok

    "=" -> {
      // if next character is "=" then it is an assignment, otherwise it is an equals
      case rest {
        [next, ..rest2] -> {
          case next {
            "=" -> {
              token_type.EqualEqual
              |> token.new("==", line)
              |> Some
              |> ScanTokenResult(rest2)
              |> Ok
            }
            _ -> {
              token_type.Equal
              |> token.new("=", line)
              |> Some
              |> ScanTokenResult(rest)
              |> Ok
            }
          }
        }
        [] -> {
          token_type.Equal
          |> token.new("=", line)
          |> Some
          |> ScanTokenResult(rest)
          |> Ok
        }
      }
    }

    // Skipt tokens
    " " -> ScanTokenResult(None, rest) |> Ok
    "\n" -> {
      // Should find a way to increment the line number.
      ScanTokenResult(None, rest) |> Ok
    }
    "\t" -> ScanTokenResult(None, rest) |> Ok
    "\r" -> ScanTokenResult(None, rest) |> Ok

    // Anything else is a unexpected character.
    _ -> UnexpectedCharacter(c, line) |> Error
  }
}

pub fn print_tokens(scanner: ScanResult) -> Nil {
  scanner.tokens
  |> list.map(token.to_string)
  |> list.each(io.println)
}

fn scanner_error_to_string(error: ScanError) -> String {
  case error {
    UnexpectedCharacter(c, line) -> {
      "[line " <> int.to_string(line) <> "] Error: Unexpected character: " <> c
    }
  }
}
