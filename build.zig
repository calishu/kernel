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
    // kernel.use_lld = true;
    kernel.setLinkerScript(b.path("src/linker.ld"));
    kernel.entry = .{ .symbol_name = "_start" };
    // kernel.want_lto = true;
    // kernel.image_base = 0xffffffff80000000;

    b.installArtifact(kernel);

    createIsoStep(b, kernel);
}

pub fn createIsoStep(b: *std.Build, exe: *std.Build.Step.Compile) void {
    const iso_step = b.step("iso", "Build the bootable ISO image");

    // copy kernel to `iso_root`
    const copy_kernel = b.addSystemCommand(&.{ "cp" });
    copy_kernel.addArtifactArg(exe);
    copy_kernel.addArgs(&.{ "iso_root/kernel" });

    // build the iso
    const xorriso = b.addSystemCommand(&.{
        "xorriso", "-as", "mkisofs",
        "-b", "limine-bios-cd.bin",
        "-no-emul-boot",
        "-boot-load-size", "4",
        "-boot-info-table",
        "--efi-boot", "limine-uefi-cd.bin",
        "-efi-boot-part",
        "--efi-boot-image",
        "--protective-msdos-label",
        "iso_root",
        "-o", "os.iso"
    });

    // install bios onto iso
    const limine = b.addSystemCommand(&.{ "./limine", "bios-install", "os.iso" });

    xorriso.step.dependOn(&copy_kernel.step);
    limine.step.dependOn(&xorriso.step);
    iso_step.dependOn(&limine.step);
}
