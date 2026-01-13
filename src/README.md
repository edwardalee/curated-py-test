
# HelloWorld.lf

By convention, LF programs are put in a `src` directory. This `src` directory
initially contains one program, `HelloWorld.lf`, which demonstrates:

1. **Reactors** - Modular components that encapsulate behavior
   - `Greeter`: Generates periodic greetings
   - `Counter`: Receives and counts messages
   - `HelloWorld`: Main reactor that composes the system

2. **Timers** - Periodic and one-shot events
   - Startup reaction (executes once at program start)
   - Periodic timer (`500 msec` intervals)
   - Shutdown reaction (executes once at program end)

3. **Ports** - Communication between reactors
   - `output greeting` - Output port in Greeter
   - `input message` - Input port in Counter
   - Connection: `greeter.greeting -> counter.message`

4. **State Variables** - Persistent data across reactions
   - `state count = 0` - Tracks greeting count
   - `state total = 0` - Tracks received messages

5. **Reactions** - Event-driven code blocks
   - Triggered by: `startup`, `timer`, `input`, `shutdown`
   - Python code embedded between `{= =}` delimiters

6. **Timeout** - Program execution duration
   - `timeout: 2 sec` - Program runs for 2 seconds

## How to Compile and Run

You need the Lingua Franca compiler (`lfc`) for command-line compilation
and/or the Visual Studio Code extension for compiling and running within
VSCode or Cursor.
See [https://www.lf-lang.org/](https://www.lf-lang.org/) for installation instructions.

## Compile on the Command Line

```bash
lfc src/HelloWorld.lf
```

This will:
- Generate C code in `src-gen/HelloWorld/`
- Compile the generated code
- Create an executable in `bin/HelloWorld`

## Run on the Command Line

```bash
./bin/HelloWorld
```

## Compile and Run in VSCode or Cursor

In the icon bar, click on the "run" triangle.
Or from the command palette (Command-Shift P), select
"Lingua Franca: Build and Run".

## Expected Output

```
% bin/HelloWorld
---- System clock resolution: 1000 nsec
---- Start execution on Tue Jan 13 10:09:58 2026 ---- plus 977859000 nanoseconds
=== Greeter started ===

╔════════════════════════════════════════════╗
║  Lingua Franca Hello World Demo            ║
║  Demonstrating reactive programming        ║
╚════════════════════════════════════════════╝

[Message #1 at 0 ms] Hello, World! Welcome to Lingua Franca!
[Message #2 at 500 ms] First periodic greeting!
[Message #3 at 1000 ms] Second periodic greeting!
[Message #4 at 1500 ms] Greetings from Lingua Franca!
[Message #5 at 2000 ms] Greetings from Lingua Franca!
=== Greeter shutting down after 4 greetings ===
=== Counter received 5 messages total ===
---- Elapsed logical time (in nsec): 2,000,000,000
---- Elapsed physical time (in nsec): 2,003,074,000
```

# Key Concepts

## Logical Time
Lingua Franca uses **logical time** - a deterministic notion of time that ensures reproducible execution.
Unless the target property `fast` is set to `true`, events are handled only when physical time advances to their logical time, giving real-time behavior.

## Determinism
The output is data deterministic. Running the program multiple times will produce identical results with the same logical timestamps.

## Zero-Delay Communication
Connections between reactors (like `greeter.greeting -> counter.message`) have zero logical delay by default, meaning the downstream reaction executes at the same logical time.

# Next Steps

- Try modifying the timer period
- Add more reactors to the composition
- Experiment with logical actions and delays using `after`
- Explore physical actions for non-deterministic inputs
- Try changing the program to a federated one

For many more examples, see the `src` directories within the `../context` directory.
