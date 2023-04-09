from fastapi import FastAPI

app = FastAPI()
app.title = "microservice_name"
app.version = "0.0.0"


@app.get('/')
def establish_connection():
    return "microservice_name connected!"
