#!/usr/bin/env python3
"""
Script to fix common Flutter issues:
1. Replace withOpacity with withValues
2. Replace print with debugPrint
3. Fix unnecessary const keywords
4. Fix curly braces in flow control structures
"""

import os
import re

def fix_file(file_path):
    """Fix issues in a single file"""
    try:
        with open(file_path, 'r', encoding='utf-8') as f:
            content = f.read()
        
        original_content = content
        
        # Fix 1: Replace withOpacity with withValues
        content = re.sub(r'\.withOpacity\(([^)]+)\)', r'.withValues(alpha: \1)', content)
        
        # Fix 2: Replace print with debugPrint (but not in test files)
        if not file_path.endswith('_test.dart') and '/test/' not in file_path:
            content = re.sub(r'\bprint\(', 'debugPrint(', content)
        
        # Fix 3: Remove unnecessary const
        content = re.sub(r'const\s+const\s+', 'const ', content)
        
        # Fix 4: Add curly braces to if statements without blocks
        # This is more complex, so we'll handle specific patterns
        lines = content.split('\n')
        for i, line in enumerate(lines):
            # Look for if statements without braces
            if re.match(r'^(\s*)if\s*\([^)]+\)\s*([^{;]+);?\s*$', line):
                indent = re.match(r'^(\s*)', line).group(1)
                condition = re.search(r'if\s*\([^)]+\)', line).group(0)
                statement = line[line.find(')') + 1:].strip()
                if statement and not statement.startswith('{'):
                    lines[i] = f"{indent}{condition} {{"
                    lines.insert(i + 1, f"{indent}  {statement}")
                    lines.insert(i + 2, f"{indent}}}")
        
        content = '\n'.join(lines)
        
        # Only write if content changed
        if content != original_content:
            with open(file_path, 'w', encoding='utf-8') as f:
                f.write(content)
            print(f"Fixed: {file_path}")
            return True
        return False
        
    except Exception as e:
        print(f"Error processing {file_path}: {e}")
        return False

def main():
    """Main function to process all Dart files"""
    lib_dir = "/Users/malwersh/foodapp_user/lib"
    test_dir = "/Users/malwersh/foodapp_user/test"
    
    fixed_files = 0
    
    # Process lib directory
    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                if fix_file(file_path):
                    fixed_files += 1
    
    # Process test directory
    for root, dirs, files in os.walk(test_dir):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                if fix_file(file_path):
                    fixed_files += 1
    
    print(f"\nFixed {fixed_files} files total")

if __name__ == "__main__":
    main()
