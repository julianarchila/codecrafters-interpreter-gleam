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
  |> InnerScanResult(tokens: [], had_error: False, line: 1)
  |> inner_scan
  |> fn(res) { ScanResult(tokens: res.tokens, had_error: res.had_error) }
}

type InnerScanResult {
  InnerScanResult(
    source: List(String),
    tokens: List(Token),
    had_error: Bool,
    line: Int,
  )
}

fn inner_scan(input: InnerScanResult) -> InnerScanResult {
  case input.source {
    [] ->
      InnerScanResult(
        ..input,
        tokens: list.append(input.tokens, [
          token.new(token_type.EOF, "", input.line),
        ]),
      )
    [c, ..rest] -> {
      case scan_token(c, rest, input.line) {
        // If the token could not be scanned, then we have an error.
        Error(msg) -> {
          scanner_error_to_string(msg) |> io.println_error
          InnerScanResult(..input, source: rest, had_error: True)
        }
        Ok(res) -> {
          case res.token {
            None ->
              InnerScanResult(
                ..input,
                source: res.new_source,
                line: res.new_line,
              )
            Some(token) -> {
              InnerScanResult(
                ..input,
                source: res.new_source,
                tokens: list.append(input.tokens, [token]),
                line: res.new_line,
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
  ScanTokenResult(token: Option(Token), new_source: List(String), new_line: Int)
}

// Helper to create a token result
fn ok_token(
  kind: token_type.TokenType,
  lexeme: String,
  rest: List(String),
  line: Int,
) -> Result(ScanTokenResult, ScanError) {
  let tok = token.new(kind, lexeme, line)
  Ok(ScanTokenResult(Some(tok), rest, line))
}

// Helper to skip a character without emitting a token
fn skip(rest: List(String), new_line: Int) -> Result(ScanTokenResult, ScanError) {
  Ok(ScanTokenResult(None, rest, new_line))
}

fn scan_token(
  c: String,
  rest: List(String),
  line: Int,
) -> Result(ScanTokenResult, ScanError) {
  case c {
    "(" -> ok_token(token_type.LeftParen, "(", rest, line)
    ")" -> ok_token(token_type.RightParen, ")", rest, line)
    "{" -> ok_token(token_type.LeftBrace, "{", rest, line)
    "}" -> ok_token(token_type.RightBrace, "}", rest, line)
    "," -> ok_token(token_type.Comma, ",", rest, line)
    "." -> ok_token(token_type.Dot, ".", rest, line)
    "-" -> ok_token(token_type.Minus, "-", rest, line)
    "+" -> ok_token(token_type.Plus, "+", rest, line)
    ";" -> ok_token(token_type.Semicolon, ";", rest, line)
    "/" -> ok_token(token_type.Slash, "/", rest, line)
    "*" -> ok_token(token_type.Star, "*", rest, line)

    "!" ->
      case rest {
        ["=", ..rest2] -> ok_token(token_type.BangEqual, "!=", rest2, line)
        _ -> ok_token(token_type.Bang, "!", rest, line)
      }
    "=" ->
      case rest {
        ["=", ..rest2] -> ok_token(token_type.EqualEqual, "==", rest2, line)
        _ -> ok_token(token_type.Equal, "=", rest, line)
      }

    // Skip whitespace
    " " -> skip(rest, line)
    "\n" -> skip(rest, line + 1)
    "\t" -> skip(rest, line)
    "\r" -> skip(rest, line)

    // Unexpected character
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
