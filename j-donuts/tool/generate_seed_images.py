"""Generates license-safe placeholder seed images for assets/seed/images.

Every image is drawn from primitives so the repository never contains
client artwork. Real photos can replace any file without code changes as
long as the filename stays the same.

Usage: python tool/generate_seed_images.py
"""

import math
import random
from pathlib import Path

from PIL import Image, ImageDraw

OUTPUT_DIR = Path(__file__).resolve().parent.parent / "assets" / "seed" / "images"
PRODUCT_SIZE = (360, 360)
BANNER_SIZE = (640, 320)
SHOP_SIZE = (480, 320)
AVATAR_SIZE = (160, 160)
WEBP_QUALITY = 78
SPRINKLE_COUNT = 26

DONUTS = {
    "p_coconut": ("#5B3A29", "#F7F1E8"),
    "p_strawberry_chocolate": ("#D9A066", "#F06A9B"),
    "p_glazed_classic": ("#D9A066", "#F4D9A6"),
    "p_choco_sprinkle": ("#C98B52", "#4A2C21"),
    "p_matcha_donut": ("#D9A066", "#8DBF6A"),
    "p_blueberry_donut": ("#D9A066", "#7C83E8"),
    "c_coco_donut": ("#D9A066", "#F28DB5"),
}
DRINKS = {
    "p_dalgona_coffee": ("#E9C9A0", "#8A5A3B"),
    "p_americano": ("#3B2418", "#6B4430"),
    "p_caramel_latte": ("#F0D2A8", "#B07445"),
    "c_americano": ("#3B2418", "#6B4430"),
}
BOXES = {
    "p_mistletoe_box": ("#2F7D5B", "#F06A9B"),
    "p_christmas_family_box": ("#C8323C", "#F4D9A6"),
    "p_santa_cookies": ("#C8323C", "#FFFFFF"),
}
BANNERS = {
    "b_central_boulevard": ("#6C5BD4", "#9A8CF0"),
    "b_hot_drinks": ("#56CFEA", "#9BE3F3"),
    "b_holiday_boxes": ("#F0559F", "#FF9CC8"),
}
SHOPS = {
    "s_downtown": ("#56CFEA", "#F0559F"),
    "s_junction": ("#FF7F22", "#56CFEA"),
    "s_inya_lake": ("#8DBF6A", "#FF7F22"),
    "s_hledan": ("#F0559F", "#6C5BD4"),
}
SPRINKLE_COLORS = ["#FFFFFF", "#56CFEA", "#FFD23F", "#8DBF6A", "#FF7F22"]


def _rgb(hex_color):
    value = hex_color.lstrip("#")
    return tuple(int(value[i : i + 2], 16) for i in (0, 2, 4))


def _canvas(size, background="#FFFFFF"):
    return Image.new("RGB", size, _rgb(background))


def _vertical_gradient(size, top, bottom):
    image = _canvas(size)
    draw = ImageDraw.Draw(image)
    top_rgb, bottom_rgb = _rgb(top), _rgb(bottom)
    for y in range(size[1]):
        t = y / max(size[1] - 1, 1)
        color = tuple(int(a + (b - a) * t) for a, b in zip(top_rgb, bottom_rgb))
        draw.line([(0, y), (size[0], y)], fill=color)
    return image


def _draw_donut(draw, center, radius, dough, glaze, rng):
    cx, cy = center
    draw.ellipse([cx - radius, cy - radius, cx + radius, cy + radius], fill=_rgb(dough))
    glaze_radius = radius * 0.9
    draw.ellipse(
        [cx - glaze_radius, cy - glaze_radius, cx + glaze_radius, cy + glaze_radius],
        fill=_rgb(glaze),
    )
    for _ in range(SPRINKLE_COUNT):
        angle = rng.uniform(0, math.tau)
        distance = rng.uniform(radius * 0.45, radius * 0.82)
        x = cx + math.cos(angle) * distance
        y = cy + math.sin(angle) * distance
        tilt = rng.uniform(0, math.tau)
        dx, dy = math.cos(tilt) * 7, math.sin(tilt) * 7
        draw.line([(x - dx, y - dy), (x + dx, y + dy)], fill=_rgb(rng.choice(SPRINKLE_COLORS)), width=4)
    hole = radius * 0.32
    draw.ellipse([cx - hole, cy - hole, cx + hole, cy + hole], fill=_rgb("#FFFFFF"))


def donut(name, dough, glaze):
    image = _canvas(PRODUCT_SIZE)
    draw = ImageDraw.Draw(image)
    _draw_donut(draw, (180, 180), 140, dough, glaze, random.Random(name))
    return image


def drink(name, foam, coffee):
    image = _canvas(PRODUCT_SIZE)
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle([110, 70, 250, 310], radius=28, fill=_rgb("#E8EEF0"))
    draw.rounded_rectangle([118, 150, 242, 302], radius=22, fill=_rgb(coffee))
    draw.rounded_rectangle([118, 96, 242, 160], radius=22, fill=_rgb(foam))
    return image


def gift_box(name, box, accent):
    image = _canvas(PRODUCT_SIZE, "#F5F7F8")
    draw = ImageDraw.Draw(image)
    draw.rounded_rectangle([50, 90, 310, 300], radius=24, fill=_rgb(box))
    rng = random.Random(name)
    for row in range(2):
        for col in range(3):
            _draw_donut(draw, (100 + col * 80, 150 + row * 90), 34, "#D9A066", accent, rng)
    return image


def banner(name, start, end):
    image = _vertical_gradient(BANNER_SIZE, start, end)
    draw = ImageDraw.Draw(image)
    rng = random.Random(name)
    for index in range(3):
        _draw_donut(draw, (420 + index * 70, 200 - index * 30), 60 - index * 8, "#D9A066", "#F06A9B", rng)
    return image


def shop(name, wall, awning):
    image = _vertical_gradient(SHOP_SIZE, "#DDF5FB", "#FFFFFF")
    draw = ImageDraw.Draw(image)
    draw.rectangle([80, 110, 400, 300], fill=_rgb(wall))
    for index in range(8):
        color = awning if index % 2 == 0 else "#FFFFFF"
        draw.rectangle([80 + index * 40, 90, 120 + index * 40, 130], fill=_rgb(color))
    draw.rectangle([200, 190, 280, 300], fill=_rgb("#FFFFFF"))
    return image


def avatar():
    image = _canvas(AVATAR_SIZE, "#FFE3D3")
    draw = ImageDraw.Draw(image)
    draw.ellipse([30, 40, 130, 150], fill=_rgb("#3B2418"))
    draw.ellipse([45, 45, 115, 125], fill=_rgb("#F2C7A5"))
    draw.ellipse([20, 120, 140, 220], fill=_rgb("#F0559F"))
    return image


def main():
    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    images = {name: donut(name, *colors) for name, colors in DONUTS.items()}
    images.update({name: drink(name, *colors) for name, colors in DRINKS.items()})
    images.update({name: gift_box(name, *colors) for name, colors in BOXES.items()})
    images.update({name: banner(name, *colors) for name, colors in BANNERS.items()})
    images.update({name: shop(name, *colors) for name, colors in SHOPS.items()})
    images["m_hania"] = avatar()
    for name, image in images.items():
        image.save(OUTPUT_DIR / f"{name}.webp", "WEBP", quality=WEBP_QUALITY, method=6)


if __name__ == "__main__":
    main()
