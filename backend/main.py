from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import Response
from pydantic import BaseModel
from typing import List, Optional
from dotenv import load_dotenv
import httpx
import os
import json
import re

load_dotenv()

app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

GEMINI_API_KEY = os.getenv("GEMINI_API_KEY")
ELEVENLABS_API_KEY = os.getenv("ELEVENLABS_API_KEY")

VOICE_IDS = {
    "malay": "lvNyQwaZPcGFiNUWWiVa",
    "chinese": "9lHjugDhwqoxA5MhX0az",
    "tamil": "Z0ocGS7BSRxFSMhV00nB",
    "english": "21m00Tcm4TlvDq8ikWAM",
}

# Language-specific system prompts with Malaysian conversational style
SYSTEM_PROMPTS = {
    "english": """You are a friendly Malaysian Government Services Assistant. Respond in Malaysian English (Manglish) style - casual, warm, and helpful. Use Malaysian expressions like "lah", "can", "no problem one", "okay lah" naturally. Keep it professional but friendly like talking to a Malaysian friend.

Example style: "No worries lah, I can help you with that! Losing IC is quite common one, don't stress."

Format response as JSON: {"response": "your message", "type": "text" or "checklist", "checklist": ["item 1", "item 2"] if applicable}

Common scenarios:
- Lost IC: Police report, visit JPN, bring birth cert, pay RM10, wait 24h
- Renew IC: Book appointment online, bring old IC, photo, pay RM5
- Lost passport: Police report, Immigration office, bring IC, pay fee""",

    "malay": """Anda adalah Pembantu Perkhidmatan Kerajaan Malaysia yang mesra. Jawab dalam Bahasa Malaysia yang santai dan mesra seperti bercakap dengan kawan. Gunakan gaya perbualan Malaysia yang biasa.

Contoh gaya: "Tak apa, saya boleh tolong. Kehilangan IC ni biasa je, jangan risau sangat."

Format respons sebagai JSON: {"response": "mesej anda", "type": "text" atau "checklist", "checklist": ["item 1", "item 2"] jika berkenaan}

Senario biasa:
- IC hilang: Laporan polis, pergi JPN, bawa sijil lahir, bayar RM10, tunggu 24 jam
- Pembaharuan IC: Buat temujanji online, bawa IC lama, gambar, bayar RM5
- Pasport hilang: Laporan polis, pejabat Imigresen, bawa IC, bayar""",

    "chinese": """你是一位友好的马来西亚政府服务助手。用马来西亚华人的日常口语风格回答，轻松友好，像跟朋友聊天一样。可以用一些马来西亚华人常用的表达方式。

例子风格："没关系啦，我可以帮你的！IC不见很常见的，不用太担心。"

用JSON格式回复: {"response": "你的信息", "type": "text" 或 "checklist", "checklist": ["项目1", "项目2"] 如适用}

常见情况:
- IC丢失：警察报案、去JPN、带出生证明、付RM10、等24小时
- 更新IC：网上预约、带旧IC、照片、付RM5
- 护照丢失：警察报案、移民局、带IC、付费""",

    "tamil": """நீங்கள் ஒரு நட்பான மலேசிய அரசு சேவைகள் உதவியாளர். மலேசிய தமிழர்களின் அன்றாட பேச்சு வழக்கில் பதிலளிக்கவும், நட்பாகவும் எளிமையாகவும் இருக்கவும்.

JSON வடிவத்தில் பதில்: {"response": "உங்கள் செய்தி", "type": "text" அல்லது "checklist", "checklist": ["பொருள் 1", "பொருள் 2"] பொருந்தினால்}

பொதுவான சூழ்நிலைகள்:
- IC தொலைந்தது: போலீஸ் புகார், JPN செல்லுங்கள், பிறப்புச் சான்றிதழ், RM10 செலுத்துங்கள், 24 மணி நேரம் காத்திருங்கள்
- IC புதுப்பித்தல்: ஆன்லைன் சந்திப்பு, பழைய IC, புகைப்படம், RM5 செலுத்துங்கள்"""
}

class ChatRequest(BaseModel):
    message: str
    language: str = "english"

class ChatResponse(BaseModel):
    response: str
    type: str = "text"
    checklist: Optional[List[str]] = None

class TTSRequest(BaseModel):
    text: str
    language: str = "english"

@app.get("/")
def read_root():
    return {"status": "Journey Backend Running", "voices": list(VOICE_IDS.keys())}

