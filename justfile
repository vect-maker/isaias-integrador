default:
  @just --list

compile:
  typst compile main.typ main.pdf

watch:
  typst watch main.typ main.pdf

preview:
  mkdir -p preview
  typst compile --format png --ppi 150 main.typ preview/main-{n}.png

compare: compile
  mkdir -p comparison/original comparison/typst
  [ -f Documento_final_INTV.pdf ] && [ ! -f comparison/original/page-01.png ] && pdftoppm -png -r 150 Documento_final_INTV.pdf comparison/original/page || true
  rm -f comparison/typst/page-*.png
  pdftoppm -png -r 150 main.pdf comparison/typst/page

extract-images:
  mkdir -p images
  python3 -c "import zipfile, os; z=zipfile.ZipFile('Documento_final_INTV.docx'); [open(os.path.join('images', os.path.basename(n)), 'wb').write(z.read(n)) for n in z.namelist() if n.startswith('word/media/')]; print('Extracted images successfully.')"
