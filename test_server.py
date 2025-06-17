#!/usr/bin/env python3
"""
خادم اختبار لتطبيق الطعام - معالجة أخطاء التسجيل
"""

from fastapi import FastAPI, HTTPException, status
from pydantic import BaseModel, EmailStr
from typing import Optional
import uvicorn
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Food App Test Server", version="1.0.0")

# إعداد CORS للسماح بالطلبات من التطبيق
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# نماذج البيانات
class UserRegister(BaseModel):
    name: str
    email: Optional[str] = None
    password: str
    phone: str

class UserLogin(BaseModel):
    identifier: str  # يمكن أن يكون بريد إلكتروني أو رقم هاتف
    password: str

# قاعدة بيانات وهمية للمستخدمين
fake_users_db = [
    {
        "id": "1",
        "name": "محمد أحمد",
        "email": "test@example.com",
        "phone": "0123456789",
        "password": "password123"
    },
    {
        "id": "2", 
        "name": "فاطمة علي",
        "email": "fatima@example.com",
        "phone": "0987654321",
        "password": "password456"
    }
]

@app.get("/")
async def root():
    return {"message": "Food App Test Server is running"}

@app.post("/register")
async def register_user(user: UserRegister):
    """تسجيل مستخدم جديد مع معالجة أخطاء الازدواج"""
    
    # التحقق من وجود البريد الإلكتروني مسبقاً
    if user.email:
        for existing_user in fake_users_db:
            if existing_user.get("email") == user.email:
                raise HTTPException(
                    status_code=status.HTTP_400_BAD_REQUEST,
                    detail="البريد الإلكتروني مسجل مسبقاً، يرجى استخدام بريد إلكتروني آخر"
                )
    
    # التحقق من وجود رقم الهاتف مسبقاً
    for existing_user in fake_users_db:
        if existing_user.get("phone") == user.phone:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="رقم الهاتف مسجل مسبقاً، يرجى استخدام رقم هاتف آخر"
            )
    
    # إنشاء مستخدم جديد
    new_user = {
        "id": str(len(fake_users_db) + 1),
        "name": user.name,
        "email": user.email,
        "phone": user.phone,
        "password": user.password
    }
    
    fake_users_db.append(new_user)
    
    return {
        "message": "تم إنشاء الحساب بنجاح",
        "user": {
            "id": new_user["id"],
            "name": new_user["name"],
            "email": new_user["email"],
            "phone": new_user["phone"]
        }
    }

@app.post("/login")
async def login_user(login_data: UserLogin):
    """تسجيل دخول المستخدم"""
    
    # البحث عن المستخدم بالبريد الإلكتروني أو رقم الهاتف
    user = None
    for existing_user in fake_users_db:
        if (existing_user.get("email") == login_data.identifier or 
            existing_user.get("phone") == login_data.identifier):
            user = existing_user
            break
    
    # التحقق من وجود المستخدم وكلمة المرور
    if not user or user.get("password") != login_data.password:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="البريد الإلكتروني أو رقم الهاتف أو كلمة المرور غير صحيحة"
        )
    
    return {
        "message": "تم تسجيل الدخول بنجاح",
        "data": {
            "user_id": user["id"],
            "user": {
                "name": user["name"],
                "email": user["email"],
                "phone": user["phone"]
            }
        }
    }

if __name__ == "__main__":
    print("🚀 بدء تشغيل خادم اختبار تطبيق الطعام...")
    print("📡 الخادم متاح على: http://127.0.0.1:8004")
    print("📚 الوثائق متاحة على: http://127.0.0.1:8004/docs")
    uvicorn.run(app, host="127.0.0.1", port=8004)
