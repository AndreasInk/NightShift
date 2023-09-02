"""
1984 Andreas Ink
"""

from fastapi import FastAPI

# Create an instance of the FastAPI class
app = FastAPI()

# Define a route and a function to handle it
@app.get("/")
def read_root():
    return {"message": "Hello World"}

# Run the application using uvicorn
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
