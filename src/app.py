from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import openai
from dotenv import load_dotenv
from pydantic import BaseModel

app = FastAPI()
load_dotenv()

class ModelResponse(BaseModel):
    message: str


app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")


@app.get("/", response_class=HTMLResponse)
async def index(request: Request):
    return templates.TemplateResponse(request=request, name="chat.html")


@app.post("/chat")
def chat(modelResponse: ModelResponse):
    user_message = modelResponse.message
    print(user_message)
    client = openai.OpenAI(base_url="http://localhost:11434/v1", api_key="nokeyneeded")
    response = client.chat.completions.create(
        model="qwen3:0.6b",
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
        ]
    )
    
    def stream_response():
        yield response.choices[0].message.content
                
                    
                    
    return StreamingResponse(stream_response(), media_type='text/plain')


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000)
