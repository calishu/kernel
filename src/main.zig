// ai generated dummy, I am still fighting around with the fact that the zig internal linker is overriding the custom linker
const std = @import("std");

pub export var framebuffer_request: [4]u64 align(8) linksection(".requests") = .{
    0xc7b1dd30df4c4148, 0x047f0c37070122da,
    0,
    0,
};

export fn _start() noreturn {
    // 1. Get the response pointer from index [3]
    const response_ptr = framebuffer_request[3];

    if (response_ptr != 0) {
        // Limine returns a pointer to a struct. Let's cast it.
        // The struct contains: framebuffer_count, **framebuffers
        const response = @as(*FramebufferResponse, @ptrFromInt(response_ptr));

        if (response.framebuffer_count > 0) {
            // Get the first framebuffer
            const fb = response.framebuffers[0];

            // Draw a tiny white square (100x100)
            var y: u64 = 0;
            while (y < 100) : (y += 1) {
                var x: u64 = 0;
                while (x < 100) : (x += 1) {
                    // Assuming 32-bit pixels (ARGB)
                    const pixel_offset = (y * (fb.pitch / 4)) + x;
                    fb.address[pixel_offset] = 0xFFFFFFFF;
                }
            }
        }
    }

    while (true) {
        asm volatile ("hlt");
    }
}

// These helper structs match the Limine Protocol layout
const Framebuffer = extern struct {
    address: [*]u32,
    width: u64,
    height: u64,
    pitch: u64,
    bpp: u16,
    memory_model: u8,
    red_mask_size: u8,
    red_mask_shift: u8,
    green_mask_size: u8,
    green_mask_shift: u8,
    blue_mask_size: u8,
    blue_mask_shift: u8,
    unused: u8,
    edid_size: u64,
    edid: ?*anyopaque,
};

const FramebufferResponse = extern struct {
    revision: u64,
    framebuffer_count: u64,
    framebuffers: [*]*Framebuffer,
};
