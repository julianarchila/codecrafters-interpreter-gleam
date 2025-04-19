## Instructions for Writing Gleam Code

This document provides instructions and examples for generating Gleam code. Gleam is a statically-typed functional language that compiles to Erlang and JavaScript.

**General Principles:**

*   **Static Typing:** Gleam has a robust static type system. Ensure that types are consistent throughout the code. The compiler will catch type errors.
*   **Immutability:** Values in Gleam are immutable. When you "modify" a value, you are actually creating a new value.
*   **No Null, No Implicit Conversions, No Exceptions:** Gleam promotes predictable code by avoiding common sources of runtime errors.
*   **Pattern Matching:** Case expressions and pattern matching are central to Gleam's flow control and data manipulation.
*   **Recursion:** Gleam uses recursion instead of traditional loops for iteration. Tail call optimization is supported.
*   **Pipelines:** The `|>` operator is commonly used for chaining function calls, improving readability for sequential operations.
*   **Standard Library:** Familiarize yourself with the `gleam` standard library, especially modules like `gleam/list`, `gleam/result`, and `gleam/dict`.

**File Structure and Organization:**

*   Gleam code is organized into **modules**.
*   Module names correspond to their file paths (e.g., `gleam/io` is in `gleam/io.gleam`).
*   Use the `import` keyword to bring in definitions from other modules.
*   Qualify imported functions and types with the module name (`module.function`) or use unqualified imports for specific items (generally less recommended for functions, more common for types).
*   Use `pub` to make modules, types, type aliases, and functions visible to other modules.

**Basic Syntax:**

*   **Hello World:**
    ```gleam
    import gleam/io

    pub fn main() {
      io.println("Hello, Joe!")
    }
    ```
*   **Comments:**
    *   Single-line comments: `// This is a comment`
    *   Documentation comments for types and functions: `/// Documentation for a function`
    *   Documentation comments for modules: `//// Documentation for a module`
*   **Assignments:** Use `let` to assign values to immutable variables.
    ```gleam
    let x = 10
    let name = "Alice"
    ```
*   **Discard Patterns:** Prefix a variable name with `_` if it is assigned but not used, to silence warnings.
    ```gleam
    let _unused_variable = 123
    ```
*   **Type Annotations:** Optional, but recommended for function arguments and return values, and can be used on `let` bindings for clarity.
    ```gleam
    fn add(a: Int, b: Int) -> Int {
      a + b
    }

    let greeting: String = "Hello"
    ```
*   **Blocks:** Group expressions with curly braces `{}`. The value of the last expression is returned. Variables defined inside a block are only accessible within that block.
    ```gleam
    let result = {
      let x = 5
      x * 2
    }
    ```
    Blocks can also be used to control the order of evaluation for binary operators.
    ```gleam
    let y = { 1 + 2 } * 3 // Evaluates to 9
    ```

**Data Types:**

*   **Ints:** Whole numbers. Arithmetic operators: `+`, `-`, `/`, `*`, `%`. Comparisons: `>`, `<`, `>=`, `<=`.
    ```gleam
    let age = 30
    let sum = 1 + 1
    ```
*   **Floats:** Numbers with decimal points. Float arithmetic operators: `+.`, `-.`, `/.`, `*.`. Float comparisons: `>.`, `<.`, `>=.`, `<=.`. Division by zero results in `0.0` on the BEAM and potentially `Infinity` or `NaN` on JavaScript.
    ```gleam
    let price = 9.99
    let average = 5.0 /. 2.0
    ```
*   **Number Formats:** Underscores for clarity (`1_000_000`), binary (`0b...`), octal (`0o...`), hexadecimal (`0x...`), scientific notation (`7.0e7`).
    ```gleam
    let big_number = 1_000_000
    let byte_value = 0xFF
    let scientific = 1.23e-5
    ```
*   **Equality:** Use `==` and `!=`. Works for any type, but both sides must be of the same type. Structural equality check.
    ```gleam
    echo 1 == 1 // True
    echo "hello" != "world" // True
    ```
*   **Strings:** Text surrounded by double quotes. Can span multiple lines and contain Unicode. Concatenation with `<>`. Supports escape sequences (`\"`, `\\`, `\f`, `\n`, `\r`, `\t`, `\u{xxxxxx}`).
    ```gleam
    let greeting = "Hello, " <> "Gleam!"
    let multiline = "First line\nSecond line"
    let unicode_char = "\u{1F600}"
    ```
