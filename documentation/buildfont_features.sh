#!/bin/sh

# pandoc -f markdown-smart -s -M testfont="[../results/CharisSIL-Regular.ttf]" -M fontitalic="[../results/CharisSIL-Italic.ttf]" -M testsize=12 --metadata-file=source/metadata.yaml --pdf-engine=xelatex -o CharisSIL-font-features.json source/CharisSIL-font-features.md

pandoc -f markdown-smart -F source/pandocfeats.py -s -M testfont="[../results/CharisSIL-Regular.ttf]" -M fontitalic="[../results/CharisSIL-Italic.ttf]" -M testsize=12 --metadata-file=source/metadata.yaml --pdf-engine=xelatex -o CharisSIL-font-features.pdf source/CharisSIL-font-features.md

pandoc -f markdown-smart -F source/pandocfeats.py -s -M testfont="CharisSIL-R" -M fontitalic="CharisSIL-I" --template=source/template.html -o CharisSIL-font-features.html source/CharisSIL-font-features.md

pandoc -f markdown-smart -F source/pandocfeats.py -s -M testfont="CharisSIL-R" -M fontitalic="CharisSIL-I" -o CharisSIL-font-features_mmd.md source/CharisSIL-font-features.md
