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