*   **Bools:** `True` or `False`. Operators: `||` (short-circuiting OR), `&&` (short-circuiting AND), `!` (NOT).
    ```gleam
    let is_active = True
    let can_proceed = is_active && (count > 0)
    ```
*   **Lists:** Ordered collections of values of the same type (`List(Int)`, `List(String)`). Immutable. Efficient to add/remove from the front. Prepend with `[element, ..list]`.
    ```gleem
    let numbers = [1, 2, 3]
    let new_numbers = [0, ..numbers]
    ```
*   **Constants:** Defined at the top level of a module using `const`. Must be literal values.
    ```gleam
    const MAX_RETRIES: Int = 3
    ```
*   **Tuples:** Combine multiple values of different types (`#(Int, String)`). Access elements with `.0`, `.1`, etc.
    ```gleam
    let person_data = #("Alice", 30, True)
    echo person_data.0 // "Alice"
    ```
*   **Custom Types:** Define new types with `type`. Can have variants. Variant and type names start with uppercase letters.
    ```gleam
    pub type Status {
      Active
      Inactive
    }
    ```
*   **Records:** Custom type variants that hold data with labeled fields.
    ```gleam
    pub type Point {
      Point(x: Int, y: Int)
    }

    let origin = Point(x: 0, y: 0)
    ```
    Use shorthand syntax for labels when the variable name matches the label: `Point(x:, y:)`
*   **Record Accessors:** Access record fields using `record.field_label`. Can always be used for fields with the same name, position, and type across all variants.
    ```gleam
    pub type Shape {
      Circle(radius: Float)
      Square(side: Float)
    }

    pub fn area(shape: Shape) -> Float {
      case shape {
        Circle(radius) -> 3.14 *. radius *. radius
        Square(side) -> side *. side
      }
    }

    echo area(Circle(radius: 10.0))
    echo area(Square(side: 5.0))
    ```
*   **Record Updates:** Create a new record from an existing one with modified fields using `..record`.
    ```gleam
    let person = Person(name: "Bob", age: 25)
    let older_person = Person(..person, age: 26)
    ```
*   **Generic Custom Types:** Custom types can have type parameters.
    ```gleam
    pub type Option(inner) {
      Some(inner)
      None
    }
    ```
*   **Nil:** Gleam's unit type. Returned by functions with nothing else to return. Not nullable.
    ```gleam
    let result = io.println("Done!") // result is Nil
    ```
*   **Results:** The built-in `Result(value, error)` type for fallible computations. Variants: `Ok(value)` or `Error(error)`. Generic over success and error types.
    ```gleam
    pub type ParseError { InvalidFormat }

    pub fn parse_int(s: String) -> Result(Int, ParseError) {
      case s {
        "123" -> Ok(123)
        _ -> Error(InvalidFormat)
      }
    }
    ```
    Use the `gleam/result` module for working with results. Key functions include `map`, `try`, and `unwrap`.
*   **Bit Arrays:** Represent sequences of bits using `<<>>`. Segments can have options like `size`, `unit`, `int`, `float`, `utf8`, `little`, `big`, `signed`, `unsigned`, etc.
    ```gleam
    echo <<3>> // 8 bit int
    echo <<"Hello":utf8>> // UTF8 encoded string
    echo <<1:size(4), 2:size(4)>> // Two 4-bit integers
    ```

**Functions:**

*   Define functions with `fn`. Use `pub fn` for public functions.
    ```gleam
    fn add(a: Int, b: Int) -> Int {
      a + b
    }
    ```
*   **Higher Order Functions:** Functions are values and can be passed as arguments or returned from other functions. Function types are written as `fn(ArgType) -> ReturnType`.
    ```gleam
    fn apply_twice(x: a, f: fn(a) -> a) -> a {
      f(f(x))
    }
    ```
*   **Anonymous Functions:** Define functions inline using `fn() { ... }`. Can close over variables in their scope.
    ```gleam
    let multiply_by_two = fn(x) { x * 2 }
    ```
*   **Function Captures:** Shorthand for creating anonymous functions that pass an argument to another function, using `_` as a placeholder.
    ```gleam
    let add_five = add(5, _) // equivalent to fn(x) { add(5, x) }
    ```
*   **Generic Functions:** Use type variables (lowercase names) to define functions that work with any type, as long as the types are consistent within the function.
    ```gleam
    fn identity(x: a) -> a {
      x
    }
    ```
