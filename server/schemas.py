from pydantic import BaseModel, Field
from pydantic import BaseModel, Field
from typing import List
class BMICreate(BaseModel):
    weight: float = Field(gt=0)
    height_cm: float = Field(gt=0)


class BMIResponse(BaseModel):
    id: int
    weight: float
    height_cm: float
    bmi: float
    category: str

class CalorieCreate(BaseModel):
    age: int
    gender: str
    height_cm: float
    weight_kg: float
    activity_level: str
    goal: str

class WorkoutExerciseCreate(BaseModel):
    name: str = Field(
        ...,
        min_length=1,
        max_length=100
    )

    sets: int = Field(
        ...,
        ge=1,
        le=20
    )

    reps: int = Field(
        ...,
        ge=1,
        le=100
    )

    working_weight: float = Field(
        default=0,
        ge=0,
        le=500
    )


class WorkoutCreate(BaseModel):
    split: str = Field(
        ...,
        min_length=1,
        max_length=100
    )

    workout_day: str = Field(
        ...,
        min_length=1,
        max_length=50
    )

    exercises: List[WorkoutExerciseCreate]