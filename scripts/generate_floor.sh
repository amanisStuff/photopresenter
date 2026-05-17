#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <width> <depth> [subdivisions]"
  echo "  width       - Floor width (X axis)"
  echo "  depth       - Floor depth (Z axis)"
  echo "  subdivisions- Grid subdivisions per axis (default: 20)"
  exit 1
fi

WIDTH=$1
DEPTH=$2
SUBDIVS=${3:-20}

OUT_DIR="assets/cube"
mkdir -p "$OUT_DIR"

python3 -c "
import math

w = float($WIDTH)
d = float($DEPTH)
n = int($SUBDIVS)

lines = []
lines.append('mtllib floor.mtl')
lines.append('')

step_x = (w * 2) / n
step_z = (d * 2) / n

for i in range(n + 1):
    for j in range(n + 1):
        x = -w + j * step_x
        z = -d + i * step_z
        lines.append(f'v {x:.4f} 0.0 {z:.4f}')

lines.append('vn 0.0 1.0 0.0')

for i in range(n):
    for j in range(n):
        a = i * (n + 1) + j + 1
        b = a + 1
        c = a + (n + 1)
        d_idx = c + 1
        lines.append(f'usemtl FloorMaterial')
        lines.append(f'f {a}//1 {b}//1 {d_idx}//1 {c}//1')

with open('${OUT_DIR}/floor.obj', 'w') as f:
    f.write('\n'.join(lines) + '\n')

max_idx = 0
for line in lines:
    if line.startswith('f '):
        parts = line.split()
        for p in parts[1:]:
            idx = int(p.split('/')[0])
            if idx > max_idx:
                max_idx = idx

total_v = (n + 1) * (n + 1)
print(f'Generated floor.obj: {total_v} vertices, {n*n} faces')
print(f'  Size: {w} x {d}, Subdivisions: {n}x{n}')
print(f'  Max face index: {max_idx} / Total vertices: {total_v} -> OK' if max_idx <= total_v else f'  ERROR: index out of range')
"

echo "Done: ${OUT_DIR}/floor.obj"
