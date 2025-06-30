const std = @import("std");
const mat = @import("mat.zig");

const SAMPLE_RATE: f32 = 44.1e3;
const SAMPLE_TIME: f32 = 1e-3;

const SAMPLES: i32 = @intFromFloat(SAMPLE_RATE * SAMPLE_TIME);

const SPEED_OF_SOUND: f32 = 343;

const SinSource = struct {
    const Self = @This();
    pos: mat.Vec3f,
    frequency: f32,

    pub fn getPressure(self: Self, time: f32, dist: f32) f32 {
        return std.math.sin((time - dist / SPEED_OF_SOUND) * self.frequency * std.math.tau);
    }
};

const Camera = struct {
    const Self = @This();
    pos: mat.Vec3f,
    samples: [SAMPLES]i16 = undefined,
};

var sources = [_]SinSource{
    .{
        .pos = mat.Vec3f.new(.{ 0, 0, 0 }),
        .frequency = 500,
    },
    .{
        .pos = mat.Vec3f.new(.{ 1, 0, 0 }),
        .frequency = 600,
    },
};

var cameras = [_]Camera{
    .{
        .pos = mat.Vec3f.new(.{ 2, 0, 0 }),
    },
    .{
        .pos = mat.Vec3f.new(.{ 0, 2, 0 }),
    },
    .{
        .pos = mat.Vec3f.new(.{ 0, 0, 2 }),
    },
    .{
        .pos = mat.Vec3f.new(.{ -1, -1, -1 }),
    },
};

pub fn main() !void {
    // const start_time = std.time.microTimestamp();
    for (0..SAMPLES) |i| {
        for (&cameras) |*camera| {
            var pressure: i16 = 0;
            for (sources) |source| {
                const dist = camera.pos.sub(source.pos).norm();
                std.debug.print("dist:{d}\n", .{dist});

                pressure += @intFromFloat(source.getPressure(@as(f32, @floatFromInt(i)) / SAMPLE_RATE, dist) * (1 << 14));
            }

            camera.samples[i] = pressure;
        }
    }

    for (cameras) |camera| {
        std.debug.print("camera: {any}\n", .{camera});
    }
}
