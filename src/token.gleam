import token_type.{type TokenType}

pub type Token {
  Token(token_type: TokenType, lexeme: String, literal: Nil, line: Int)
}

pub fn new(token_type: TokenType, lexeme: String, line: Int) -> Token {
  Token(token_type, lexeme, Nil, line)
}

pub fn to_string(token: Token) -> String {
  let Token(token_type, lexeme, _literal, _line) = token

  token_type.to_string(token_type)
  <> " "
  <> lexeme
  <> " "
  <> literal_to_string(token)
}

pub fn literal_to_string(_token: Token) -> String {
  "null"
}
