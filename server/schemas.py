from pydantic import BaseModel, Field
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