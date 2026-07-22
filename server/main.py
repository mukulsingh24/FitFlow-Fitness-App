from fastapi import FastAPI, Depends, HTTPException
from sqlalchemy.orm import Session

from database import Base, engine, get_db
from auth import verify_firebase_token
from models import User, HealthRecord
from schemas import BMICreate

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

    # Find user
    user = (
        db.query(User)
        .filter(User.firebase_uid == firebase_uid)
        .first()
    )

    # Create user if not found
    if user is None:
        user = User(
            firebase_uid=firebase_uid,
            email=email,
            name=name,
        )

        db.add(user)
        db.commit()
        db.refresh(user)

    # Calculate BMI
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