# Inference Lock

Mixin module to get inference locking in custom Ruby tool to match that of
native SketchUp tool (as close as possible).

Supports constraint lock (Shift) and axial locks (Arrow Keys).
Parallel/Perpendicular lock (Down Arrow) is not supported.

## Installation

1. Place file inside your extension's directory, preferably in a sub-directory called vendor to distinguish it from your own code base.
2. Wrap file content in your extension's namespace.
3. Require the file from files depending on it.
