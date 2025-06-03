#!/usr/bin/env python3
import os
import subprocess
import sys

def convert_svg_to_png():
    icons_dir = "/Users/malwersh/foodapp_user/assets/icons"
    os.chdir(icons_dir)
    
    svg_files = [f for f in os.listdir('.') if f.endswith('.svg')]
    
    for svg_file in svg_files:
        png_file = svg_file.replace('.svg', '.png')
        
        print(f"Converting {svg_file} to {png_file}")
        
        # Try different conversion methods
        success = False
        
        # Method 1: Use qlmanage (available on macOS)
        try:
            cmd = ['qlmanage', '-t', '-s', '200', '-o', '.', svg_file]
            result = subprocess.run(cmd, capture_output=True, text=True)
            if result.returncode == 0:
                # qlmanage creates filename.svg.png, rename it
                temp_name = f"{svg_file}.png"
                if os.path.exists(temp_name):
                    if os.path.exists(png_file):
                        os.remove(png_file)
                    os.rename(temp_name, png_file)
                    success = True
                    print(f"✓ Converted {svg_file} using qlmanage")
        except Exception as e:
            print(f"qlmanage failed for {svg_file}: {e}")
        
        # Method 2: Try with sips (macOS built-in)
        if not success:
            try:
                cmd = ['sips', '-s', 'format', 'png', '-Z', '200', svg_file, '--out', png_file]
                result = subprocess.run(cmd, capture_output=True, text=True)
                if result.returncode == 0:
                    success = True
                    print(f"✓ Converted {svg_file} using sips")
            except Exception as e:
                print(f"sips failed for {svg_file}: {e}")
        
        if not success:
            print(f"✗ Failed to convert {svg_file}")

if __name__ == "__main__":
    convert_svg_to_png()
