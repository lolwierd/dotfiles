## Gemini Added Memories
- The validation script for UPSC PYQs is located at 'pyqs/validate_pyqs.py' and uses the 'gemini-3-flash-preview' model. It saves reports to 'pyqs/GS/parsed/validation'.
- The `pyqs/extract_gemini.py` script now supports chunked PDF processing (default 6 pages per chunk) to handle large files and avoid token limits, using `pypdf` to split the PDF.
- Current affairs and web search (grounding) are now forced ON for all quiz generation requests (both single quizzes and quiz sets) in the worker codebase.
