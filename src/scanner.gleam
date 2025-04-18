import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import token.{type Token}
import token_type

pub type Scanner {
  Scanner(source: List(String), tokens: List(Token), line: Int, had_error: Bool)
}

pub fn new(source: String) -> Scanner {
  Scanner(
    source: string.to_graphemes(source),
    tokens: [],
    line: 1,
    had_error: False,
  )
}

pub fn scan_tokens(scanner: Scanner) -> Scanner {
  case scanner.source {
    [] -> {
      let new = token.new(token_type.EOF, "", scanner.line)
      Scanner(..scanner, tokens: list.append(scanner.tokens, [new]))
    }
    [c, ..rest] -> {
      // Scan a new token and continu scanning the rest of the source code.
      case scan_token(c, rest, scanner) {
        // If the token could not be scanned, then we have an error.
        None -> Scanner(..scanner, source: rest, had_error: True)
        Some(new_token) ->
          Scanner(
            ..scanner,
            source: rest,
            tokens: list.append(scanner.tokens, [new_token]),
          )
      }
      |> scan_tokens
    }
  }
}

pub fn print_tokens(scanner: Scanner) -> Nil {
  scanner.tokens
  |> list.map(token.to_string)
  |> list.each(io.println)
}

/// Scans a single token from the source code.
///
/// Returns `None` if the token could not be scanned.
fn scan_token(c: String, _rest: List(String), scanner: Scanner) -> Option(Token) {
  case c {
    "(" -> token_type.LeftParen |> token.new("(", scanner.line) |> Some
    ")" -> token_type.RightParen |> token.new(")", scanner.line) |> Some
    "{" -> token_type.LeftBrace |> token.new("{", scanner.line) |> Some
    "}" -> token_type.RightBrace |> token.new("}", scanner.line) |> Some
    _ -> None
  }
}
