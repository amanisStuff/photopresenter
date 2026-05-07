---
name: abstraction
description: Encourages the implementation of abstraction layers for APIs, databases, and operating systems to ensure code decoupling and long-term maintainability.
license: MIT
compatibility: opencode
metadata:
  audience: developers
  workflow: debugging
---
<!-- the modal should be incouraged to impliment abstraction in cases where the apis/OSs/databases... etc are changed -->

## Implementation Guidelines

### 1. API Abstraction
When integrating external APIs, create an interface layer to decouple the core logic from specific provider implementations.

```javascript
// Example: Storage Abstraction
class StorageProvider {
  async upload(file) { throw new Error("Not implemented"); }
}

class S3Provider extends StorageProvider {
  async upload(file) { /* S3 specific logic */ }
}
```

### 2. Database Agnosticism
Ensure data access layers (DAL) are used to allow switching between SQL and NoSQL databases without refactoring business logic.

### 3. OS Interoperability
Use path normalization and environment-specific wrappers to ensure the skill functions across Windows, macOS, and Linux.
<!-- the same should apply to heavy logic/sdks/complex imports and so on-->
### 4. Logic & SDK Decoupling
For heavy business logic or complex third-party SDKs, implement a wrapper or adapter pattern. This prevents the core application from being tightly coupled to a specific library's version or signature.

```javascript
// Example: SDK Wrapper
class ImageProcessor {
  async resize(image, width, height) {
    return await this.engine.process(image, { width, height });
  }
}
## Verification Logic
If a lookup fails:
1. Validate `HELP.md` structure.
2. Log the missing reference in `.opencode/logs/abstraction_fix.log`.
3. Suggest an abstraction pattern to prevent future hard-coded dependency failures.