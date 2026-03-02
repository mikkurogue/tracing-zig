const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Main library module - this is what users import via zig fetch
    const tracing_mod = b.addModule("tracing", .{
        .root_source_file = b.path("src/tracing.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Example executable
    const example = b.addExecutable(.{
        .name = "example-basic",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/basic.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "tracing", .module = tracing_mod },
            },
        }),
    });

    b.installArtifact(example);

    // Run example
    const run_cmd = b.addRunArtifact(example);
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the example");
    run_step.dependOn(&run_cmd.step);

    // Library tests
    const lib_tests = b.addTest(.{
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/tracing.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const run_lib_tests = b.addRunArtifact(lib_tests);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&run_lib_tests.step);

    // Check step for CI
    const check = b.step("check", "Check if the code compiles");
    check.dependOn(&lib_tests.step);
}
