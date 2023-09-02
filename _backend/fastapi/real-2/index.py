"""
vscodium is shit
"""


from fastapi import FastAPI
from pydantic import BaseModel
import sqlite3




app = FastAPI()

class Schedule(BaseModel):
    id: str = None
    name: str = None
    peopleOnShift: list = None
    startDate: int = None
    endDate: int = None
    autoPick: bool = None
    style: str = None


# Create an SQLite database and a table
def create_db():
    conn = sqlite3.connect('schedule.db')
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
    conn.commit()
    conn.close()


"""
What 

"""

@app.get("/get_schedule/{schedule_id}")
async def get_schedule(schedule_id: str):
    try:
        conn = sqlite3.connect('schedule.db')
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
            return schedule
        else:
            return {"message": "Schedule not found"}

    except Exception as e:
        return {"error": str(e)}


@app.post("/save_schedule/")
async def save_schedule(schedule: Schedule):
    # Convert the start and end dates to seconds since 1970
    schedule.startDate = schedule.startDate if schedule.startDate else None
    schedule.endDate = schedule.endDate if schedule.endDate else None

    # Insert the schedule data into the SQLite database
    conn = sqlite3.connect('schedule.db')
    cursor = conn.cursor()
    cursor.execute('''
        INSERT INTO schedules (id, name, peopleOnShift, startDate, endDate, autoPick, style)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ''', (schedule.id, schedule.name, str(schedule.peopleOnShift), schedule.startDate, schedule.endDate, schedule.autoPick, schedule.style))
    conn.commit()
    conn.close()
    
    return {"message": "Schedule saved successfully"}

if __name__ == "__main__":
    import uvicorn
    create_db()
    uvicorn.run(app, host="0.0.0.0", port=8000)
