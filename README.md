# EBU6304 TA Recruitment System

BUPT International School Teaching Assistant Recruitment System.

This repository follows the EBU6304 group-project workflow and assessment schedule.

## Project Goal

Build a Java Servlet/JSP web prototype that supports TA recruitment with:
- efficient memory management
- stable file-based persistence
- clear data structures and boundaries
- a high-recognition, design-driven frontend

## Branch Strategy

- `main`: documentation and assessment submissions only
- `project-ta-system`: integration branch for software implementation
- personal branches (for example `YuhangFu`): member development branches

## Core Roles and Features

- TA: create profile, browse jobs, apply, check status
- MO: post jobs, shortlist candidates
- Admin: monitor workload distribution

## Engineering Standards

### Backend quality bar

- Layering: `Servlet (Controller) -> Service -> Repository -> FileStore`
- Storage: text files only (`JSON Lines`), no database
- Stability:
  - idempotent application submission by `applicationId`
  - input validation and explicit exception boundaries
  - append-only writes and atomic compaction
- Memory efficiency:
  - lightweight startup indexes (`id/status`)
  - on-demand detail loading
  - paged reads, no unbounded cache

### Frontend quality bar

- iPhone-inspired visual language:
  - bright minimal base
  - glass cards
  - layered rounded geometry
  - coherent motion rhythm (`120ms` and `240ms`)
- Mobile-first responsive layout with distinct visual identity

## Data Files (No Database)

Expected runtime files:
- `data/jobs.jsonl`
- `data/applications.jsonl`
- `data/users.jsonl`

Each line is one JSON object for append-friendly persistence and deterministic parsing.

## First Assessment Mapping (Due: 22 March 2026)

Materials are in `docs/assessment1/`:
- `Product_Backlog.xlsx`
- `Prototype_v1.pdf`
- `Brief_Report_v1.pdf`
- `submission-checklist.md`

## Delivery Milestones

- 22 March 2026: First assessment
- 12 April 2026: Intermediate assessment
- 24 May 2026: Final assessment

## Quick Collaboration Rules

- No direct code push to `main`
- Feature work goes to personal branch -> PR to `project-ta-system`
- Documentation for staged submission is maintained on `main`
