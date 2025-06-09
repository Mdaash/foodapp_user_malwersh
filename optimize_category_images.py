#!/usr/bin/env python3
"""
أداة تحسين صور الفئات
Category Images Optimization Tool

هذه الأداة تساعد في:
1. تحسين أحجام صور الفئات إلى 300×300px
2. ضغط الصور لتقليل حجم الملف
3. التأكد من جودة الصور
"""

import os
from PIL import Image
import sys

def optimize_category_images():
    """تحسين جميع صور الفئات"""
    
    # مجلد الصور
    icons_dir = "assets/icons"
    
    if not os.path.exists(icons_dir):
        print(f"❌ مجلد الصور غير موجود: {icons_dir}")
        return
    
    # قائمة صور الفئات المطلوب تحسينها
    category_images = [
        "cat_rest.png",
        "cat_supermarket.png", 
        "cat_fast.png",
        "cat_break.png",
        "cat_groce.png",
        "cat_meat.png",
        "cat_dessert.png",
        "cat_juice.png",
        "cat_flowers.png",
        "cat_other.png"
    ]
    
    optimized_count = 0
    target_size = (300, 300)
    
    print("🚀 بدء تحسين صور الفئات...")
    print(f"📏 الحجم المستهدف: {target_size[0]}×{target_size[1]}px")
    print("-" * 50)
    
    for image_name in category_images:
        image_path = os.path.join(icons_dir, image_name)
        
        if not os.path.exists(image_path):
            print(f"⚠️  الصورة غير موجودة: {image_name}")
            continue
        
        try:
            # فتح الصورة
            with Image.open(image_path) as img:
                original_size = img.size
                original_file_size = os.path.getsize(image_path)
                
                print(f"📸 {image_name}")
                print(f"   الحجم الأصلي: {original_size[0]}×{original_size[1]}px")
                print(f"   حجم الملف الأصلي: {original_file_size/1024:.1f}KB")
                
                # تحسين الحجم إذا كان مختلف عن المستهدف
                if img.size != target_size:
                    # تغيير الحجم مع الحفاظ على الجودة
                    img_resized = img.resize(target_size, Image.Resampling.LANCZOS)
                    
                    # حفظ الصورة المحسنة
                    if img.mode == 'RGBA':
                        img_resized.save(image_path, 'PNG', optimize=True, compress_level=6)
                    else:
                        img_resized = img_resized.convert('RGBA')
                        img_resized.save(image_path, 'PNG', optimize=True, compress_level=6)
                    
                    # قياس الحجم الجديد
                    new_file_size = os.path.getsize(image_path)
                    
                    print(f"   ✅ تم التحسين إلى: {target_size[0]}×{target_size[1]}px")
                    print(f"   📦 حجم الملف الجديد: {new_file_size/1024:.1f}KB")
                    
                    if new_file_size < original_file_size:
                        savings = ((original_file_size - new_file_size) / original_file_size) * 100
                        print(f"   💾 توفير: {savings:.1f}%")
                    
                    optimized_count += 1
                else:
                    print(f"   ✅ الحجم مثالي بالفعل")
                
                print("-" * 30)
                
        except Exception as e:
            print(f"❌ خطأ في معالجة {image_name}: {str(e)}")
            continue
    
    print(f"🎉 تم الانتهاء!")
    print(f"📊 تم تحسين {optimized_count} صورة من أصل {len(category_images)}")
    
    if optimized_count > 0:
        print("\n💡 التوصيات:")
        print("   • اختبر التطبيق للتأكد من وضوح الصور")
        print("   • تحقق من أن الصور تظهر بشكل صحيح على أجهزة مختلفة")
        print("   • في حالة عدم الرضا عن الجودة، يمكن زيادة الحجم إلى 400×400px")

def check_images_info():
    """عرض معلومات الصور الحالية"""
    icons_dir = "assets/icons"
    category_images = [
        "cat_rest.png", "cat_supermarket.png", "cat_fast.png",
        "cat_break.png", "cat_groce.png", "cat_meat.png",
        "cat_dessert.png", "cat_juice.png", "cat_flowers.png", "cat_other.png"
    ]
    
    print("📋 معلومات صور الفئات الحالية:")
    print("-" * 60)
    
    for image_name in category_images:
        image_path = os.path.join(icons_dir, image_name)
        
        if os.path.exists(image_path):
            try:
                with Image.open(image_path) as img:
                    file_size = os.path.getsize(image_path)
                    print(f"{image_name:20} | {img.size[0]:4}×{img.size[1]:4}px | {file_size/1024:6.1f}KB | {img.mode}")
            except:
                print(f"{image_name:20} | خطأ في قراءة الملف")
        else:
            print(f"{image_name:20} | غير موجود")

if __name__ == "__main__":
    print("🖼️  أداة تحسين صور الفئات")
    print("=" * 50)
    
    if len(sys.argv) > 1 and sys.argv[1] == "info":
        check_images_info()
    else:
        # عرض معلومات الصور أولاً
        check_images_info()
        print("\n")
        
        # استمرار في التحسين
        response = input("هل تريد المتابعة مع تحسين الصور؟ (y/n): ")
        if response.lower() in ['y', 'yes', 'نعم']:
            optimize_category_images()
        else:
            print("تم إلغاء العملية.")
