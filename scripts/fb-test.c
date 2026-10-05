/* SPDX-License-Identifier: MIT */
/* RGB565 framebuffer test for the ST7789V /dev/fb1. */
#include <errno.h>
#include <fcntl.h>
#include <linux/fb.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/mman.h>
#include <time.h>
#include <unistd.h>

static uint16_t rgb565(unsigned r, unsigned g, unsigned b)
{
	return (uint16_t)(((r & 0xf8) << 8) | ((g & 0xfc) << 3) | (b >> 3));
}

static void put_pixel(uint8_t *mem, const struct fb_fix_screeninfo *fix,
		      const struct fb_var_screeninfo *var,
		      unsigned x, unsigned y, uint16_t color)
{
	size_t off = (size_t)(y + var->yoffset) * fix->line_length +
		     (size_t)(x + var->xoffset) * 2;
	mem[off] = color & 0xff;
	mem[off + 1] = color >> 8;
}

static void fill(uint8_t *mem, const struct fb_fix_screeninfo *fix,
		 const struct fb_var_screeninfo *var, uint16_t color)
{
	unsigned x, y;
	for (y = 0; y < var->yres; y++)
		for (x = 0; x < var->xres; x++)
			put_pixel(mem, fix, var, x, y, color);
}

static void bars(uint8_t *mem, const struct fb_fix_screeninfo *fix,
		 const struct fb_var_screeninfo *var)
{
	static const uint16_t c[] = {
		0xffff, 0xffe0, 0x07ff, 0x07e0,
		0xf81f, 0xf800, 0x001f, 0x0000
	};
	unsigned x, y, n = sizeof(c) / sizeof(c[0]);
	for (y = 0; y < var->yres; y++)
		for (x = 0; x < var->xres; x++)
			put_pixel(mem, fix, var, x, y, c[(x * n) / var->xres]);
}

static void gradient(uint8_t *mem, const struct fb_fix_screeninfo *fix,
		     const struct fb_var_screeninfo *var)
{
	unsigned x, y;
	for (y = 0; y < var->yres; y++) {
		for (x = 0; x < var->xres; x++) {
			unsigned r = x * 255 / (var->xres - 1);
			unsigned g = y * 255 / (var->yres - 1);
			unsigned b = (x + y) * 255 / (var->xres + var->yres - 2);
			put_pixel(mem, fix, var, x, y, rgb565(r, g, b));
		}
	}
}

static void pause_ms(unsigned ms)
{
	struct timespec ts = { ms / 1000, (long)(ms % 1000) * 1000000L };
	nanosleep(&ts, NULL);
}

int main(int argc, char **argv)
{
	const char *path = argc > 1 ? argv[1] : "/dev/fb1";
	struct fb_fix_screeninfo fix;
	struct fb_var_screeninfo var;
	uint8_t *mem;
	int fd = open(path, O_RDWR);
	if (fd < 0) {
		fprintf(stderr, "open %s: %s\n", path, strerror(errno));
		return 1;
	}
	if (ioctl(fd, FBIOGET_FSCREENINFO, &fix) ||
	    ioctl(fd, FBIOGET_VSCREENINFO, &var)) {
		perror("framebuffer ioctl");
		close(fd);
		return 1;
	}
	printf("%s: id=%s %ux%u virtual=%ux%u bpp=%u line=%u bytes=%u\n",
	       path, fix.id, var.xres, var.yres, var.xres_virtual,
	       var.yres_virtual, var.bits_per_pixel, fix.line_length,
	       fix.smem_len);
	if (var.bits_per_pixel != 16) {
		fprintf(stderr, "expected RGB565/16bpp, got %u bpp\n",
			var.bits_per_pixel);
		close(fd);
		return 2;
	}
	mem = mmap(NULL, fix.smem_len, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
	if (mem == MAP_FAILED) {
		perror("mmap");
		close(fd);
		return 1;
	}

	fill(mem, &fix, &var, rgb565(255, 0, 0)); pause_ms(1500);
	fill(mem, &fix, &var, rgb565(0, 255, 0)); pause_ms(1500);
	fill(mem, &fix, &var, rgb565(0, 0, 255)); pause_ms(1500);
	fill(mem, &fix, &var, rgb565(255, 255, 255)); pause_ms(1500);
	fill(mem, &fix, &var, rgb565(0, 0, 0)); pause_ms(1500);
	gradient(mem, &fix, &var); pause_ms(2500);
	bars(mem, &fix, &var);
	msync(mem, fix.smem_len, MS_SYNC);

	munmap(mem, fix.smem_len);
	close(fd);
	return 0;
}

