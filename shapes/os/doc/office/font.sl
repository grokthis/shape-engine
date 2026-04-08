shape os.doc.office.font : os.doc {
  type: doc
  layer: 4
  section: 4
  synopsis: "Font system"
  summary: "TTF font parsing, serving, and font picker for office apps."
  """
# Font System

Fonts are shapes. Each font family is a shape under `os.font.*` with
weight/style children. Binary font data lives in the content store.

## Font Shapes

- `os.font.system` - Platform default sans-serif
- `os.font.mono` - Platform default monospace
- `os.font.serif` - Platform default serif
- `os.font.{family}.regular` - Regular weight (400)
- `os.font.{family}.bold` - Bold weight (700)

## Font Serving

GET `/office/font/{family}/{style}.ttf` serves font bytes.

## Adding Fonts

Import a TTF file as a shape:
1. Store the binary data in the content store
2. Create a font shape with metadata (family, weight, style)
3. The font becomes available in all office editors
"""
}
