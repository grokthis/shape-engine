#!/usr/bin/env python3
"""Build shapes.json from all .sl files for the web deployment."""
import json, os

shapes_dir = os.path.join(os.path.dirname(__file__), '..', 'shapes')
out_path = os.path.join(os.path.dirname(__file__), 'shapes.json')

shapes = {}
for root, dirs, files in os.walk(shapes_dir):
    for f in sorted(files):
        if not f.endswith('.sl'):
            continue
        path = os.path.join(root, f)
        rel = os.path.relpath(path, shapes_dir)
        with open(path) as fh:
            content = fh.read()
        layer = 0
        for line in content.split('\n'):
            line = line.strip()
            if line.startswith('layer:'):
                try: layer = int(line.split(':')[1].strip())
                except: pass
                break
        shapes[rel] = {'content': content, 'layer': layer}

with open(out_path, 'w') as out:
    json.dump(shapes, out)

print(f'{len(shapes)} shapes -> {out_path} ({os.path.getsize(out_path)} bytes)')
