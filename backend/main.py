from fastapi import FastAPI
from routes import fir, evidence, timeline, graph, qa, court

app = FastAPI(title="CaseMind Backend")

app.include_router(fir.router)
app.include_router(evidence.router)
app.include_router(timeline.router)
app.include_router(graph.router)
app.include_router(qa.router)
app.include_router(court.router)
