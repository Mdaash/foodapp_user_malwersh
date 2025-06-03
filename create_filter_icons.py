#!/usr/bin/env python3
"""
إنشاء أيقونات الفلاتر للتطبيق
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_filter_icon(filename, icon_char, color):
    """إنشاء أيقونة فلتر بسيطة"""
    size = 64
    img = Image.new('RGBA', (size, size), (255, 255, 255, 0))
    draw = ImageDraw.Draw(img)
    
    # رسم دائرة ملونة
    circle_size = size - 10
    draw.ellipse([5, 5, circle_size + 5, circle_size + 5], 
                 fill=color, outline=None)
    
    # إضافة النص/الرمز
    try:
        font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", 30)
    except:
        font = ImageFont.load_default()
    
    # حساب موضع النص ليكون في المنتصف
    bbox = draw.textbbox((0, 0), icon_char, font=font)
    text_width = bbox[2] - bbox[0]
    text_height = bbox[3] - bbox[1]
    x = (size - text_width) // 2
    y = (size - text_height) // 2 - 5
    
    draw.text((x, y), icon_char, fill=(255, 255, 255), font=font)
    
    return img

def main():
    # إنشاء مجلد الأيقونات إذا لم يكن موجوداً
    icons_dir = "assets/icons"
    os.makedirs(icons_dir, exist_ok=True)
    
    # تعريف الأيقونات المطلوبة
    icons = {
        'fast_delivery.png': ('⚡', (52, 168, 232)),      # أزرق للتوصيل السريع
        'delivery_fee.png': ('💰', (34, 197, 94)),       # أخضر للرسوم
        'pickup.png': ('🏪', (245, 158, 11)),            # برتقالي للاستلام
        'open_now.png': ('🕐', (16, 185, 129)),          # أخضر فاتح للمفتوح
        'discount.png': ('%', (239, 68, 68)),            # أحمر للخصومات
    }
    
    # إنشاء كل أيقونة
    for filename, (icon_char, color) in icons.items():
        icon = create_filter_icon(filename, icon_char, color)
        filepath = os.path.join(icons_dir, filename)
        icon.save(filepath, 'PNG')
        print(f"تم إنشاء {filepath}")
    
    print("تم إنشاء جميع أيقونات الفلاتر بنجاح!")

if __name__ == "__main__":
    main()
