from pydantic import BaseModel
from typing import List, Dict, Optional, Literal


# ------------------------
# FIR MODELS
# ------------------------

class FIRRequest(BaseModel):
    fir_text: str


class FIRAnalysisResponse(BaseModel):
    case_summary: str
    extracted_entities: Dict[str, List[str]]
    bns_sections: List[str]
    investigation_plan: List[str]


# ------------------------
# EVIDENCE MODELS
# ------------------------

EvidenceType = Literal["document", "image", "audio", "video", "forensic"]

class EvidenceRequest(BaseModel):
    case_id: str
    evidence_type: EvidenceType
    evidence_summary: str  # OCR / transcript / scene description
    source: Optional[str] = None
    timestamp: Optional[str] = None
    fir_context: Dict


class EvidenceInsight(BaseModel):
    key_findings: List[str]
    extracted_entities: Dict[str, List[str]]
    inferred_timeline_events: List[str]
    confidence_level: Literal["low", "medium", "high"]


# ------------------------
# CONSISTENCY CHECK
# ------------------------

class ConsistencyCheckRequest(BaseModel):
    case_state: Dict
    new_evidence_insight: Dict


class ConsistencyResult(BaseModel):
    conflicts: List[str]
    severity: Literal["low", "medium", "high"]
    explanation: str


# ------------------------
# TIMELINE
# ------------------------

class TimelineUpdateRequest(BaseModel):
    case_id: str
    existing_timeline: List[Dict]
    new_events: List[str]



class TimelineEvent(BaseModel):
    event: str
    time_range: Optional[str]
    source: str
    confidence: Literal["low", "medium", "high"]


# ------------------------
# EVIDENCE GAP DETECTION
# ------------------------

class EvidenceGapRequest(BaseModel):
    case_summary: Dict
    timeline: List[Dict]


class EvidenceGapResponse(BaseModel):
    missing_evidence: List[str]
    suggested_actions: List[str]


# ------------------------
# ENTITY GRAPH
# ------------------------

class GraphNode(BaseModel):
    id: str
    type: Literal["victim", "suspect", "witness", "location", "evidence"]


class GraphEdge(BaseModel):
    source: str
    target: str
    relation: str


class GraphResponse(BaseModel):
    nodes: List[GraphNode]
    edges: List[GraphEdge]


# ------------------------
# INVESTIGATION PATH SIMULATOR
# ------------------------

class InvestigationSimulationRequest(BaseModel):
    case_state: Dict


class InvestigationPath(BaseModel):
    actions: List[str]
    expected_outcomes: List[str]
    risks: List[str]


class SimulationResponse(BaseModel):
    path_a: InvestigationPath
    path_b: InvestigationPath


# ------------------------
# CASE Q&A
# ------------------------

class CaseQuestionRequest(BaseModel):
    case_data: Dict
    question: str


class CaseAnswerResponse(BaseModel):
    answer: str
    justification: Optional[str] = None


# ------------------------
# COURT NARRATIVE
# ------------------------

class CourtNarrativeRequest(BaseModel):
    case_data: Dict


class CourtNarrativeResponse(BaseModel):
    narrative: str
