# MiG-23M Project Architecture & Safety Rules

## CRITICAL SAFETY RULES - CODE PRESERVATION
These rules apply to all AI modifications. Failure to follow them is considered a critical failure.

1. **NO DESTRUCTIVE REWRITES:** You are strictly forbidden from deleting, shortening, refactoring, or "optimizing" any existing code unless explicitly instructed (e.g., "you may rewrite this function").
2. **NO TRUNCATION:** Never use placeholders like `-- ... rest of the code ...`.
3. **ISOLATED CHANGES:** If a file is large, do not rewrite the whole file. Provide ONLY the specific block of code to be changed/added and explicitly state WHERE to apply it.
4. **NO UNRELATED MODIFICATIONS:** Do not touch, delete, or optimize systems unrelated to the current task.
5. **VERIFY BEFORE OUTPUT:** Before finalizing a response, verify: "Did I delete any existing working code?" If yes, discard the response and rewrite.

## Workflows
- **Verified Save Point:** After the user confirms that a feature is working correctly (e.g., "все хорошо", "работает"), always perform:
    1. `git add .`
    2. `git commit -m "[Brief description]"`
    3. `git push origin master`

