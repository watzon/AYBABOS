const std = @import("std");
const builtin = @import("builtin");
const Builder = std.build.Builder;
const Target = std.Target;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("aybabos-x86.bin", "src/kernel/arch/x86/boot/main.zig");

    exe.setLinkerScriptPath("src/kernel/arch/x86/boot/setup.ld");
    exe.setTarget(.{ .cpu_arch = .i386, .os_tag = .freestanding });
    // exe.addPackagePath("drivers", "./src/drivers.zig");
    exe.addPackagePath("kernel", "./src/kernel.zig");

    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
