import zlib, struct, os
W, H = 48, 48
BASE = 'd:/IdeaProjects/last-train-car-13/assets'

def make(w, h):
    return bytearray(w * h * 4)

def sp(buf, w, x, y, c):
    if x < 0 or y < 0 or x >= w or y >= H:
        return
    i = (y * w + x) * 4
    buf[i] = c[0]; buf[i+1] = c[1]; buf[i+2] = c[2]; buf[i+3] = c[3]

def rect(b, w, x0, y0, x1, y1, c):
    for y in range(max(0, y0), min(H, y1+1)):
        for x in range(max(0, x0), min(W, x1+1)):
            sp(b, w, x, y, c)

def disc(b, w, cx, cy, r, c):
    for y in range(H):
        for x in range(W):
            if (x - cx) ** 2 + (y - cy) ** 2 <= r * r:
                sp(b, w, x, y, c)

S = (28, 30, 40, 255)
CO = (40, 46, 66, 255)
CO2 = (30, 34, 50, 255)
SK = (214, 180, 150, 255)
HA = (44, 30, 30, 255)
CY = (86, 200, 222, 255)
CY2 = (54, 150, 176, 255)
P = (224, 226, 234, 255)
BL = (20, 20, 28, 255)
SH = (0, 0, 0, 55)

b = make(W, H)
for y in range(32, 34):
    for x in range(16, 32):
        sp(b, W, x, y, SH)
rect(b, W, 17, 30, 21, 32, BL); rect(b, W, 26, 30, 31, 32, BL)
rect(b, W, 17, 30, 18, 33, S); rect(b, W, 30, 30, 31, 33, S)
rect(b, W, 17, 25, 21, 30, CO2); rect(b, W, 26, 25, 31, 30, CO2)
rect(b, W, 18, 25, 21, 29, S); rect(b, W, 27, 25, 30, 29, S)
rect(b, W, 15, 17, 33, 30, CO)
rect(b, W, 15, 17, 33, 18, CO2)
rect(b, W, 15, 17, 15, 30, S); rect(b, W, 33, 17, 33, 30, S)
rect(b, W, 20, 17, 28, 20, P)
rect(b, W, 20, 18, 21, 22, CY); rect(b, W, 20, 20, 21, 21, CY2)
rect(b, W, 21, 18, 22, 24, CY2)
rect(b, W, 13, 18, 15, 26, CO); rect(b, W, 33, 18, 35, 26, CO)
rect(b, W, 13, 18, 13, 26, S); rect(b, W, 35, 18, 35, 26, S)
rect(b, W, 13, 25, 15, 26, S); rect(b, W, 33, 25, 35, 26, S)
rect(b, W, 13, 25, 15, 27, SK); rect(b, W, 33, 25, 35, 27, SK)
rect(b, W, 22, 15, 26, 17, SK)
disc(b, W, 24, 12, 4, SK)
for y in range(7, 17):
    for x in range(20, 29):
        dx = x - 24; dy = y - 12
        if dx*dx + dy*dy <= 16:
            sp(b, W, x, y, SK)
for y in range(7, 13):
    for x in range(19, 30):
        dx = x - 24; dy = y - 12
        if dx*dx + dy*dy <= 20 and y < 12:
            sp(b, W, x, y, HA)
sp(b, W, 19, 11, HA); sp(b, W, 29, 11, HA); sp(b, W, 19, 12, HA); sp(b, W, 29, 12, HA)
sp(b, W, 21, 12, (180, 150, 128, 255)); sp(b, W, 27, 12, (180, 150, 128, 255))
sp(b, W, 22, 11, CY); sp(b, W, 26, 11, CY)
rect(b, W, 15, 24, 33, 26, CO2)
rect(b, W, 23, 24, 25, 26, CY); sp(b, W, 24, 25, CY2)

def write_png(path, w, h, buf):
    stride = w * 4
    raw = bytearray()
    for y in range(h):
        raw.append(0)
        raw += buf[y*stride:(y+1)*stride]
    comp = zlib.compress(bytes(raw), 9)
    def ch(t, d):
        return struct.pack('>I', len(d)) + t + d + struct.pack('>I', zlib.crc32(t + d) & 0xffffffff)
    with open(path, 'wb') as f:
        f.write(b'\x89PNG\r\n\x1a\n')
        f.write(ch(b'IHDR', struct.pack('>IIBBBBB', w, h, 8, 6, 0, 0, 0)))
        f.write(ch(b'IDAT', comp))
        f.write(ch(b'IEND', b''))

write_png(BASE + '/player_idle.png', W, H, b)
print('written', os.path.getsize(BASE + '/player_idle.png'), 'bytes')
