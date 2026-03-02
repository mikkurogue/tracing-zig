const std = @import("std");
const tracing = @import("tracing");

pub fn main() !void {
    // Test 1: Default config - no timestamp, no thread ID
    tracing.event(.info, "Without any config", @src());

    // Test 2: Enable just timestamp
    tracing.init(.{ .with_timestamp = true });
    tracing.event(.info, "With timestamp only", @src());

    // Test 3: Enable just thread ID
    tracing.init(.{ .with_thread_id = true });
    tracing.event(.info, "With thread ID only", @src());

    // Test 4: Enable both
    tracing.init(.{ .with_timestamp = true, .with_thread_id = true });
    tracing.event(.info, "With both enabled", @src());

    doWork();
}

fn doWork() void {
    tracing.event(.debug, "Doing some work...", @src());
}
