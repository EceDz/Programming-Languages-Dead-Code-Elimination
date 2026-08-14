# Dead Code Elimination

A small compiler-construction project (Flex + Bison, C) that performs **dead code elimination** on a simple three-address-code-style language. Given a list of assignment statements and a set of "live" (needed) output variables, the tool works backward through the code and prints only the statements that actually contribute to those outputs.

A full write-up of the approach is included in [`Report.pdf`](Report.pdf).

## How It Works

1. **`termproject.l`** (Flex) — tokenizes the input: identifiers, numbers, the operators `= + - * / ^`, braces, and separators.
2. **`termproject.y`** (Bison) — parses a sequence of assignment statements followed by a live-variable list in braces, e.g. `{ x, y }`, and builds an internal list of statements.
3. **Dead code elimination pass** — starting from the declared live variables, the program scans statements in reverse:
   - If a statement's destination variable is currently live, the statement is kept, and its operands are marked live (unless they're constants).
   - The destination itself is then removed from the live set (since it's been "defined").
   - Statements whose destination is never live are dropped as dead code.
4. The surviving statements are printed back out, in their original order.

## Input Format

Each statement is one of:

```
dest = value;
dest = op1 + op2;
dest = op1 - op2;
dest = op1 * op2;
dest = op1 / op2;
dest = op1 ^ op2;
```

where `op1`/`op2` can be identifiers or numeric constants. The file ends with a brace-enclosed list of the variables considered "live" (i.e. the outputs you actually care about):

```
{ var1, var2, ... }
```

### Example

`input1.txt`:
```
a=2+2;
b=2^9;
c=d^3;
e=5;
f=3*4;
g=6/2;
h=m;
p=0;
j=j+p;
r=e*p;
s=a;
{ r, s }
```

Running the tool keeps only the statements needed to compute `r` and `s`, dropping everything else (`b`, `c`, `f`, `g`, `h`, `j` never feed into `r` or `s`):

```
$ ./termproject input1.txt
a=2+2;
e=5;
p=0;
r=e*p;
s=a;
```

## Requirements

- GCC
- Flex
- Bison

On Debian/Ubuntu:
```bash
sudo apt-get install gcc flex bison
```

## Building

```bash
cd Codes
make
```

This generates the lexer/parser (`lex.yy.c`, `termproject.tab.c/h`) and compiles them into the `termproject` executable.

## Usage

```bash
./termproject <input_file>
```

Run the provided test inputs:

```bash
make test
```

Clean generated files:

```bash
make clean
```

## Project Structure

```
Codes/
├── termproject.l       # Flex lexer
├── termproject.y        # Bison grammar + dead code elimination logic
├── Makefile
├── input1.txt ... input5.txt   # Sample test inputs
Report.pdf               # Written report describing the approach
LICENSE
```

## License

This project is licensed under the MIT License. See [LICENSE](LICENSE) for details.
