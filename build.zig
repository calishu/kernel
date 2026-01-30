const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{});

    const target = b.resolveTargetQuery(.{
        .cpu_arch = .x86_64,
        .os_tag = .freestanding,
        .abi = .none,
    });

    const kernel = b.addExecutable(.{
        .name = "kernel",
        .root_module = b.createModule(.{
            .optimize = optimize,
            .root_source_file = b.path("src/main.zig"),
            .target = target,
            .code_model = .kernel,
        }),
    });
    kernel.setLinkerScript(b.path("src/linker.ld"));

    b.installArtifact(kernel);
}
