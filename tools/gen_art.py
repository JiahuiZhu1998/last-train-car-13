import zlib, struct, os

def write_png(path, w, h, rgba):
    # rgba: bytearray of length w*h*4, row-major RGBA
    stride = w * 4
    raw = bytearray()
    for y in range(h):
        raw.append(0)  # filter type 0 (None) for this scanline
        raw += rgba[y*stride:(y+1)*stride]
    assert len(raw) == h * (stride + 1), (len(raw), h*(stride+1))
    comp = zlib.compress(bytes(raw), 9)
    def chunk(typ, data):
        return struct.pack(">I", len(data)) + typ + data + struct.pack(">I", zlib.crc32(typ+data) & 0xffffffff)
    with open(path, "wb") as f:
        f.write(b"\x89PNG\r\n\x1a\n")
        f.write(chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0)))
        f.write(chunk(b"IDAT", comp))
        f.write(chunk(b"IEND", b""))

def make(w, h):
    return bytearray(w*h*4)

def setpx(buf, w, x, y, c):
    if x<0 or y<0 or x>=w: return
    i = (y*w + x)*4
    buf[i]=c[0]; buf[i+1]=c[1]; buf[i+2]=c[2]; buf[i+3]=c[3]

def rect(buf, w, h, x0,y0,x1,y1,c):
    for y in range(max(0,y0), min(h,y1+1)):
        for x in range(max(0,x0), min(w,x1+1)):
            setpx(buf,w,x,y,c)

def disc(buf, w, h, cx,cy,r,c):
    for y in range(h):
        for x in range(w):
            if (x-cx)**2 + (y-cy)**2 <= r*r:
                setpx(buf,w,x,y,c)

A=(0,0,0,0)
# passenger 72x96
s=make(72,96)
rect(s,72,96,30,84,42,86,(0,0,0,60))
rect(s,72,96,31,66,35,82,(40,36,48,255))
rect(s,72,96,37,66,41,82,(40,36,48,255))
rect(s,72,96,30,80,36,84,(24,22,30,255))
rect(s,72,96,36,80,42,84,(24,22,30,255))
rect(s,72,96,28,38,44,68,(78,88,128,255))
rect(s,72,96,28,38,44,41,(58,66,100,255))
rect(s,72,96,34,38,38,44,(228,230,238,255))
rect(s,72,96,25,40,29,64,(78,88,128,255))
rect(s,72,96,43,40,47,64,(78,88,128,255))
rect(s,72,96,25,40,29,42,(58,66,100,255))
rect(s,72,96,43,40,47,42,(58,66,100,255))
rect(s,72,96,25,62,29,66,(220,182,150,255))
rect(s,72,96,43,62,47,66,(220,182,150,255))
rect(s,72,96,34,34,38,38,(220,182,150,255))
disc(s,72,96,36,24,10,(220,182,150,255))
for y in range(12,25):
  for x in range(26,47):
    dx=x-36; dy=y-24
    if dx*dx+dy*dy<=100 and y<23: setpx(s,72,x,y,(55,42,40,255))
rect(s,72,96,34,42,38,58,(150,42,60,255))
rect(s,72,96,30,22,35,23,(40,36,46,255))
rect(s,72,96,37,22,42,23,(40,36,46,255))
rect(s,72,96,28,34,28,68,(45,52,82,255))
rect(s,72,96,44,34,44,68,(45,52,82,255))
rect(s,72,96,25,64,47,64,(45,52,82,255))
write_png(r"d:\IdeaProjects\last-train-car-13\assets\passenger_sprite.png",72,96,s)

# key 32x32
k=make(32,32)
cx,cy=9,12
for y in range(32):
  for x in range(32):
    dx=x-cx; dy=y-cy; o=dx*dx+dy*dy
    if 16<o<=36: setpx(k,32,x,y,(232,196,72,255))
    if 36<o<=49: setpx(k,32,x,y,(196,158,48,255))
    if 49<o<=64: setpx(k,32,x,y,(120,96,28,255))
rect(k,32,32,8,16,10,26,(232,196,72,255))
rect(k,32,32,9,16,10,26,(196,158,48,255))
rect(k,32,32,8,21,11,22,(232,196,72,255))
rect(k,32,32,8,25,11,26,(232,196,72,255))
rect(k,32,32,11,21,13,22,(196,158,48,255))
rect(k,32,32,11,25,13,26,(196,158,48,255))
write_png(r"d:\IdeaProjects\last-train-car-13\assets\key_icon.png",32,32,k)

# clue 32x32
c=make(32,32)
rect(c,32,32,6,5,30,29,(20,18,30,70))
rect(c,32,32,5,4,29,28,(236,232,220,255))
rect(c,32,32,5,4,29,5,(216,212,200,255))
rect(c,32,32,5,27,29,28,(216,212,200,255))
rect(c,32,32,5,4,6,28,(216,212,200,255))
rect(c,32,32,28,4,29,28,(216,212,200,255))
rect(c,32,32,8,7,26,10,(38,30,32,255))
for ly in range(13,25,4):
  rect(c,32,32,8,ly,26,ly+1,(54,48,46,255))
rect(c,32,32,8,25,18,26,(54,48,46,255))
rect(c,32,32,22,19,26,21,(110,100,96,255))
write_png(r"d:\IdeaProjects\last-train-car-13\assets\clue_icon.png",32,32,c)
print("generated ok")
