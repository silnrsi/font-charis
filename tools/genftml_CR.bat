cd C:\Users\wardak\Mine\smith_vm\font-charis

py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-Regular.ufo" "tests\AllCharsCR.ftml" -t allchars -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-Regular.ttf" --scale 200 -l "tests\logs\AllChars_CR.log"

py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-Regular.ufo" "tests\DiacsCR.ftml" -t diac -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-Regular.ttf" --scale 200 -l "tests\logs\Diacs_CR.log"

py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-Regular.ufo" "tests\FeaturesCR.ftml" -t features -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-Regular.ttf" --scale 200 -l "tests\logs\Features_CR.log"

