#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont
import os

def create_category_icon(filename, bg_color, icon_text, text_color='white'):
    """Create a simple category icon with text"""
    size = (200, 200)
    img = Image.new('RGBA', size, bg_color)
    draw = ImageDraw.Draw(img)
    
    # Try to use a system font
    try:
        font = ImageFont.truetype('/System/Library/Fonts/Arial.ttf', 40)
    except:
        font = ImageFont.load_default()
    
    # Calculate text position to center it
    bbox = draw.textbbox((0, 0), icon_text, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size[0] - text_width) // 2
    y = (size[1] - text_height) // 2
    
    # Draw text
    draw.text((x, y), icon_text, fill=text_color, font=font)
    
    # Add a circle border
    draw.ellipse([10, 10, size[0]-10, size[1]-10], outline='white', width=5)
    
    # Save the image
    icons_dir = "/Users/malwersh/foodapp_user/assets/icons"
    filepath = os.path.join(icons_dir, filename)
    img.save(filepath)
    print(f"Created {filename}")

def main():
    # Create category icons with attractive colors and emojis/text
    categories = [
        ('restaurant_category.png', '#ff6b35', '🍽️', 'white'),
        ('fast_food_category.png', '#ffc107', '🍔', 'white'),
        ('breakfast_category.png', '#ff9800', '🥞', 'white'),
        ('grocery_category.png', '#4caf50', '🛒', 'white'),
        ('meat_category.png', '#d32f2f', '🥩', 'white'),
        ('desserts_category.png', '#e91e63', '🍰', 'white'),
        ('vegetables_category.png', '#8bc34a', '🥕', 'white'),
        ('beverages_category.png', '#2196f3', '🥤', 'white'),
        ('supermarket_category.png', '#9c27b0', '🏪', 'white'),
    ]
    
    for filename, bg_color, icon_text, text_color in categories:
        create_category_icon(filename, bg_color, icon_text, text_color)

if __name__ == "__main__":
    main()
