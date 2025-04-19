//// Tests for the Scanner module
//// Uses gleeunit for unit testing

import gleeunit/should
import scanner

// Removed import of ScanResult; use fully-qualified constructor instead
import gleam/list
import token

pub fn empty_file_test() {
  let scanner.ScanResult(tokens, had_error) = scanner.scan("")
  should.equal(had_error, False)
  let token_strs = list.map(tokens, token.to_string)
  should.equal(token_strs, ["EOF  null"])
}

pub fn parentheses_test() {
  // Simple parentheses
  let scanner.ScanResult(tokens1, err1) = scanner.scan("()")
  should.equal(err1, False)
  let strs1 = list.map(tokens1, token.to_string)
  should.equal(strs1, ["LEFT_PAREN ( null", "RIGHT_PAREN ) null", "EOF  null"])
}

pub fn braces_test() {
  // Simple braces
  let scanner.ScanResult(tokens2, err2) = scanner.scan("{}")
  should.equal(err2, False)
  let strs2 = list.map(tokens2, token.to_string)
  should.equal(strs2, ["LEFT_BRACE { null", "RIGHT_BRACE } null", "EOF  null"])
}

pub fn simple_tokens_test() {
  // Other single-character tokens
  let source = "+-*/.,;"
  let scanner.ScanResult(tokens3, err3) = scanner.scan(source)
  should.equal(err3, False)
  let strs3 = list.map(tokens3, token.to_string)
  should.equal(strs3, [
    "PLUS + null", "MINUS - null", "STAR * null", "SLASH / null", "DOT . null",
    "COMMA , null", "SEMICOLON ; null", "EOF  null",
  ])
}

pub fn comparison_operators_test() {
  // Assignment and equality operators
  let scanner.ScanResult(tokens4, err4) = scanner.scan("= == != < <= > >=")
  should.equal(err4, False)
  let strs4 = list.map(tokens4, token.to_string)
  should.equal(strs4, [
    "EQUAL = null", "EQUAL_EQUAL == null", "BANG_EQUAL != null", "LESS < null",
    "LESS_EQUAL <= null", "GREATER > null", "GREATER_EQUAL >= null", "EOF  null",
  ])
}