@app.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    lang = request.language.lower() if request.language else "english"
    system_prompt = SYSTEM_PROMPTS.get(lang, SYSTEM_PROMPTS["english"])
    
    if not GEMINI_API_KEY:
        return simple_chat(request.message, lang)
    
    try:
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key={GEMINI_API_KEY}",
                headers={"Content-Type": "application/json"},
                json={
                    "contents": [{"parts": [{"text": f"{system_prompt}\n\nUser: {request.message}\n\nRespond in JSON:"}]}],
                    "generationConfig": {"temperature": 0.8, "maxOutputTokens": 1024}
                },
                timeout=30.0
            )
            
            if response.status_code == 200:
                data = response.json()
                text = data.get("candidates", [{}])[0].get("content", {}).get("parts", [{}])[0].get("text", "")
                json_match = re.search(r'\{[\s\S]*\}', text)
                if json_match:
                    parsed = json.loads(json_match.group(0))
                    return ChatResponse(
                        response=parsed.get("response", text),
                        type=parsed.get("type", "text"),
                        checklist=parsed.get("checklist")
                    )
                return ChatResponse(response=text)
    except Exception as e:
        print(f"Gemini error: {e}")
    return simple_chat(request.message, lang)

def simple_chat(message: str, lang: str = "english") -> ChatResponse:
    msg = message.lower()
    
    responses = {
        "english": {
            "lost": ("Aiyah, lost IC ah? No worries lah, I can help! Here's what you need to do:", ["File police report first", "Go to JPN branch", "Bring your birth cert", "Pay RM10 fee", "Wait about 24 hours"]),
            "renew": ("Sure thing! Renewing IC is easy one lah:", ["Book appointment online first", "Bring your old IC", "Bring passport photo", "Pay RM5 only"]),
            "default": "How can I help you today? Just ask me anything about government services lah!"
        },
        "malay": {
            "lost": ("Alamak, IC hilang ke? Takpe, saya boleh tolong!", ["Buat laporan polis dulu", "Pergi cawangan JPN", "Bawa sijil lahir", "Bayar RM10", "Tunggu lebih kurang 24 jam"]),
            "renew": ("Boleh je! Pembaharuan IC senang:", ["Buat temujanji online dulu", "Bawa IC lama", "Bawa gambar passport", "Bayar RM5 je"]),
            "default": "Macam mana saya boleh bantu hari ni? Tanya je apa-apa pasal perkhidmatan kerajaan!"
        },
        "chinese": {
            "lost": ("哎呀，IC不见了啊？没关系啦，我帮你！", ["先去报警", "去JPN分行", "带出生证明", "付RM10", "等大概24小时"]),
            "renew": ("可以的！更新IC很简单的:", ["先上网预约", "带旧IC", "带护照照片", "付RM5就可以了"]),
            "default": "今天我可以帮你什么？问我任何关于政府服务的问题啦！"
        },
        "tamil": {
            "lost": ("IC காணாமல் போனதா? கவலைப்படாதீர்கள், நான் உதவுகிறேன்!", ["முதலில் போலீஸ் புகார் செய்யுங்கள்", "JPN கிளைக்கு செல்லுங்கள்", "பிறப்புச் சான்றிதழ் கொண்டு வாருங்கள்", "RM10 செலுத்துங்கள்", "24 மணி நேரம் காத்திருங்கள்"]),
            "renew": ("நிச்சயமாக! IC புதுப்பிப்பது எளிது:", ["ஆன்லைனில் முன்பதிவு செய்யுங்கள்", "பழைய IC கொண்டு வாருங்கள்", "பாஸ்போர்ட் புகைப்படம்", "RM5 செலுத்துங்கள்"]),
            "default": "இன்று நான் எப்படி உதவ முடியும்? அரசு சேவைகள் பற்றி கேளுங்கள்!"
        }
    }
    
    lang_data = responses.get(lang, responses["english"])
    
    if "lost" in msg or "hilang" in msg or "不见" in msg or "காணாமல்" in msg:
        return ChatResponse(response=lang_data["lost"][0], type="checklist", checklist=lang_data["lost"][1])
    elif "renew" in msg or "baharu" in msg or "更新" in msg or "புதுப்பி" in msg:
        return ChatResponse(response=lang_data["renew"][0], type="checklist", checklist=lang_data["renew"][1])
    return ChatResponse(response=lang_data["default"])

@app.get("/user/id")
def get_digital_id():
    return {"name": "Tan Ah Kow", "id_number": "900101-14-1234", "country": "Malaysia", "qr_data": "did:my:900101141234:verify", "valid_until": "2030-12-31"}

@app.post("/tts")
async def text_to_speech(request: TTSRequest):
    if not ELEVENLABS_API_KEY:
        raise HTTPException(status_code=500, detail="ELEVENLABS_API_KEY not configured")
    
    voice_id = VOICE_IDS.get(request.language.lower(), VOICE_IDS["english"])
    
    async with httpx.AsyncClient() as client:
        response = await client.post(
            f"https://api.elevenlabs.io/v1/text-to-speech/{voice_id}",
            headers={"Accept": "audio/mpeg", "Content-Type": "application/json", "xi-api-key": ELEVENLABS_API_KEY},
            json={"text": request.text[:500], "model_id": "eleven_multilingual_v2", "voice_settings": {"stability": 0.5, "similarity_boost": 0.75}},
            timeout=30.0
        )
        if response.status_code == 200:
            return Response(content=response.content, media_type="audio/mpeg")
        raise HTTPException(status_code=response.status_code, detail=f"TTS failed: {response.text}")
