"""
split_koala.py

Delar upp en Koala Painter-fil (.kla / .koa / .koala) i de tre
binärfiler som Divine-demots source.asm laddar in med incbin:

    bitmap.bin     8000 bytes  (bitmap-data)
    screen.bin     1000 bytes  (skärm-RAM / teckenfärger)
    colorram.bin   1000 bytes  (färg-RAM)

Koala-formatet (standard, 10003 bytes):
    offset 0-1      : load-adress ($00 $60), ignoreras
    offset 2-8001    : bitmap        (8000 bytes)
    offset 8002-9001 : skärm-RAM     (1000 bytes)
    offset 9002-10001: färg-RAM      (1000 bytes)
    offset 10002      : bakgrundsfärg (1 byte, 0-15)

Användning:
    python split_koala.py minbild.koala

Filerna bitmap.bin, screen.bin och colorram.bin skrivs till samma
mapp som detta skript ligger i (D:\\GitRepos\\Divine), och skriver
över de befintliga filerna.
"""

import sys
import os

EXPECTED_SIZE = 10003
HEADER_SIZE = 2
BITMAP_SIZE = 8000
SCREEN_SIZE = 1000
COLOR_SIZE = 1000

OUTPUT_DIR = os.path.dirname(os.path.abspath(__file__))


def split_koala(koala_path):
    with open(koala_path, "rb") as f:
        data = f.read()

    size = len(data)
    if size not in (EXPECTED_SIZE, EXPECTED_SIZE - 1):
        print(f"VARNING: Filen är {size} bytes, förväntade {EXPECTED_SIZE} "
              f"(eller {EXPECTED_SIZE - 1} utan bakgrundsfärgbyte).")
        print("Fortsätter ändå, men kontrollera att filen verkligen är i Koala-format.")

    offset = HEADER_SIZE
    bitmap = data[offset:offset + BITMAP_SIZE]
    offset += BITMAP_SIZE
    screen = data[offset:offset + SCREEN_SIZE]
    offset += SCREEN_SIZE
    colorram = data[offset:offset + COLOR_SIZE]
    offset += COLOR_SIZE

    bgcolor = None
    if len(data) > offset:
        bgcolor = data[offset] & 0x0F

    if len(bitmap) != BITMAP_SIZE:
        print(f"FEL: bitmap-delen blev {len(bitmap)} bytes, förväntade {BITMAP_SIZE}. Avbryter.")
        sys.exit(1)
    if len(screen) != SCREEN_SIZE:
        print(f"FEL: skärm-delen blev {len(screen)} bytes, förväntade {SCREEN_SIZE}. Avbryter.")
        sys.exit(1)
    if len(colorram) != COLOR_SIZE:
        print(f"FEL: färg-RAM-delen blev {len(colorram)} bytes, förväntade {COLOR_SIZE}. Avbryter.")
        sys.exit(1)

    bitmap_path = os.path.join(OUTPUT_DIR, "bitmap.bin")
    screen_path = os.path.join(OUTPUT_DIR, "screen.bin")
    colorram_path = os.path.join(OUTPUT_DIR, "colorram.bin")

    with open(bitmap_path, "wb") as f:
        f.write(bitmap)
    with open(screen_path, "wb") as f:
        f.write(screen)
    with open(colorram_path, "wb") as f:
        f.write(colorram)

    print("Klart! Skrev:")
    print(f"  {bitmap_path}    ({len(bitmap)} bytes)")
    print(f"  {screen_path}    ({len(screen)} bytes)")
    print(f"  {colorram_path}  ({len(colorram)} bytes)")

    if bgcolor is not None:
        print(f"\nBakgrundsfärg i koala-filen: {bgcolor} (${bgcolor:02X})")
        print("OBS: Detta värde sätts INTE automatiskt i source.asm.")
        print("Om det inte är svart (0), uppdatera raden 'LDA #$00 / STA BGCOL'")
        print(f"i START-rutinen till 'LDA #${bgcolor:02X}' om du vill matcha bilden.")
    else:
        print("\nIngen bakgrundsfärgbyte hittades i filen (kortare format).")
        print("BGCOL i source.asm förblir oförändrad (svart).")


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Användning: python split_koala.py <sökväg-till-koalafil>")
        sys.exit(1)

    koala_file = sys.argv[1]
    if not os.path.isfile(koala_file):
        print(f"Hittar inte filen: {koala_file}")
        sys.exit(1)

    split_koala(koala_file)
