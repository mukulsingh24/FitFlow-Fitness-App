from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session

from database import Base, engine, get_db
from auth import verify_firebase_token
from models import User, HealthRecord, CalorieRecord
from schemas import BMICreate, CalorieCreate

import models
Base.metadata.create_all(bind=engine)
app = FastAPI(
    title="FitFlow API",
    version="1.0.0",
)

@app.get("/")
def root():
    return {
        "message": "FitFlow API is running"
    }


@app.get("/health")
def health_check():
    return {
        "status": "healthy"
    }

@app.get("/me")
def get_current_user(
    firebase_user=Depends(verify_firebase_token),
    db: Session = Depends(get_db),
):
    firebase_uid = firebase_user.get("uid")
    email = firebase_user.get("email")
    name = firebase_user.get("name")

    user = (
        db.query(User)
        .filter(User.firebase_uid == firebase_uid)
        .first()
    )

    if user is None:
        user = User(
            firebase_uid=firebase_uid,
            email=email,
            name=name,
        )

        db.add(user)
        db.commit()
        db.refresh(user)

    return {
        "id": user.id,
        "firebase_uid": user.firebase_uid,
        "email": user.email,
        "name": user.name,
        "created_at": user.created_at,
    }

@app.post("/health/bmi")
def save_bmi(
    bmi_data: BMICreate,
    firebase_user=Depends(verify_firebase_token),
    db: Session = Depends(get_db),
):
    firebase_uid = firebase_user.get("uid")
    email = firebase_user.get("email")
    name = firebase_user.get("name")

    user = (
        db.query(User)
        .filter(User.firebase_uid == firebase_uid)
        .first()
    )

    if user is None:
        user = User(
            firebase_uid=firebase_uid,
            email=email,
            name=name,
        )

        db.add(user)
        db.commit()
        db.refresh(user)

    height_m = bmi_data.height_cm / 100

    bmi = round(
        bmi_data.weight / (height_m ** 2),
        2,
    )

    if bmi < 18.5:
        category = "Underweight"
    elif bmi < 25:
        category = "Normal"
    elif bmi < 30:
        category = "Overweight"
    else:
        category = "Obese"

    # Save health record
    health_record = HealthRecord(
        user_id=user.id,
        weight=bmi_data.weight,
        height_cm=bmi_data.height_cm,
        bmi=bmi,
    )

    db.add(health_record)
    db.commit()
    db.refresh(health_record)

    return {
        "id": health_record.id,
        "weight": health_record.weight,
        "height_cm": health_record.height_cm,
        "bmi": health_record.bmi,
        "category": category,
        "created_at": health_record.created_at,
    }
@app.get("/health/bmi")
def get_bmi_history(
    firebase_user=Depends(verify_firebase_token),
    db: Session = Depends(get_db),
):
    firebase_uid = firebase_user.get("uid")

    user = (
        db.query(User)
        .filter(User.firebase_uid == firebase_uid)
        .first()
    )

    if user is None:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    records = (
        db.query(HealthRecord)
        .filter(
            HealthRecord.user_id == user.id,
            HealthRecord.bmi.isnot(None),
        )
        .order_by(HealthRecord.created_at.desc())
        .all()
    )

    return [
        {
            "id": record.id,
            "weight": record.weight,
            "height_cm": record.height_cm,
            "bmi": record.bmi,
            "created_at": record.created_at,
        }
        for record in records
    ]

@app.post("/health/calories")
def save_calories(
    calorie_data: CalorieCreate,
    firebase_user=Depends(verify_firebase_token),
    db: Session = Depends(get_db),
):
    firebase_uid = firebase_user.get("uid")

    user = (
        db.query(User)
        .filter(User.firebase_uid == firebase_uid)
        .first()
    )

    if user is None:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    if calorie_data.gender.lower() == "male":
        bmr = (
            (10 * calorie_data.weight_kg)
            + (6.25 * calorie_data.height_cm)
            - (5 * calorie_data.age)
            + 5
        )
    else:
        bmr = (
            (10 * calorie_data.weight_kg)
            + (6.25 * calorie_data.height_cm)
            - (5 * calorie_data.age)
            - 161
        )

    activity_multipliers = {
        "Sedentary": 1.2,
        "Lightly Active": 1.375,
        "Moderately Active": 1.55,
        "Very Active": 1.725,
        "Extra Active": 1.9,
    }

    multiplier = activity_multipliers.get(
        calorie_data.activity_level,
        1.2,
    )

    maintenance_calories = bmr * multiplier

    target_calories = maintenance_calories

    if calorie_data.goal == "Lose Weight":
        target_calories -= 500

    elif calorie_data.goal == "Gain Weight":
        target_calories += 500

    if target_calories < 1200:
        target_calories = 1200

    record = CalorieRecord(
        user_id=user.id,
        age=calorie_data.age,
        gender=calorie_data.gender,
        height_cm=calorie_data.height_cm,
        weight_kg=calorie_data.weight_kg,
        activity_level=calorie_data.activity_level,
        goal=calorie_data.goal,
        bmr=round(bmr, 2),
        maintenance_calories=round(
            maintenance_calories,
            2,
        ),
        target_calories=round(
            target_calories,
            2,
        ),
    )

    db.add(record)
    db.commit()
    db.refresh(record)

    return {
        "id": record.id,
        "age": record.age,
        "gender": record.gender,
        "height_cm": record.height_cm,
        "weight_kg": record.weight_kg,
        "activity_level": record.activity_level,
        "goal": record.goal,
        "bmr": record.bmr,
        "maintenance_calories": record.maintenance_calories,
        "target_calories": record.target_calories,
        "created_at": record.created_at,
    }

@app.get("/health/calories")
def get_calorie_history(
    firebase_user=Depends(verify_firebase_token),
    db: Session = Depends(get_db),
):
    firebase_uid = firebase_user.get("uid")

    user = (
        db.query(User)
        .filter(User.firebase_uid == firebase_uid)
        .first()
    )

    if user is None:
        raise HTTPException(
            status_code=404,
            detail="User not found",
        )

    records = (
        db.query(CalorieRecord)
        .filter(CalorieRecord.user_id == user.id)
        .order_by(CalorieRecord.created_at.desc())
        .all()
    )

    return [
        {
            "id": record.id,
            "age": record.age,
            "gender": record.gender,
            "height_cm": record.height_cm,
            "weight_kg": record.weight_kg,
            "activity_level": record.activity_level,
            "goal": record.goal,
            "bmr": record.bmr,
            "maintenance_calories": record.maintenance_calories,
            "target_calories": record.target_calories,
            "created_at": record.created_at,
        }
        for record in records
    ]