*   **Pipelines:** Use the `|>` operator to chain function calls, passing the result of the left as the first argument to the function on the right.
    ```gleam
    let result =
      "  Hello!  "
      |> string.trim
      |> string.to_uppercase
    ```
    Can pipe to a different argument using function capture: `value |> function(arg1, _, arg3)`.
    Use `|> echo` for debugging in pipelines.
*   **Labelled Arguments:** Give arguments external labels in the function definition. Calling order doesn't matter for labelled arguments, and labels are optional when calling. Unlabelled arguments must come first.
    ```gleam
    fn greet(name: String, loud should_be_loud: Bool) -> String {
      case should_be_loud {
        True -> string.to_uppercase("HELLO, " <> name)
        False -> "Hello, " <> name
      }
    }

    greet("Alice", loud: True)
    greet("Bob", loud: False)
    greet("Charlie", False) // Labels are optional
    ```
*   **Label Shorthand Syntax:** When a local variable has the same name as a labelled argument, the variable name can be omitted during the function call (`quantity:` instead of `quantity: quantity`).
    ```gleam
    let count = 10
    let message = "items"
    io.println(count:, message:) // Assuming a function println(count count: Int, message message: String)
    ```
*   **Deprecations:** Use the `@deprecated` attribute to mark functions or types as deprecated. Provide a message explaining the replacement.
    ```glealeam
    @deprecated("Use new_function instead")
    pub fn old_function() { Nil }
    ```

**Flow Control:**

*   **Case Expressions:** Powerful pattern matching. Checks all possible patterns for exhaustiveness.
    ```gleam
    case value {
      Pattern1 -> // code
      Pattern2 -> // code
      _ -> // fallback
    }
    ```
*   **Newtypes and Destructuring:**
    * You can create simplified types with one variant via `pub type` with a single variant:
        ```gleam
        pub type UserName {
            UserName(String)
        }
        ```
    * You can make a newtype for better control over how a type is created and accessed using `pub opaque type`:
        ```gleam
        pub opaque type ValidUserName {
            ValidUserName(String)
        }
        // The `ValidUserName` constructor is not public, ensuring that users must use the `new`
        // function to create one. This ensures that only valid user names are created.
        pub fn new(s: String) -> UserName {
            // validation logic here
            ValidUserName(s)
        }
        ```
    * To extract values from a single variant type, you can use `let` destructuring:
      ```gleam
      pub type Wrapper<a> { Wrapper(a) }

      pub fn get_value(wrapper: Wrapper(Int)) -> Int {
        let Wrapper(value) = wrapper
        value
      }
      ```
*   **Variable Patterns:** Assign matched values to variables within a `case` clause.
    ```glelem
    case number {
      0 -> "Zero"
      other -> "It's " <> int.to_string(other)
    }
    ```
*   **String Patterns:** Use `<>` to match on string prefixes.
    ```gleam
    case message {
      "Error: " <> error_message -> io.println("An error occurred: " <> error_message)
      _ -> io.println("No error reported.")
    }
    ```
*   **List Patterns:** Match on list structure using `[]` (empty), `[element, ..]` (starts with), `[element]` (single element), `[first, ..rest]` (first element and rest of list).
    ```gleam
    case my_list {
      [] -> "Empty"
      [x] -> "Single element: " <> int.to_string(x)
      [first, second, ..] -> "Starts with " <> int.to_string(first) <> " and " <> int.to_string(second)
      _ -> "Something else"
    }
    ```
*   **Recursion:** Functions calling themselves. Requires base case(s) and recursive case(s).
    ```gleam
    pub fn factorial(n: Int) -> Int {
      case n {
        0 -> 1
        _ -> n * factorial(n - 1)
      }
    }
    ```
*   **Tail Calls:** The compiler optimizes recursive calls that are the last operation in a function to prevent stack overflow. Often involves using an accumulator.
    ```gleam
    pub fn factorial_tail_recursive(n: Int) -> Int {
      factorial_loop(n, 1)
    }

    fn factorial_loop(n: Int, accumulator: Int) -> Int {
      case n {
        0 -> accumulator
        _ -> factorial_loop(n - 1, accumulator * n)
      }
    }
    ```
*   **List Recursion:** Common recursive pattern using `[first, ..rest]` and `[]`.
    ```gleam
    fn sum_list(list: List(Int), total: Int) -> Int {
      case list {
        [first, ..rest] -> sum_list(rest, total + first)
        [] -> total
      }
    }
    ```
