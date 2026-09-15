pub const packages = struct {
    pub const @"../Cubyz-libs/zig-out" = struct {
        pub const available = true;
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\../Cubyz-libs/zig-out";
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"N-V-__8AACbJDAN2FUnjncVZbrRCVIqJU0jOmXeOYp91Dye3" = struct {
        pub const available = false;
    };
    pub const @"N-V-__8AAGraCQMrbnuuZOfcwon3nuXQctCmUrO29zh-7vmd" = struct {
        pub const available = false;
    };
    pub const @"N-V-__8AAH13EweheT5OUNQg6SvWhcJENd2Ysd7TTo-yakiO" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\N-V-__8AAH13EweheT5OUNQg6SvWhcJENd2Ysd7TTo-yakiO";
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"N-V-__8AAJ55LAO5fpHky9VeU1aZfg20uFxUCBp1GpMS7Ck_" = struct {
        pub const available = false;
    };
    pub const @"N-V-__8AAJL3TQPVI95OraBXiDeB61x59EZPWkCvISKUsIxd" = struct {
        pub const available = true;
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\N-V-__8AAJL3TQPVI95OraBXiDeB61x59EZPWkCvISKUsIxd";
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"N-V-__8AALKj1AXwkr2SLawu5qZ4RPAsJubW-AAXs7UG-G8A" = struct {
        pub const available = false;
    };
    pub const @"N-V-__8AAMq6gAB96bzJsMrlYdZKbZ1Qc_Ine5E08vH9Zx0w" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\N-V-__8AAMq6gAB96bzJsMrlYdZKbZ1Qc_Ine5E08vH9Zx0w";
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"N-V-__8AANj7xgXmZ00RDncJTWhYEBz81jr4aGbZGaOf0TNW" = struct {
        pub const available = false;
    };
    pub const @"zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_" = struct {
        pub const available = true;
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_";
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "standalone_test_cases", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone" },
            .{ "link_test_cases", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link" },
        };
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "bss", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/bss" },
            .{ "common_symbols_alignment", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/common_symbols_alignment" },
            .{ "interdependent_static_c_libs", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/interdependent_static_c_libs" },
            .{ "static_libs_from_object_files", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/static_libs_from_object_files" },
            .{ "wasm_archive", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/archive" },
            .{ "wasm_basic_features", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/basic-features" },
            .{ "wasm_export", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/export" },
            .{ "wasm_export_data", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/export-data" },
            .{ "wasm_extern", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/extern" },
            .{ "wasm_extern_mangle", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/extern-mangle" },
            .{ "wasm_function_table", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/function-table" },
            .{ "wasm_infer_features", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/infer-features" },
            .{ "wasm_producers", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/producers" },
            .{ "wasm_shared_memory", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/shared-memory" },
            .{ "wasm_stack_pointer", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/stack_pointer" },
            .{ "wasm_type", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/type" },
        };
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/bss" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/bss";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/bss");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/common_symbols_alignment" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/common_symbols_alignment";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/common_symbols_alignment");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/interdependent_static_c_libs" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/interdependent_static_c_libs";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/interdependent_static_c_libs");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/static_libs_from_object_files" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/static_libs_from_object_files";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/static_libs_from_object_files");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/archive" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/archive";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/archive");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/basic-features" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/basic-features";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/basic-features");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/export" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/export";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/export");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/export-data" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/export-data";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/export-data");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/extern" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/extern";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/extern");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/extern-mangle" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/extern-mangle";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/extern-mangle");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/function-table" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/function-table";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/function-table");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/infer-features" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/infer-features";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/infer-features");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/producers" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/producers";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/producers");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/shared-memory" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/shared-memory";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/shared-memory");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/stack_pointer" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/stack_pointer";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/stack_pointer");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/type" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/type";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/link/wasm/type");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "simple", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/simple" },
            .{ "test_obj_link_run", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/test_obj_link_run" },
            .{ "test_runner_path", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/test_runner_path" },
            .{ "test_runner_module_imports", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/test_runner_module_imports" },
            .{ "shared_library", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/shared_library" },
            .{ "mix_o_files", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/mix_o_files" },
            .{ "mix_c_files", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/mix_c_files" },
            .{ "global_linkage", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/global_linkage" },
            .{ "static_c_lib", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/static_c_lib" },
            .{ "issue_339", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_339" },
            .{ "compile_asm", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/compile_asm" },
            .{ "issue_794", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_794" },
            .{ "issue_5825", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_5825" },
            .{ "pkg_import", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/pkg_import" },
            .{ "glibc_compat", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/glibc_compat" },
            .{ "install_raw_hex", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/install_raw_hex" },
            .{ "emit_asm_and_bin", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/emit_asm_and_bin" },
            .{ "emit_llvm_no_bin", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/emit_llvm_no_bin" },
            .{ "emit_asm_no_bin", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/emit_asm_no_bin" },
            .{ "child_process", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/child_process" },
            .{ "embed_generated_file", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/embed_generated_file" },
            .{ "extern", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/extern" },
            .{ "dep_diamond", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_diamond" },
            .{ "dep_triangle", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_triangle" },
            .{ "dep_recursive", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_recursive" },
            .{ "dep_mutually_recursive", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_mutually_recursive" },
            .{ "dep_shared_builtin", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_shared_builtin" },
            .{ "dep_lazypath", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_lazypath" },
            .{ "dirname", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dirname" },
            .{ "dep_duplicate_module", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_duplicate_module" },
            .{ "empty_env", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/empty_env" },
            .{ "env_vars", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/env_vars" },
            .{ "issue_11595", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_11595" },
            .{ "libcxx", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/libcxx" },
            .{ "libfuzzer", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/libfuzzer" },
            .{ "load_dynamic_library", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/load_dynamic_library" },
            .{ "windows_resources", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_resources" },
            .{ "windows_entry_points", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_entry_points" },
            .{ "windows_spawn", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_spawn" },
            .{ "windows_argv", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_argv" },
            .{ "windows_bat_args", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_bat_args" },
            .{ "windows_paths", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_paths" },
            .{ "self_exe_symlink", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/self_exe_symlink" },
            .{ "c_compiler", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/c_compiler" },
            .{ "c_embed_path", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/c_embed_path" },
            .{ "issue_12706", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_12706" },
            .{ "strip_empty_loop", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/strip_empty_loop" },
            .{ "strip_struct_init", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/strip_struct_init" },
            .{ "cmakedefine", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/cmakedefine" },
            .{ "zerolength_check", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/zerolength_check" },
            .{ "coff_dwarf", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/coff_dwarf" },
            .{ "compiler_rt_panic", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/compiler_rt_panic" },
            .{ "ios", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/ios" },
            .{ "depend_on_main_mod", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/depend_on_main_mod" },
            .{ "install_headers", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/install_headers" },
            .{ "dependency_options", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependency_options" },
            .{ "dependencyFromBuildZig", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependencyFromBuildZig" },
            .{ "run_output_paths", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/run_output_paths" },
            .{ "run_output_caching", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/run_output_caching" },
            .{ "empty_global_error_set", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/empty_global_error_set" },
            .{ "config_header", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/config_header" },
            .{ "entry_point", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/entry_point" },
            .{ "run_cwd", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/run_cwd" },
            .{ "posix", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/posix" },
            .{ "debug_io_color", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/debug_io_color" },
        };
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/c_compiler" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/c_compiler";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/c_compiler");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/c_embed_path" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/c_embed_path";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/c_embed_path");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/child_process" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/child_process";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/child_process");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/cmakedefine" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/cmakedefine";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/cmakedefine");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/coff_dwarf" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/coff_dwarf";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/coff_dwarf");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/compile_asm" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/compile_asm";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/compile_asm");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/compiler_rt_panic" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/compiler_rt_panic";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/compiler_rt_panic");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/config_header" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/config_header";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/config_header");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/debug_io_color" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/debug_io_color";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/debug_io_color");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_diamond" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_diamond";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_diamond");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_duplicate_module" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_duplicate_module";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_duplicate_module");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_lazypath" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_lazypath";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_lazypath");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_mutually_recursive" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_mutually_recursive";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_mutually_recursive");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_recursive" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_recursive";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_recursive");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_shared_builtin" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_shared_builtin";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_shared_builtin");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_triangle" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_triangle";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dep_triangle");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/depend_on_main_mod" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/depend_on_main_mod";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/depend_on_main_mod");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependencyFromBuildZig" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependencyFromBuildZig";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependencyFromBuildZig");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "other", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependencyFromBuildZig/other" },
        };
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependencyFromBuildZig/other" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependencyFromBuildZig/other";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependencyFromBuildZig/other");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependency_options" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependency_options";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependency_options");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
            .{ "other", "zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependency_options/other" },
        };
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependency_options/other" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependency_options/other";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dependency_options/other");
        pub const deps: []const struct { []const u8, []const u8 } = &.{
        };
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dirname" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dirname";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/dirname");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/embed_generated_file" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/embed_generated_file";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/embed_generated_file");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/emit_asm_and_bin" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/emit_asm_and_bin";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/emit_asm_and_bin");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/emit_asm_no_bin" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/emit_asm_no_bin";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/emit_asm_no_bin");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/emit_llvm_no_bin" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/emit_llvm_no_bin";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/emit_llvm_no_bin");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/empty_env" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/empty_env";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/empty_env");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/empty_global_error_set" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/empty_global_error_set";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/empty_global_error_set");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/entry_point" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/entry_point";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/entry_point");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/env_vars" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/env_vars";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/env_vars");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/extern" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/extern";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/extern");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/glibc_compat" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/glibc_compat";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/glibc_compat");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/global_linkage" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/global_linkage";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/global_linkage");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/install_headers" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/install_headers";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/install_headers");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/install_raw_hex" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/install_raw_hex";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/install_raw_hex");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/ios" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/ios";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/ios");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_11595" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_11595";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_11595");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_12706" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_12706";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_12706");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_339" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_339";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_339");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_5825" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_5825";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_5825");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_794" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_794";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/issue_794");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/libcxx" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/libcxx";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/libcxx");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/libfuzzer" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/libfuzzer";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/libfuzzer");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/load_dynamic_library" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/load_dynamic_library";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/load_dynamic_library");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/mix_c_files" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/mix_c_files";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/mix_c_files");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/mix_o_files" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/mix_o_files";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/mix_o_files");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/pkg_import" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/pkg_import";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/pkg_import");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/posix" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/posix";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/posix");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/run_cwd" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/run_cwd";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/run_cwd");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/run_output_caching" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/run_output_caching";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/run_output_caching");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/run_output_paths" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/run_output_paths";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/run_output_paths");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/self_exe_symlink" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/self_exe_symlink";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/self_exe_symlink");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/shared_library" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/shared_library";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/shared_library");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/simple" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/simple";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/simple");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/static_c_lib" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/static_c_lib";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/static_c_lib");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/strip_empty_loop" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/strip_empty_loop";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/strip_empty_loop");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/strip_struct_init" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/strip_struct_init";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/strip_struct_init");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/test_obj_link_run" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/test_obj_link_run";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/test_obj_link_run");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/test_runner_module_imports" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/test_runner_module_imports";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/test_runner_module_imports");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/test_runner_path" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/test_runner_path";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/test_runner_path");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_argv" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_argv";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_argv");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_bat_args" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_bat_args";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_bat_args");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_entry_points" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_entry_points";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_entry_points");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_paths" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_paths";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_paths");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_resources" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_resources";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_resources");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_spawn" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_spawn";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/windows_spawn");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
    pub const @"zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/zerolength_check" = struct {
        pub const build_root = "C:\\Users\\user\\Cubyz-Server\\zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/zerolength_check";
        pub const build_zig = @import("zig-pkg\\zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_/test/standalone/zerolength_check");
        pub const deps: []const struct { []const u8, []const u8 } = &.{};
    };
};

pub const root_deps: []const struct { []const u8, []const u8 } = &.{
    .{ "local", "../Cubyz-libs/zig-out" },
    .{ "cubyz_deps_headers", "N-V-__8AAMq6gAB96bzJsMrlYdZKbZ1Qc_Ine5E08vH9Zx0w" },
    .{ "cubyz_deps_aarch64_macos", "N-V-__8AALKj1AXwkr2SLawu5qZ4RPAsJubW-AAXs7UG-G8A" },
    .{ "cubyz_deps_aarch64_linux", "N-V-__8AAGraCQMrbnuuZOfcwon3nuXQctCmUrO29zh-7vmd" },
    .{ "cubyz_deps_aarch64_windows", "N-V-__8AAJ55LAO5fpHky9VeU1aZfg20uFxUCBp1GpMS7Ck_" },
    .{ "cubyz_deps_x86_64_macos", "N-V-__8AANj7xgXmZ00RDncJTWhYEBz81jr4aGbZGaOf0TNW" },
    .{ "cubyz_deps_x86_64_linux", "N-V-__8AACbJDAN2FUnjncVZbrRCVIqJU0jOmXeOYp91Dye3" },
    .{ "cubyz_deps_x86_64_windows", "N-V-__8AAJL3TQPVI95OraBXiDeB61x59EZPWkCvISKUsIxd" },
    .{ "cubyz_large_assets", "N-V-__8AAH13EweheT5OUNQg6SvWhcJENd2Ysd7TTo-yakiO" },
    .{ "cubyz_test_runner", "zig-0.0.0-Fp4XJG_h5A3OLpPXqVTJ1DRl3lZhqHp_fClrI7MUVjU_" },
};
