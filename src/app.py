from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from pathlib import Path
import openai
from dotenv import load_dotenv
from pydantic import BaseModel
import os

app = FastAPI()
load_dotenv()

class ModelResponse(BaseModel):
    message: str

BASE_DIR = Path(__file__).parent
templates = Jinja2Templates(directory=str(BASE_DIR / "templates"))

app.mount("/static", StaticFiles(directory=str(BASE_DIR / "static")), name="static")

@app.get("/", response_class=HTMLResponse)
async def index(request: Request):
    return templates.TemplateResponse(request=request, name="chat.html")


@app.post("/chat")
def chat(modelResponse: ModelResponse):
    user_message = modelResponse.message
    print(user_message)
    client = openai.OpenAI(base_url=os.getenv('ENDPOINT'), api_key="nokeyneeded")
    response = client.chat.completions.create(
        model=os.getenv('MODEL'),
        temperature=0.7,
        n=1,
        messages=[
            {
                "role": "system",
                "content": "You are a helpful assistant.",
            },
            {
                "role": "user",
                "content": user_message,
            },
        ],
        stream=True
    )
    
    def stream_response():
        for event in response:
            if event.choices:
                content = event.choices[0].delta.content
                if content:
                    yield content
                    
    return StreamingResponse(stream_response(), media_type='text/plain')


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
