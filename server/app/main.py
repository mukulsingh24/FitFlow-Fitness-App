from fastapi import FastAPI

app = FastAPI(
    title="FitFlow API",
    version="1.0.0"
)

@app.get("/")
def home():
    return {"message": "FitFlow API is running 🚀"}