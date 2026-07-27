from PIL import Image, ImageDraw, ImageFont
import math
import random
import sys
from pathlib import Path

# Project root (this file is in <root>/scripts/)
_ASSETS_DIR = Path(__file__).resolve().parent.parent / "app" / "assets"

def create_gradient_icon(size=1024):
    """Create icon with gradient background (original style)"""
    
    img = Image.new('RGBA', (size, size), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)
    
    # Create gradient background (purple to blue)
    for y in range(size):
        r = int(98 + (46 * (1 - y / size)))
        g = int(0 + (138 * (y / size)))
        b = int(238 + (17 * (y / size)))
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    # Add subtle gradient overlay for depth
    for y in range(size):
        alpha = int(30 * (1 - y / size))
        draw.rectangle([(0, y), (size, y+1)], fill=(255,255,255, alpha))
    
    # Draw musical note in center
    center = size // 2
    note_radius = size // 6
    
    # Musical note (eighth note)
    draw.ellipse(
        [(center - note_radius, center + note_radius * 0.5),
         (center + note_radius, center + note_radius * 1.8)],
        fill=(255,255,255,255)
    )
    
    # Note stem
    stem_width = note_radius // 6
    draw.rectangle(
        [(center + note_radius - stem_width, center - note_radius * 0.5),
         (center + note_radius, center + note_radius * 0.5)],
        fill=(255,255,255,255)
    )
    
    # Note flag
    flag_points = [
        (center + note_radius, center - note_radius * 0.5),
        (center + note_radius * 2.5, center - note_radius * 0.8),
        (center + note_radius * 2.3, center - note_radius * 0.5),
        (center + note_radius, center - note_radius * 0.2)
    ]
    draw.polygon(flag_points, fill=(255,255,255,255))
    
    # Add decorative language elements (circles with letters)
    a_pos = (size // 4, size // 4)
    a_radius = size // 10
    draw.ellipse(
        [(a_pos[0] - a_radius, a_pos[1] - a_radius),
         (a_pos[0] + a_radius, a_pos[1] + a_radius)],
        fill=(255, 230, 0, 200)
    )
    
    cyril_pos = (size * 3 // 4, size // 4)
    draw.ellipse(
        [(cyril_pos[0] - a_radius, cyril_pos[1] - a_radius),
         (cyril_pos[0] + a_radius, cyril_pos[1] + a_radius)],
        fill=(255, 150, 0, 200)
    )
    
    greek_pos = (size // 4, size * 3 // 4)
    draw.ellipse(
        [(greek_pos[0] - a_radius, greek_pos[1] - a_radius),
         (greek_pos[0] + a_radius, greek_pos[1] + a_radius)],
        fill=(0, 200, 255, 200)
    )
    
    japan_pos = (size * 3 // 4, size * 3 // 4)
    draw.ellipse(
        [(japan_pos[0] - a_radius, japan_pos[1] - a_radius),
         (japan_pos[0] + a_radius, japan_pos[1] + a_radius)],
        fill=(100, 255, 150, 200)
    )
    
    # Add glow effect
    glow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    for i in range(5):
        glow_radius = note_radius * (2 + i * 0.5)
        glow_alpha = int(50 * (1 - i * 0.2))
        glow_draw.ellipse(
            [(center - glow_radius, center - glow_radius),
             (center + glow_radius, center + glow_radius)],
            fill=(255,255,255, glow_alpha)
        )
    
    img = Image.alpha_composite(img, glow)
    
    # Add "LT" text
    try:
        font = ImageFont.truetype("arial.ttf", size // 10)
    except Exception:
        font = ImageFont.load_default()
    
    text = "LT"
    bbox = draw.textbbox((0, 0), text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    
    draw.text(
        (size - text_width - 20, size - text_height - 20),
        text,
        fill=(255,255,255, 220),
        font=font
    )
    
    return img

def create_modern_icon(size=1024):
    """Create modern, clean icon"""
    
    img = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    center = size // 2
    
    # Gradient background - deep purple to violet
    for y in range(size):
        r = int((1 - y / size) * 50)
        g = int(30 + (y / size) * 40)
        b = int(60 + (y / size) * 80)
        draw.rectangle([(0, y), (size, y + 1)], fill=(r, g, b, 255))
    
    # Add subtle noise for texture
    for _ in range(size * size // 20):
        x = random.randint(0, size - 1)
        y = random.randint(0, size - 1)
        draw.point((x, y), fill=(255,255,255, 5))
    
    # Draw music note
    note_size = size // 4
    note_x = center - note_size // 2
    note_y = center
    
    # Note head with gradient
    for r in range(note_size, 0, -2):
        alpha = int(30 * (1 - r / note_size))
        draw.ellipse(
            [(note_x, note_y + r),
             (note_x + note_size * 0.9, note_y + r + note_size * 0.45)],
            fill=(255,255,255, alpha)
        )
    
    # Note stem
    stem_width = note_size // 8
    stem_height = note_size * 2.8
    
    draw.rectangle(
        [(note_x + note_size * 0.85 - stem_width, note_y - stem_height),
         (note_x + note_size * 0.85, note_y)],
        fill=(255,255,255, 255)
    )
    
    # Note flag
    flag_top = note_y - stem_height
    flag_points = [
        (note_x + note_size * 0.85, flag_top),
        (note_x + note_size * 1.1, flag_top + note_size * 0.5),
        (note_x + note_size * 0.95, flag_top + note_size * 0.3),
        (note_x + note_size * 0.85, flag_top + note_size * 0.5),
    ]
    draw.polygon(flag_points, fill=(255,255,255, 220))
    
    # Draw sound waves
    for i in range(3):
        wave_radius = note_size * (1.2 + i * 0.5)
        start_angle = -20 - i * 5
        end_angle = 200 + i * 5
        alpha = int(40 * (1 - i * 0.3))
        
        draw.arc(
            [(center - wave_radius, center - wave_radius),
             (center + wave_radius, center + wave_radius)],
            start=start_angle,
            end=end_angle,
            fill=(255,255,255, alpha),
            width=4
        )
    
    # Draw "LT" logo
    logo_size = size // 6
    logo_x = center - logo_size // 2
    logo_y = center + note_size * 0.6
    
    try:
        font_size = int(logo_size * 1.5)
        font = ImageFont.truetype("arial.ttf", font_size)
    except Exception:
        font = None
    
    if font:
        bbox = draw.textbbox((0, 0), "LT", font=font)
        text_width = bbox[2] - bbox[0]
        text_height = bbox[3] - bbox[1]
        
        draw.text(
            (logo_x - text_width // 2, logo_y - text_height // 2),
            "LT",
            font=font,
            fill=(255,255,255, 255)
        )
        
        # Add accent line under "LT"
        draw.line(
            [(logo_x - text_width // 2, logo_y + text_height // 2 + 5),
             (logo_x + text_width // 2, logo_y + text_height // 2 + 5)],
            fill=(100, 150, 255, 200),
            width=3
        )
    
    return img

def create_original_icon(size=1024):
    """Create original, creative icon with orbiting letters"""
    
    img = Image.new('RGBA', (size, size), (0, 0, 0, 255))
    draw = ImageDraw.Draw(img)
    center = size // 2
    
    # Dynamic gradient - purple to blue to teal
    for y in range(size):
        progress = y / size
        if progress < 0.5:
            p = progress * 2
            r = int(98 + (0 - 98) * p)
            g = int(0 + (100 - 0) * p)
            b = int(238 + (238 - 238) * p)
        else:
            p = (progress - 0.5) * 2
            r = int(0 + (20 - 0) * p)
            g = int(100 + (200 - 100) * p)
            b = int(238 + (220 - 238) * p)
        
        draw.line([(0, y), (size, y)], fill=(r, g, b, 255))
    
    # Add subtle diagonal stripe pattern
    for i in range(-size, size * 2, 80):
        draw.line([(i, 0), (i + size, size)], fill=(255,255,255, 8), width=1)
    
    # Musical note with glow
    note_radius = size // 7
    note_x = center - note_radius // 2
    note_y = center + note_radius // 2
    
    glow = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    glow_draw = ImageDraw.Draw(glow)
    
    for i in range(8):
        glow_radius = note_radius * (1.2 + i * 0.15)
        glow_alpha = int(40 * (1 - i * 0.12))
        glow_draw.ellipse(
            [(center - glow_radius, center - glow_radius),
             (center + glow_radius, center + glow_radius)],
            fill=(255,255,255, glow_alpha)
        )
    
    img = Image.alpha_composite(img, glow)
    
    # Note head
    draw.ellipse(
        [(note_x - note_radius, note_y - note_radius * 0.3),
         (note_x + note_radius * 1.2, note_y + note_radius * 0.3)],
        fill=(255,255,255, 255)
    )
    
    # Note stem
    stem_width = note_radius // 5
    stem_height = note_radius * 3.5
    stem_top = note_y - note_radius - stem_height
    
    draw.rounded_rectangle(
        [(note_x + note_radius - stem_width, stem_top),
         (note_x + note_radius + stem_width, note_y - note_radius)],
        radius=stem_width // 2,
        fill=(255,255,255, 240)
    )
    
    # Note flag
    flag_points = [
        (note_x + note_radius, stem_top),
        (note_x + note_radius * 2.8, stem_top + note_radius * 0.8),
        (note_x + note_radius * 2.5, stem_top + note_radius * 0.5),
        (note_x + note_radius, stem_top + note_radius * 0.3)
    ]
    flag_points_clean = [(int(x), int(y)) for x, y in flag_points]
    draw.polygon(flag_points_clean, fill=(255,255,255, 220))
    
    # Language letters orbiting
    letters = [
        ('A', (255, 215, 0)),      # Latin - Gold
        ('А', (255, 107, 53)),     # Cyrillic - Orange
        ('Ω', (78, 205, 196)),     # Greek - Teal
        ('あ', (255, 107, 157)),   # Japanese - Pink
        ('ه', (149, 225, 211)),   # Arabic - Mint
    ]
    
    orbit_radius = note_radius * 2.2
    letter_size = note_radius // 2
    
    for i, (letter, color) in enumerate(letters):
        angle = (2 * math.pi * i / len(letters)) - math.pi / 2
        x = center + orbit_radius * math.cos(angle)
        y = center + orbit_radius * math.sin(angle)
        
        # Circle
        circle_radius = letter_size * 1.5
        draw.ellipse(
            [(x - circle_radius, y - circle_radius),
             (x + circle_radius, y + circle_radius)],
            fill=color + (220,)
        )
        
        # Letter
        try:
            font = ImageFont.truetype("arial.ttf", letter_size)
            bbox = draw.textbbox((0, 0), letter, font=font)
            text_width = bbox[2] - bbox[0]
            text_height = bbox[3] - bbox[1]
            
            draw.text(
                (x - text_width // 2, y - text_height // 2),
                letter,
                fill=(255,255,255, 255),
                font=font
            )
        except Exception:
            pass
    
    # Draw sound waves
    for i in range(4):
        wave_radius = note_radius * (1.8 + i * 0.5)
        wave_alpha = int(80 * (1 - i * 0.25))
        
        for angle in range(0, 360, 6):
            rad = math.radians(angle)
            wave_x = center + wave_radius * math.cos(rad)
            wave_y = center + wave_radius * math.sin(rad)
            
            if angle % 18 == 0:
                draw.ellipse(
                    [(wave_x - 5, wave_y - 5), (wave_x + 5, wave_y + 5)],
                    fill=(255,255,255, wave_alpha)
                )
            else:
                draw.ellipse(
                    [(wave_x - 2, wave_y - 2), (wave_x + 2, wave_y + 2)],
                    fill=(255,255,255, wave_alpha // 2)
                )
    
    # Connecting lines between letters
    for i in range(len(letters)):
        angle1 = (2 * math.pi * i / len(letters)) - math.pi / 2
        angle2 = (2 * math.pi * ((i + 1) % len(letters)) / len(letters)) - math.pi / 2
        
        x1 = center + orbit_radius * 0.7 * math.cos(angle1)
        y1 = center + orbit_radius * 0.7 * math.sin(angle1)
        x2 = center + orbit_radius * 0.7 * math.cos(angle2)
        y2 = center + orbit_radius * 0.7 * math.sin(angle2)
        
        draw.line(
            [(x1, y1), (x2, y2)],
            fill=(255,255,255, 40),
            width=2
        )
    
    return img

def create_all_sizes(style='gradient'):
    """Create icon in multiple sizes"""
    sizes = [1024, 512, 192, 144, 96, 72, 48, 36]
    
    # Select style function
    style_functions = {
        'gradient': create_gradient_icon,
        'modern': create_modern_icon,
        'original': create_original_icon,
    }
    
    create_func = style_functions.get(style, create_gradient_icon)
    
    for size in sizes:
        print(f'Creating {size}x{size} icon ({style} style)...')
        icon = create_func(size)
        
        output_path = _ASSETS_DIR / 'icon.png' if size == 1024 else _ASSETS_DIR / f'icon_{size}x{size}.png'
        icon.save(output_path, 'PNG')
        print(f'  Saved: {output_path}')

def main():
    """Main function to show menu and create icons"""
    print('🎨 LingoTune Icon Generator')
    print('=' * 50)
    print()
    print('Available styles:')
    print('  1. Gradient (classic with language circles)')
    print('  2. Modern (clean, minimalist design)')
    print('  3. Original (creative with orbiting letters)')
    print('  4. All styles')
    print()
    
    choice = input('Select style (1-4) [default: 1]: ').strip() or '1'
    
    styles = {
        '1': 'gradient',
        '2': 'modern',
        '3': 'original',
        '4': 'all',
    }
    
    style = styles.get(choice, 'gradient')
    
    if style == 'all':
        print()
        print('Creating all styles...')
        for s in ['gradient', 'modern', 'original']:
            print()
            print(f'Creating {s} style...')
            print('-' * 50)
            create_all_sizes(style)
            print('-' * 50)
    else:
        create_all_sizes(style)
    
    print()
    print('=' * 50)
    print('✅ Icon creation completed!')
    print()

if __name__ == '__main__':
    main()
