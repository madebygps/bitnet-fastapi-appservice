from fastapi import FastAPI, Request
from fastapi.responses import StreamingResponse, HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
from pathlib import Path
import openai
from dotenv import load_dotenv
from pydantic import BaseModel
import os
import logging
from contextlib import asynccontextmanager

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info('Inititialzing OpenAI client')
    app.state.client = openai.OpenAI(base_url=os.getenv('ENDPOINT'), api_key="nokeyneeded", timeout=60)
    yield
    logger.info('Shutting down')


app = FastAPI(lifespan=lifespan)
load_dotenv()

class ModelResponse(BaseModel):
    message: str

BASE_DIR = Path(__file__).parent
templates = Jinja2Templates(directory=str(BASE_DIR / "templates"))
app.mount("/static", StaticFiles(directory=str(BASE_DIR / "static")), name="static")



@app.get("/", response_class=HTMLResponse)
async def index(request: Request):
    return templates.TemplateResponse(request=request, name="chat.html")

@app.get("/health")
async def health():
    return {"status": "ok"}

@app.post("/chat")
async def chat(modelResponse: ModelResponse):
    user_message = modelResponse.message
    logger.info(f"Received message: {user_message[:50]}...")
    try:
        response = app.state.client.chat.completions.create(
            model=os.getenv('MODEL'),
            temperature=0.3,
            n=1,
            messages=[
                {
                    "role": "system",
                    "content": "You are a helpful assistant. Keep responses brief and focused.",
                },
                {
                    "role": "user",
                    "content": user_message,
                },
            ],
            stream=True,
            max_tokens=150,
            
            
        )
        
        async def stream_response():
            try:
                for event in response:
                    if event.choices:
                        content = event.choices[0].delta.content
                        if content:
                            yield content
            except Exception as e:
                    logger.error(f"Streaming error: {str(e)}")
                    yield f"\nError during streaming: {str(e)}"

                        
        return StreamingResponse(stream_response(), media_type='text/plain')
    except Exception as e:
        logger.error(f"Chat error: {str(e)}")
        return {"error": str(e)}


if __name__ == "__main__":
    import uvicorn

    uvicorn.run(app, host="0.0.0.0", port=8000, timeout_keep_alive=75)
