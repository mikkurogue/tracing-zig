const std = @import("std");

pub const Level = enum {
    trace,
    debug,
    info,
    warn,
    err,
    fatal,

    pub fn color(self: Level) []const u8 {
        return switch (self) {
            .trace => "\x1b[36m", // cyan
            .debug => "\x1b[34m", // blue
            .info => "\x1b[32m", // green
            .warn => "\x1b[33m", // yellow
            .err => "\x1b[31m", // red
            .fatal => "\x1b[35m", // magenta
        };
    }
};

const dim = "\x1b[2m";
const reset = "\x1b[0m";

pub const Config = struct {
    with_timestamp: bool = false,
    with_thread_id: bool = false,
};

pub const Subscriber = struct {
    config: Config = .{},

    const Self = @This();

    pub fn writePrefix(self: *Self) void {
        if (self.config.with_timestamp) {
            const ts: u64 = @intCast(std.time.timestamp());
            const epoch_secs = std.time.epoch.EpochSeconds{ .secs = ts };
            const epoch_day = epoch_secs.getEpochDay();
            const year_day = epoch_day.calculateYearDay();
            const month_day = year_day.calculateMonthDay();
            const day_secs = epoch_secs.getDaySeconds();

            std.debug.print("{s}{d:0>2}-{d:0>2}-{d}T{d:0>2}:{d:0>2}:{d:0>2}Z{s} ", .{
                dim,
                @as(u32, month_day.day_index) + 1,
                month_day.month.numeric(),
                year_day.year,
                day_secs.getHoursIntoDay(),
                day_secs.getMinutesIntoHour(),
                day_secs.getSecondsIntoMinute(),
                reset,
            });
        }

        if (self.config.with_thread_id) {
            const tid = std.Thread.getCurrentId();
            std.debug.print("{s}[thread:{d}]{s} ", .{ dim, tid, reset });
        }
    }

    pub fn log(self: *Self, level: Level, msg: []const u8, src: std.builtin.SourceLocation) void {
        self.writePrefix();
        std.debug.print("{s}[{s}]{s} ", .{ level.color(), @tagName(level), reset });
        std.debug.print("{s}{s}{s} ", .{ dim, src.fn_name, reset });
        std.debug.print("{s}\n", .{msg});
    }
};

// Global subscriber instance
var global_subscriber: Subscriber = .{};

/// Initialize the global subscriber with configuration.
pub fn init(config: Config) void {
    global_subscriber = .{ .config = config };
}

/// Log an event at the specified level.
/// Use @src() to capture the calling function name automatically.
///
/// Example:
/// ```zig
/// const tracing = @import("tracing");
/// tracing.event(.info, "hello world", @src());
/// ```
pub fn event(level: Level, msg: []const u8, src: std.builtin.SourceLocation) void {
    global_subscriber.log(level, msg, src);
}

// Convenience functions for each log level

pub inline fn trace(msg: []const u8, src: std.builtin.SourceLocation) void {
    event(.trace, msg, src);
}

pub inline fn debug(msg: []const u8, src: std.builtin.SourceLocation) void {
    event(.debug, msg, src);
}

pub inline fn info(msg: []const u8, src: std.builtin.SourceLocation) void {
    event(.info, msg, src);
}

pub inline fn warn(msg: []const u8, src: std.builtin.SourceLocation) void {
    event(.warn, msg, src);
}

pub inline fn err(msg: []const u8, src: std.builtin.SourceLocation) void {
    event(.err, msg, src);
}

pub inline fn fatal(msg: []const u8, src: std.builtin.SourceLocation) void {
    event(.fatal, msg, src);
}

test "Level.color returns correct ANSI codes" {
    try std.testing.expectEqualStrings("\x1b[36m", Level.trace.color());
    try std.testing.expectEqualStrings("\x1b[34m", Level.debug.color());
    try std.testing.expectEqualStrings("\x1b[32m", Level.info.color());
    try std.testing.expectEqualStrings("\x1b[33m", Level.warn.color());
    try std.testing.expectEqualStrings("\x1b[31m", Level.err.color());
    try std.testing.expectEqualStrings("\x1b[35m", Level.fatal.color());
}

test "Config defaults to false" {
    const config = Config{};
    try std.testing.expect(!config.with_timestamp);
    try std.testing.expect(!config.with_thread_id);
}

test "Subscriber initializes with config" {
    const sub = Subscriber{ .config = .{ .with_timestamp = true, .with_thread_id = true } };
    try std.testing.expect(sub.config.with_timestamp);
    try std.testing.expect(sub.config.with_thread_id);
}

test "init sets global subscriber config" {
    init(.{ .with_timestamp = true });
    try std.testing.expect(global_subscriber.config.with_timestamp);
    try std.testing.expect(!global_subscriber.config.with_thread_id);

    // Reset for other tests
    init(.{});
}

test "event does not crash" {
    // Just ensure it doesn't panic - output goes to stderr
    init(.{});
    event(.info, "test message", @src());
}

test "convenience functions do not crash" {
    init(.{});
    trace("trace msg", @src());
    debug("debug msg", @src());
    info("info msg", @src());
    warn("warn msg", @src());
    err("err msg", @src());
    fatal("fatal msg", @src());
}
