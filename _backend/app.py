"""
vscodium is shit
"""
import json
import httpx
import os
from fastapi import FastAPI, Depends
from pydantic import BaseModel
from typing import List, Optional
import sqlite3
from datetime import datetime, timedelta
import jwt
from fastapi import HTTPException
import psycopg2

app = FastAPI()

SECRET_KEY = ""
ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 30

class Schedule(BaseModel):
    id: str = None
    name: str = None
    peopleOnShift: list = None
    startDate: int = None
    endDate: int = None
    autoPick: bool = None
    style: str = None

class CodableColor(BaseModel):
    red: float
    blue: float
    green: float

class SleepData(BaseModel):
    date: int
    bloodOxygen: float
    heartRate: float
    respirationRate: float
    decibels: float

# Represents the PersonCodable struct in Swift
class PersonCodable(BaseModel):
    name: Optional[str] = None
    color: Optional[CodableColor] = None
    imageData: Optional[bytes] = None
    emoji: Optional[str] = None
    userID: Optional[str] = None
    pushToken: Optional[str] = None
    sleepData: Optional[List["SleepData"]] = None  # Forward reference for recursive model

    # Methods for handling UIImage can be added here if necessary.


def get_connection():
    return psycopg2.connect(
        host=os.environ.get("CLOUD_SQL_INSTANCE_IP"),
        user=os.environ.get("DB_USERNAME"),
        password=os.environ.get("DB_PASSWORD"),
        dbname=os.environ.get("DB_NAME")
    )


def get_sleep_stage(heartrate: float, avg_heartrate: float, respiration_rate: float, avg_respiration_rate: float) -> str:
    if heartrate > avg_heartrate + 6 and respiration_rate > avg_respiration_rate + 3:
        return "light"
    else:
        return "deep"

class User(BaseModel):
    username: str
    password: str

# Create an SQLite database and a table
def create_db():
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute('''
        CREATE TABLE IF NOT EXISTS schedules (
            id TEXT PRIMARY KEY,
            name TEXT,
            peopleOnShift TEXT,
            startDate INTEGER,
            endDate INTEGER,
            autoPick INTEGER,
            style TEXT
        )          
    ''')
    conn.execute('''
                 CREATE TABLE IF NOT EXISTS profiles (
            id TEXT PRIMARY KEY,
            name TEXT,
            color TEXT,
            imageData BLOB,
            emoji TEXT,
            userID TEXT,
            pushToken TEXT,
            sleepData TEXT
        )
                 ''')
    conn.commit()
    conn.close()


"""
What 

"""
def send_push_notification(user_id, person_name, is_prod):
    
    key_id = os.environ.get("key_id", "")
    team_id = os.environ.get("team_id", "")
    alg = "ES256"
    private_key = os.environ.get("private_key", "")
    # Prepare the claims
    claims = {
        "iss": team_id,
        "iat": int(datetime.now().timestamp())
    }

    # Add headers
    headers = {
        "alg": alg,
        "kid": key_id,
    }

    # Create the token
    token = jwt.encode(claims, private_key, algorithm=alg, headers=headers)

    # Headers for the push notification
    headers = {
        'apns-topic': os.environ.get("apns-topic", ""),
        'apns-push-type': 'alert',
        'apns-priority': '10',
        'authorization': f'bearer {token}',
    }

    aps = {
        "aps": 
        {
            "timestamp": int(datetime.now().timestamp()),
            "alert": {
                "title": f"{person_name} needs help",
                "body": "",
                "sound": "default"
                }
        }
        
    }
    url = f'https://api.sandbox.push.apple.com/3/device/{user_id}'
    # Send the push notification
    with httpx.Client(http2=True) as client:
        response = client.post(url, headers=headers, json=aps)
        return {'message': response.status_code}
    
@app.post("/token/")
async def login_for_access_token(user: User):
    # Replace with actual user verification logic
    if user.username == "username" and user.password == "password":
        access_token = create_access_token(data={"sub": user.username})
        return {"access_token": access_token, "token_type": "bearer"}
    else:
        raise HTTPException(status_code=401, detail="Incorrect username or password")
    
