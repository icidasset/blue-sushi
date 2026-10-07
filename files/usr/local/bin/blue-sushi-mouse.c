/* blue-sushi-mouse: NZXT Gaming Mouse side buttons -> F24/F13 (uinput).
 * Grabs the source device exclusively and forwards every event verbatim
 * through a uinput device that mirrors the source's capabilities, so motion,
 * wheel and clicks behave exactly as before. BTN_SIDE/BTN_EXTRA are
 * translated to KEY_F24/KEY_F19 instead of being forwarded.
 *
 * Kernel-side key remapping (EVIOCSKEYCODE / udev hwdb) is impossible on this
 * mouse (no keymap table), hence this daemon. Umbriel binds the resulting
 * bare keys: F24 = overview toggle, F13 = vicinae toggle.
 */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <linux/input.h>
#include <linux/uinput.h>
#include <sys/ioctl.h>

static int ui_fd = -1;

static void emit(int type, int code, int value) {
    struct input_event ev;
    memset(&ev, 0, sizeof(ev));
    ev.type = type; ev.code = code; ev.value = value;
    if (write(ui_fd, &ev, sizeof(ev)) != sizeof(ev)) { /* ignore */ }
}

static void set_one(int t, int c) {
    switch (t) {
    case EV_KEY: ioctl(ui_fd, UI_SET_KEYBIT, c); break;
    case EV_REL: ioctl(ui_fd, UI_SET_RELBIT, c); break;
    case EV_MSC: ioctl(ui_fd, UI_SET_MSCBIT, c); break;
    default: break;
    }
}

/* Copy the source device's EV_KEY/EV_REL/EV_MSC capabilities (a pointer
 * mouse needs nothing else; ABS handling is left out on purpose). */
static int mirror_caps(int src_fd) {
    unsigned long evbits = 0;
    if (ioctl(src_fd, EVIOCGBIT(0, sizeof(evbits)), &evbits) < 0)
        return -1;
    for (int t = 0; t < EV_MAX; t++) {
        if (!(evbits & (1UL << t)))
            continue;
        size_t n = 0;
        switch (t) {
        case EV_KEY: n = KEY_MAX; break;
        case EV_REL: n = REL_MAX; break;
        case EV_MSC: n = MSC_MAX; break;
        default: continue; /* SYN handled by uinput; REP/ABS/etc not needed */
        }
        unsigned char bits[(KEY_MAX + 7) / 8];
        memset(bits, 0, sizeof(bits));
        if (ioctl(src_fd, EVIOCGBIT(t, sizeof(bits)), bits) < 0)
            continue;
        if (ioctl(ui_fd, UI_SET_EVBIT, t) < 0)
            continue;
        for (int c = 0; c < (int)n; c++)
            if (bits[c / 8] & (1U << (c % 8)))
                set_one(t, c);
    }
    /* plus the two synthetic keys */
    ioctl(ui_fd, UI_SET_EVBIT, EV_KEY);
    ioctl(ui_fd, UI_SET_KEYBIT, KEY_F19);
    ioctl(ui_fd, UI_SET_KEYBIT, KEY_F24);
    return 0;
}

int main(int argc, char **argv) {
    if (argc < 2) {
        fprintf(stderr, "usage: %s /dev/input/eventX\n", argv[0]);
        return 1;
    }

    int src_fd = open(argv[1], O_RDONLY);
    if (src_fd < 0) { perror("open source device"); return 2; }

    ui_fd = open("/dev/uinput", O_WRONLY);
    if (ui_fd < 0) { perror("open /dev/uinput"); return 2; }
    if (mirror_caps(src_fd) < 0) { perror("mirror caps"); return 2; }

    struct uinput_setup us;
    memset(&us, 0, sizeof(us));
    us.id.bustype = BUS_USB;
    us.id.vendor = 0x1e71;   /* NZXT */
    us.id.product = 0x2124;
    strncpy(us.name, "blue-sushi mouse remap", sizeof(us.name) - 1);
    if (ioctl(ui_fd, UI_DEV_SETUP, &us) < 0) { perror("UI_DEV_SETUP"); return 2; }
    if (ioctl(ui_fd, UI_DEV_CREATE) < 0) { perror("UI_DEV_CREATE"); return 2; }

    if (ioctl(src_fd, EVIOCGRAB, 1) < 0) { perror("EVIOCGRAB"); return 2; }

    struct input_event ev;
    while (read(src_fd, &ev, sizeof(ev)) == (ssize_t)sizeof(ev)) {
        if (ev.type == EV_KEY && ev.code == BTN_SIDE) {
            emit(EV_KEY, KEY_F24, ev.value);
            emit(EV_SYN, SYN_REPORT, 0);
            continue;
        }
        if (ev.type == EV_KEY && ev.code == BTN_EXTRA) {
            emit(EV_KEY, KEY_F19, ev.value);
            emit(EV_SYN, SYN_REPORT, 0);
            continue;
        }
        if (write(ui_fd, &ev, sizeof(ev)) != sizeof(ev)) { /* ignore */ }
    }
    ioctl(ui_fd, UI_DEV_DESTROY);
    return 0;
}
