# tracing-zig

A minimal tracing library in zig.

## Installation

```bash
zig fetch --save git+https://github.com/mikkurogue/tracing-zig
```

Then add the import in your `build.zig`:

```zig
const tracing = b.dependency("tracing", .{});

const exe = b.addExecutable(.{
    .name = "my-app",
    .root_module = b.createModule(.{
        .root_source_file = b.path("src/main.zig"),
        .imports = &.{
            .{ .name = "tracing", .module = tracing.module("tracing") },
        },
    }),
});
```

## Usage

```zig
const tracing = @import("tracing");

pub fn main() void {
    // Optional: configure timestamp and thread ID
    tracing.init(.{
        .with_timestamp = true,
        .with_thread_id = true,
    });

    // Log events - function name is captured automatically via @src()
    tracing.event(.info, "application started", @src());
    tracing.event(.debug, "some debug info", @src());
    tracing.event(.err, "something went wrong", @src());

    // Or use convenience functions
    tracing.info("hello", @src());
    tracing.debug("debugging", @src());
    tracing.warn("warning", @src());
    tracing.err("error", @src());
}
```

Output:

```
02-03-2026T19:20:52Z [thread:297323] [info] main application started
02-03-2026T19:20:52Z [thread:297323] [debug] main some debug info
02-03-2026T19:20:52Z [thread:297323] [err] main something went wrong
```