*   **Multiple Subjects:** Pattern match on multiple values in one `case` expression using commas.
    ```gleam
    case x, y {
      0, 0 -> "Both zero"
      1, _ -> "x is one"
      _, 1 -> "y is one"
      _, _ -> "Neither are one"
    }
    ```
*   **Alternative Patterns:** Use `|` to provide multiple patterns for a single `case` clause. Variables bound must be consistent across alternatives.
    ```gleam
    case number {
      2 | 4 | 6 -> "Even"
      1 | 3 | 5 -> "Odd"
      _ -> "Too large"
    }
    ```
*   **Pattern Aliases:** Use `as` to assign a sub-pattern to a variable name.
    ```gleam
    case my_list {
      [_, ..] as non_empty_list -> non_empty_list.0
      [] -> 0
    }
    ```
*   **Guards:** Use `if` with a `case` pattern to add an extra condition that must be true for the pattern to match. Guard expressions cannot contain function calls, case expressions, or blocks.
    ```gleam
    case count {
      c if c > 100 -> "Large count"
      c if c > 0 -> "Positive count"
      _ -> "Zero or negative"
    }
    ```

**Advanced Features:**

*   **Opaque Types:** Define a public type but keep its constructors private using `pub opaque type`. Requires smart constructors (public functions that create instances of the type).
    ```gleam
    pub opaque type PositiveInt {
      PositiveInt(inner: Int)
    }

    pub fn new(i: Int) -> PositiveInt {
      case i >= 0 {
        True -> PositiveInt(i)
        False -> PositiveInt(0) // Ensure it's always positive
      }
    }
    ```
*   **Use Expression:** A feature to reduce indentation when working with callback-based functions (common with Result and Option).
    ```gleam
    pub fn process_user() -> Result(String, Nil) {
      use username <- get_username()
      use password <- get_password()
      log_in(username, password)
    }
    ```
*   **Todo:** The `todo` keyword marks unimplemented code. Generates a warning and crashes at runtime. Can include a message.
    ```gleam
    pub fn implement_later() {
      todo as "Need to finish this function"
    }
    ```
*   **Panic:** The `panic` keyword crashes the program immediately. Used for invalid states that should never be reached (use sparingly). Can include a message.
    ```gleam
    pub fn handle_invalid_state(value: Int) {
      case value {
        1 -> io.println("Valid")
        _ -> panic as "Unexpected value!"
      }
    }
    ```
*   **Let Assert:** Like `let`, but allows partial patterns. Panics if the pattern does not match. Use sparingly, especially in libraries.
    ```gleam
    pub fn unsafe_head(list: List(a)) -> a {
      let assert [first, ..] = list
      first
    }
    ```
*   **Externals:** Use `@external` attribute to call functions written in other languages (Erlang or JavaScript). Requires type annotations. Be cautious with types!
    ```gleam
    @external(javascript, "./my_js_file.mjs", "fetchData")
    pub fn fetch_data(url: String) -> Result(String, Nil)
    ```
*   **Multi Target Externals:** Specify different external implementations for different compilation targets.
    ```gleam
    @external(erlang, "lists", "reverse")
    @external(javascript, "./my_js_list_utils.mjs", "reverse")
    pub fn reverse_list(items: List(a)) -> List(a)
    ```
*   **External Gleam Fallbacks:** Provide both Gleam and external implementations. The external one is preferred if available for the target, otherwise the Gleam one is used.
    ```gleam
    @external(erlang, "erl_nif", "atom_to_string")
    pub fn atom_to_string(atom: Atom) -> String {
      // Gleam fallback implementation
      case atom {
        atom -> panic // Simplified for example
      }
    }
    ```

**Standard Library Modules (Key Examples):**

*   **`gleam/list`:** Functions for manipulating lists (`map`, `filter`, `fold`, `find`, etc.). Prefer these over manual list recursion for common tasks.
*   **`gleam/result`:** Functions for working with the `Result` type (`map`, `try`, `unwrap`, etc.).
*   **`gleam/dict`:** Functions for working with key-value maps (`new`, `from_list`, `insert`, `delete`). Dictionaries are unordered.
*   **`gleam/option`:** Defines the `Option` type (`Some`, `None`) and functions for working with it. Used to represent the presence or absence of a value.

By following these instructions and referring to the examples, you should be able to generate correct and idiomatic Gleam code. Remember to prioritize clarity, type safety, and leveraging Gleam's built-in features like pattern matching and the standard library.
