from sqlalchemy.orm import relationship
from datetime import date,datetime

from database import Base
from sqlalchemy import (
    Column,
    Integer,
    String,
    Float,
    DateTime,
    ForeignKey,
    Date,
    Text,
    Boolean,
)

class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)

    firebase_uid = Column(
        String,
        unique=True,
        nullable=False,
        index=True,
    )

    email = Column(
        String,
        unique=True,
        nullable=False,
    )

    name = Column(
        String,
        nullable=True,
    )

    date_of_birth = Column(
        Date,
        nullable=True,
    )

    gender = Column(
        String,
        nullable=True,
    )

    created_at = Column(
        DateTime,
        default=datetime.utcnow,
    )

    health_records = relationship(
        "HealthRecord",
        back_populates="user",
        cascade="all, delete-orphan",
    )

    workouts = relationship(
        "Workout",
        back_populates="user",
        cascade="all, delete-orphan",
    )
    weight_logs = relationship(
    "WeightLog",
    cascade="all, delete-orphan",

    notifications = relationship(
    "Notification",
    back_populates="user",
    cascade="all, delete-orphan",
)
)

class Exercise(Base):
    __tablename__ = "exercises"

    id = Column(Integer, primary_key=True, index=True)
    workout_id = Column(
        Integer,
        ForeignKey("workouts.id"),
        nullable=False
    )

    name = Column(String, nullable=False)

    workout = relationship(
        "Workout",
        back_populates="exercises"
    )

    sets = relationship(
        "WorkoutSet",
        back_populates="exercise",
        cascade="all, delete-orphan"
    )

class WorkoutSet(Base):
    __tablename__ = "workout_sets"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    exercise_id = Column(
        Integer,
        ForeignKey("exercises.id"),
        nullable=False
    )

    set_number = Column(
        Integer,
        nullable=False
    )

    reps = Column(
        Integer,
        nullable=False
    )

    weight = Column(
        Float,
        nullable=True
    )

    exercise = relationship(
        "Exercise",
        back_populates="sets"
    )
class Workout(Base):
    __tablename__ = "workouts"

    id = Column(
        Integer,
        primary_key=True,
        index=True
    )

    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False
    )

    split = Column(
        String,
        nullable=False
    )

    workout_day = Column(
        String,
        nullable=False
    )

    workout_date = Column(
        Date,
        nullable=False
    )

    created_at = Column(
        DateTime,
        default=datetime.utcnow
    )

    user = relationship(
        "User",
        back_populates="workouts"
    )

    exercises = relationship(
        "Exercise",
        back_populates="workout",
        cascade="all, delete-orphan"
    )
class CalorieRecord(Base):
    __tablename__ = "calorie_records"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
    )

    age = Column(Integer, nullable=False)
    gender = Column(String, nullable=False)

    height_cm = Column(Float, nullable=False)
    weight_kg = Column(Float, nullable=False)

    activity_level = Column(String, nullable=False)
    goal = Column(String, nullable=False)

    bmr = Column(Float, nullable=False)
    maintenance_calories = Column(Float, nullable=False)
    target_calories = Column(Float, nullable=False)

    created_at = Column(
        DateTime,
        default=datetime.utcnow,
    )

    user = relationship("User")

class HealthRecord(Base):
    __tablename__ = "health_records"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
    )

    weight = Column(Float, nullable=False)

    height_cm = Column(Float, nullable=False)

    bmi = Column(Float, nullable=False)

    created_at = Column(
        DateTime,
        default=datetime.utcnow,
    )

    user = relationship(
        "User",
        back_populates="health_records",
    )

class WeightLog(Base):
    __tablename__ = "weight_logs"

    id = Column(
        Integer,
        primary_key=True,
        index=True,
    )

    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
    )

    weight = Column(
        Float,
        nullable=False,
    )

    notes = Column(
        String,
        nullable=True,
    )

    logged_at = Column(
        Date,
        nullable=False,
    )

    created_at = Column(
        DateTime,
        default=datetime.utcnow,
    )

    user = relationship("User")

class WaterLog(Base):
    __tablename__ = "water_logs"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(
        Integer,
        ForeignKey("users.id"),
        nullable=False,
    )

    amount_ml = Column(Integer, nullable=False)

    notes = Column(String, nullable=True)

    logged_at = Column(
        Date,
        default=date.today,
        nullable=False,
    )

    created_at = Column(
        DateTime,
        default=datetime.utcnow,
        nullable=False,
    )

    user = relationship("User")

class Notification(Base):
    __tablename__ = "notifications"

    id = Column(Integer, primary_key=True, index=True)

    user_id = Column(Integer, ForeignKey("users.id"))

    title = Column(String)
    message = Column(Text)
    type = Column(String)

    is_read = Column(Boolean, default=False)

    created_at = Column(DateTime, default=datetime.utcnow)

    user = relationship(
    "User",
    back_populates="notifications",
)