#!/usr/bin/env python3
"""
مولد صور الفئات بالحجم المناسب
Category Images Generator with Optimal Size

يمكن استخدام هذا الملف كدليل لإنشاء صور فئات جديدة بالمواصفات المطلوبة
"""

from PIL import Image, ImageDraw, ImageFont
import os

def create_sample_category_image(name, color, icon_text, size=(300, 300)):
    """إنشاء صورة فئة نموذجية بالحجم المناسب"""
    
    # إنشاء صورة جديدة بخلفية شفافة
    img = Image.new('RGBA', size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # رسم دائرة ملونة في المنتصف
    center = (size[0] // 2, size[1] // 2)
    radius = min(size) // 3
    
    # رسم ظل خفيف
    shadow_offset = 8
    draw.ellipse(
        [center[0] - radius + shadow_offset, center[1] - radius + shadow_offset,
         center[0] + radius + shadow_offset, center[1] + radius + shadow_offset],
        fill=(0, 0, 0, 30)
    )
    
    # رسم الدائرة الرئيسية
    draw.ellipse(
        [center[0] - radius, center[1] - radius,
         center[0] + radius, center[1] + radius],
        fill=color
    )
    
    # إضافة نص الأيقونة
    try:
        # محاولة استخدام خط النظام
        font_size = radius // 2
        font = ImageFont.truetype("/System/Library/Fonts/Arial.ttf", font_size)
    except:
        # في حالة عدم توفر الخط، استخدم الخط الافتراضي
        font = ImageFont.load_default()
    
    # حساب موضع النص
    text_bbox = draw.textbbox((0, 0), icon_text, font=font)
    text_width = text_bbox[2] - text_bbox[0]
    text_height = text_bbox[3] - text_bbox[1]
    text_x = center[0] - text_width // 2
    text_y = center[1] - text_height // 2
    
    # رسم النص
    draw.text((text_x, text_y), icon_text, fill=(255, 255, 255, 255), font=font)
    
    return img

def generate_sample_category_images():
    """إنشاء مجموعة من صور الفئات النموذجية"""
    
    categories = [
        {"name": "sample_restaurants", "color": (255, 107, 107, 255), "icon": "🍽️"},
        {"name": "sample_supermarket", "color": (0, 184, 148, 255), "icon": "🛒"},
        {"name": "sample_fast_food", "color": (78, 205, 196, 255), "icon": "🍔"},
        {"name": "sample_breakfast", "color": (69, 183, 209, 255), "icon": "☕"},
        {"name": "sample_grocery", "color": (150, 206, 180, 255), "icon": "🥬"},
    ]
    
    output_dir = "sample_category_images"
    os.makedirs(output_dir, exist_ok=True)
    
    print("🎨 إنشاء صور فئات نموذجية...")
    print(f"📁 مجلد الحفظ: {output_dir}")
    print("-" * 50)
    
    for category in categories:
        img = create_sample_category_image(
            category["name"], 
            category["color"], 
            category["icon"]
        )
        
        file_path = os.path.join(output_dir, f"{category['name']}.png")
        img.save(file_path, 'PNG', optimize=True, compress_level=6)
        
        file_size = os.path.getsize(file_path)
        print(f"✅ {category['name']}.png - {img.size[0]}×{img.size[1]}px - {file_size/1024:.1f}KB")
    
    print(f"\n🎉 تم إنشاء {len(categories)} صورة نموذجية!")

def get_optimal_image_specs():
    """عرض المواصفات المثلى لصور الفئات"""
    
    specs = {
        "الحجم المثالي": "300 × 300px",
        "الحد الأدنى": "200 × 200px", 
        "الحد الأقصى": "400 × 400px",
        "الصيغة": "PNG مع شفافية",
        "الدقة": "72-96 DPI",
        "حجم الملف المستهدف": "أقل من 50KB",
        "نسبة العرض للارتفاع": "1:1 (مربع)",
        "عمق الألوان": "32-bit (RGBA)",
        "الضغط": "مُحسن لـ PNG"
    }
    
    print("📋 المواصفات المثلى لصور الفئات:")
    print("=" * 40)
    
    for key, value in specs.items():
        print(f"{key:25}: {value}")
    
    print("\n💡 نصائح التصميم:")
    print("   • استخدم ألوان واضحة ومتباينة")
    print("   • تأكد من وضوح الأيقونة على خلفيات مختلفة")
    print("   • احتفظ بنسخة أصلية عالية الدقة للتعديلات المستقبلية") 
    print("   • اختبر الصور على أجهزة مختلفة")
    print("   • استخدم أدوات ضغط الصور لتقليل حجم الملف")

if __name__ == "__main__":
    print("🖼️  مولد صور الفئات بالحجم المناسب")
    print("=" * 50)
    
    print("الخيارات المتاحة:")
    print("1. عرض المواصفات المثلى")
    print("2. إنشاء صور نموذجية")
    print("3. الخروج")
    
    choice = input("\nاختر رقم الخيار: ")
    
    if choice == "1":
        get_optimal_image_specs()
    elif choice == "2":
        generate_sample_category_images()
    else:
        print("شكراً لاستخدام المولد!")
