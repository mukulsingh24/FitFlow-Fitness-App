import firebase_admin

from firebase_admin import credentials, auth
from fastapi import Header, HTTPException


if not firebase_admin._apps:
    cred = credentials.Certificate(
        "firebase-service-account.json"
    )
    firebase_admin.initialize_app(cred)


async def verify_firebase_token(
    authorization: str = Header(None)
):
    if authorization is None:
        raise HTTPException(
            status_code=401,
            detail="Authorization header missing"
        )

    if not authorization.startswith("Bearer "):
        raise HTTPException(
            status_code=401,
            detail="Invalid authorization header"
        )

    token = authorization.split("Bearer ")[1]

    try:
        decoded_token = auth.verify_id_token(token)

        return decoded_token

    except Exception:
        raise HTTPException(
            status_code=401,
            detail="Invalid or expired Firebase token"
        )