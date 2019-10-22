pushd C:\Users\wardak\Mine\smith_vm\font-charis

py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-Regular.ufo" "tests\AllCharsCR.ftml" -t allchars -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-Regular.ttf" --scale 200 -l "tests\logs\AllChars_CR.log"

py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-Regular.ufo" "tests\DiacCR.ftml" -t diac -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-Regular.ttf" --scale 200 -l "tests\logs\Diac_CR.log"

py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-Regular.ufo" "tests\FeaturesCR.ftml" -t features -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-Regular.ttf" --scale 200 -l "tests\logs\Features_CR.log"


py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-Italic.ufo" "tests\AllCharsCI.ftml" -t allchars -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-Italic.ttf" --scale 200 -l "tests\logs\AllChars_CI.log"

py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-Italic.ufo" "tests\DiacCI.ftml" -t diac -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-Italic.ttf" --scale 200 -l "tests\logs\Diac_CI.log"

py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-Italic.ufo" "tests\FeaturesCI.ftml" -t features -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-Italic.ttf" --scale 200 -l "tests\logs\Features_CI.log"


py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-Bold.ufo" "tests\AllCharsCB.ftml" -t allchars -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-Bold.ttf" --scale 200 -l "tests\logs\AllChars_CB.log"

py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-Bold.ufo" "tests\DiacCB.ftml" -t diac -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-Bold.ttf" --scale 200 -l "tests\logs\Diac_CB.log"

py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-Bold.ufo" "tests\FeaturesCB.ftml" -t features -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-Bold.ttf" --scale 200 -l "tests\logs\Features_CB.log"


py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-BoldItalic.ufo" "tests\AllCharsCBI.ftml" -t allchars -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-BoldItalic.ttf" --scale 200 -l "tests\logs\AllChars_CBI.log"

py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-BoldItalic.ufo" "tests\DiacCBI.ftml" -t diac -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-BoldItalic.ttf" --scale 200 -l "tests\logs\Diac_CBI.log"

py C:\Users\wardak\Mine\smith_vm\font-charis\tools\psfgenftml.py "source\CharisSIL-BoldItalic.ufo" "tests\FeaturesCBI.ftml" -t features -f C -i "source\glyph_data.csv" -s "../results/CharisSIL-BoldItalic.ttf" --scale 200 -l "tests\logs\Features_CBI.log"

popd
