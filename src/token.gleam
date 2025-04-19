//// Token module for representing lexical tokens.
//// Defines the structure and operations for tokens in the language.

import gleam/float
import token_type.{type TokenType}

/// Represents literal values in tokens
pub type Literal {
  StringLiteral(String)
  NumberLiteral(Float)
  NilLiteral
}

/// Represents a token in the language
pub type Token {
  Token(
    token_type: TokenType,
    lexeme: String,
    literal: Literal,
    line: Int,
  )
}

/// Create a new token with default literal value
pub fn new(token_type: TokenType, lexeme: String, line: Int) -> Token {
  Token(token_type, lexeme, NilLiteral, line)
}

/// Create a new token with a specific literal value
pub fn with_literal(
  token_type: TokenType,
  lexeme: String,
  literal: Literal,
  line: Int,
) -> Token {
  Token(token_type, lexeme, literal, line)
}

/// Convert a token to a string representation
pub fn to_string(token: Token) -> String {
  token_type.to_string(token.token_type)
  <> " "
  <> token.lexeme
  <> " "
  <> literal_to_string(token.literal)
}

/// Convert a literal value to a string representation
pub fn literal_to_string(literal: Literal) -> String {
  case literal {
    StringLiteral(value) -> value
    NumberLiteral(value) -> float.to_string(value)
    NilLiteral -> "null"
  }
}

