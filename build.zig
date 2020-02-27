const builtin = @import("builtin");
const Builder = @import("std").build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const exe = b.addExecutable("aybabos-i386.bin", "./src/kernel/arch/i386/boot/boot.zig");

    exe.setLinkerScriptPath("./src/kernel/linker.ld");
    exe.setTarget(.i386, .freestanding, .none);
    // exe.addPackagePath("drivers", "./src/drivers.zig");
    exe.addPackagePath("kernel", "./src/kernel.zig");

    exe.setBuildMode(mode);
    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}
