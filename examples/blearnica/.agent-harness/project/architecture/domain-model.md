# Domain Model

## Core Entities

### Learner

The person using the platform to diagnose and improve knowledge.

Important fields:

- id
- name
- email

### Subject

A learning area such as math, English, or programming.

### KnowledgeUnit

A small unit of knowledge such as fractions, present simple tense, or variables.

Relationships:

- Belongs to a subject.
- May have prerequisites.

### DiagnosticTest

An entry test that measures learner understanding across knowledge units.

### DiagnosticResult

The outcome of a diagnostic test, including weak units, strong units, and score.

### LearningPath

A personalized sequence of knowledge units and practice tasks.

### PracticeTask

An exercise assigned to reinforce a knowledge unit.

### ProgressRecord

Progress data for learner activity and completion.