@app.get("/api/get_schedules/{schedule_id}")
async def get_schedules(schedule_id: str):
    try:
        conn = get_connection()
        cursor = conn.cursor()
        cursor.execute('SELECT * FROM schedules WHERE id = ?', (schedule_id,))
        schedule_data = cursor.fetchall()
        conn.close()
        schedules = []
        for schedule in schedule_data:
            schedule = {
                "id": schedule_data[0],
                "name": schedule_data[1],
                "peopleOnShift": eval(schedule_data[2]),  # Convert string to list
                "startDate": schedule_data[3],
                "endDate": schedule_data[4],
                "autoPick": bool(schedule_data[5]),
                "style": schedule_data[6]
            }
            schedules.append(schedule)
        else:
            return {"message": "Schedule not found"}

    except Exception as e:
        return {"error": str(e)}

@app.post("/api/save_schedule/")
async def save_schedule(schedule: Schedule):
    # Convert the start and end dates to seconds since 1970
    schedule.startDate = schedule.startDate if schedule.startDate else None
    schedule.endDate = schedule.endDate if schedule.endDate else None

    # Insert the schedule data into the SQLite database
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO schedules (id, name, peopleOnShift, startDate, endDate, autoPick, style)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', (schedule.id, schedule.name, str(schedule.peopleOnShift), schedule.startDate, schedule.endDate, schedule.autoPick, schedule.style))
    conn.commit()
    conn.close()
    
    return {"message": "Schedule saved successfully"}

@app.post("/api/save_profile/")
async def save_profile(person: PersonCodable):
    conn = get_connection()
    cursor = conn.cursor()

    cursor.execute('''
        INSERT INTO profiles (id, name, color, imageData, emoji, userID, pushToken, sleepData)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
    ''', (
        person.userID,
        person.name,
        str(person.color.dict()) if person.color else None,
        person.imageData,
        person.emoji,
        person.userID,
        person.pushToken,
        str(person.sleepData) if person.sleepData else None
    ))

    conn.commit()
    conn.close()

@app.post("/api/determine_who_to_wakeup/{schedule_id}")
async def determine_who_to_wakeup(schedule_id: str):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM schedules WHERE id = ?', (schedule_id,))
    schedule_data = cursor.fetchone()
    conn.close()

    if schedule_data:
        schedule = {
            "id": schedule_data[0],
            "name": schedule_data[1],
            "peopleOnShift": eval(schedule_data[2]),  # Convert string to list
            "startDate": schedule_data[3],
            "endDate": schedule_data[4],
            "autoPick": bool(schedule_data[5]),
            "style": schedule_data[6]
        }
        for person in schedule["peopleOnShift"]:
            if get_sleep_stage(float(person["lastHeartrate"]), float(person["lastRespirationRate"])) == "light":
                send_push_notification(person["pushToken"])
        
def create_access_token(data: dict):
    to_encode = data.copy()
    expire = datetime.utcnow() + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES)
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt

def authenticate(token: str = None):
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        user_id = payload.get("sub")
        if user_id is None:
            raise HTTPException(status_code=401, detail="Not authenticated")
        return user_id
    except jwt.PyJWTError:
        raise HTTPException(status_code=401, detail="Not authenticated")

@app.get("/api/get_profile/{user_id}")
async def get_profile(user_id: str):
    conn = get_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT * FROM profiles WHERE id=?', (user_id,))
    row = cursor.fetchone()
    conn.close()

    if row is None:
        raise HTTPException(status_code=404, detail="Profile not found")

    # Map the SQLite row to a Pydantic object
    profile = PersonCodable(
        userID=row[0],
        name=row[1],
        color=json.loads(row[2]) if row[2] else None,
        imageData=row[3],
        emoji=row[4],
        pushToken=row[6],
        sleepData=json.loads(row[7]) if row[7] else None
    )

    return profile.dict()




if __name__ == "__main__":
    import uvicorn
    create_db()
    uvicorn.run(app, host="0.0.0.0", port=8000)
