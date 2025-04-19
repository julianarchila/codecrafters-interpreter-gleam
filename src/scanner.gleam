//// Scanner module for tokenizing source code.
//// Converts a string of source code into a list of tokens.

import gleam/int
import gleam/io
import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import token.{type Token}
import token_type.{type TokenType}

/// Represents errors that can occur during scanning
pub type ScanError {
  UnexpectedCharacter(character: String, line: Int)
  GenericScanError
}

/// Result of scanning source code
pub type ScanResult {
  ScanResult(tokens: List(Token), had_error: Bool)
}

/// Format a scan error as a human-readable string
pub fn format_error(error: ScanError) -> String {
  case error {
    UnexpectedCharacter(c, line) -> {
      "[line " <> int.to_string(line) <> "] Error: Unexpected character: " <> c
    }
    GenericScanError -> "Error during scanning"
  }
}

/// Scan source code and produce a list of tokens
pub fn scan(source: String) -> ScanResult {
  let initial_state =
    ScannerState(
      source: string.to_graphemes(source),
      tokens: [],
      had_error: False,
      line: 1,
    )

  let final_state = scan_tokens(initial_state)

  ScanResult(tokens: final_state.tokens, had_error: final_state.had_error)
}

/// Print all tokens to standard output
pub fn print_tokens(tokens: List(Token)) -> Nil {
  tokens
  |> list.map(token.to_string)
  |> list.each(io.println)
}

/// Internal state of the scanner during processing
type ScannerState {
  ScannerState(
    source: List(String),
    tokens: List(Token),
    had_error: Bool,
    line: Int,
  )
}

/// Process all tokens in the source
fn scan_tokens(state: ScannerState) -> ScannerState {
  case state.source {
    [] -> {
      // Add EOF token at the end
      let eof_token = token.new(token_type.EOF, "", state.line)
      ScannerState(..state, tokens: list.append(state.tokens, [eof_token]))
    }

    [current, ..rest] -> {
      let new_state = process_character(current, rest, state)
      scan_tokens(new_state)
    }
  }
}

/// Process a single character and update the scanner state
fn process_character(
  current: String,
  rest: List(String),
  state: ScannerState,
) -> ScannerState {
  case scan_token(current, rest, state.line) {
    Ok(result) -> {
      // Update state with new source and line number
      let base_state =
        ScannerState(
          ..state,
          source: result.remaining_source,
          line: result.new_line,
        )

      // Add token if one was produced
      case result.token {
        Some(token) ->
          ScannerState(
            ..base_state,
            tokens: list.append(base_state.tokens, [token]),
          )
        None -> base_state
      }
    }

    Error(error) -> {
      // Report error and continue with error flag set
      io.println_error(format_error(error))
      ScannerState(..state, source: rest, had_error: True)
    }
  }
}

/// Result of scanning a single token
type TokenResult {
  TokenResult(
    token: Option(Token),
    remaining_source: List(String),
    new_line: Int,
  )
}

/// Scan a single token from the source
fn scan_token(
  current: String,
  rest: List(String),
  line: Int,
) -> Result(TokenResult, ScanError) {
  // Match on the current character
  case current {
    // Single-character tokens
    "(" -> create_token(token_type.LeftParen, "(", rest, line)
    ")" -> create_token(token_type.RightParen, ")", rest, line)
    "{" -> create_token(token_type.LeftBrace, "{", rest, line)
    "}" -> create_token(token_type.RightBrace, "}", rest, line)
    "," -> create_token(token_type.Comma, ",", rest, line)
    "." -> create_token(token_type.Dot, ".", rest, line)
    "-" -> create_token(token_type.Minus, "-", rest, line)
    "+" -> create_token(token_type.Plus, "+", rest, line)
    ";" -> create_token(token_type.Semicolon, ";", rest, line)
    "*" -> create_token(token_type.Star, "*", rest, line)

    // One or two character tokens
    "!" ->
      match_second_char(
        rest,
        "=",
        token_type.BangEqual,
        token_type.Bang,
        "!",
        line,
      )
    "=" ->
      match_second_char(
        rest,
        "=",
        token_type.EqualEqual,
        token_type.Equal,
        "=",
        line,
      )
    "<" ->
      match_second_char(
        rest,
        "=",
        token_type.LessEqual,
        token_type.Less,
        "<",
        line,
      )
    ">" ->
      match_second_char(
        rest,
        "=",
        token_type.GreaterEqual,
        token_type.Greater,
        ">",
        line,
      )
    "/" -> create_token(token_type.Slash, "/", rest, line)

    // Whitespace (skip)
    " " -> skip(rest, line)
    "\r" -> skip(rest, line)
    "\t" -> skip(rest, line)
    "\n" -> skip(rest, line + 1)

    // Increment line counter
    // Unexpected character
    _ -> Error(UnexpectedCharacter(current, line))
  }
}

/// Create a token and return it with the updated source
fn create_token(
  type_: TokenType,
  lexeme: String,
  rest: List(String),
  line: Int,
) -> Result(TokenResult, ScanError) {
  let token = token.new(type_, lexeme, line)
  Ok(TokenResult(Some(token), rest, line))
}

/// Skip the current character without creating a token
fn skip(rest: List(String), new_line: Int) -> Result(TokenResult, ScanError) {
  Ok(TokenResult(None, rest, new_line))
}

/// Match a potential second character for two-character tokens
fn match_second_char(
  rest: List(String),
  expected: String,
  match_type: TokenType,
  default_type: TokenType,
  lexeme: String,
  line: Int,
) -> Result(TokenResult, ScanError) {
  case rest {
    [next, ..remaining] if next == expected -> {
      let combined_lexeme = lexeme <> next
      create_token(match_type, combined_lexeme, remaining, line)
    }
    _ -> create_token(default_type, lexeme, rest, line)
  }
}
