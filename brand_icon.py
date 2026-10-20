"""Generate the ANVIA mark for the app and platform launchers."""

import json
from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parent
SIZE = 1024
image = Image.new("RGB", (SIZE, SIZE), "#006F51")
draw = ImageDraw.Draw(image)

# A broad, readable A represents the start of a route. The curved crossbar is
# the path itself; no lettering is baked into the small launcher icon.
cream = "#F5FFF8"
mint = "#9EE5C3"
draw.line([(282, 748), (512, 260), (742, 748)], fill=cream, width=112, joint="curve")
for x, y in [(282, 748), (512, 260), (742, 748)]:
    draw.ellipse((x - 56, y - 56, x + 56, y + 56), fill=cream)

path = [(389, 638), (512, 585), (635, 638)]
draw.line(path, fill=mint, width=74, joint="curve")
for x, y in path:
    draw.ellipse((x - 37, y - 37, x + 37, y + 37), fill=mint)

resampling = Image.Resampling.LANCZOS
image.resize((512, 512), resampling).save(ROOT / "assets" / "logo.png")

android_sizes = {"mdpi": 48, "hdpi": 72, "xhdpi": 96, "xxhdpi": 144, "xxxhdpi": 192}
for density, size in android_sizes.items():
    destination = ROOT / "android" / "app" / "src" / "main" / "res" / f"mipmap-{density}" / "ic_launcher.png"
    image.resize((size, size), resampling).save(destination)

app_icons = ROOT / "ios" / "Runner" / "Assets.xcassets" / "AppIcon.appiconset"
contents = json.loads((app_icons / "Contents.json").read_text(encoding="utf-8"))
for item in contents["images"]:
    side = round(float(item["size"].split("x")[0]) * int(item["scale"][0]))
    image.resize((side, side), resampling).save(app_icons / item["filename"])
