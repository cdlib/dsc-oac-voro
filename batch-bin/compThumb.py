#!/usr/bin/env python
import sys
from PIL import Image, ImageFont, ImageDraw
import os.path

if not len(sys.argv) == 6:
    print "useage $file1, $file2, $file3, $newfile, $string"
    sys.exit(1)
else:
    image1 = Image.open(sys.argv[1])
    image2 = Image.open(sys.argv[2]) 
    image3 = Image.open(sys.argv[3]) if os.path.isfile(sys.argv[3]) else ''

    (w1, h1) = image1.size
    (w2, h2) = image2.size
    (w3, h3) = image3.size if hasattr(image3, 'size') else ('','')

    f1 = 170 if (w1 >= 170) else w1
    f2 = 170 if (w2 >= 170) else w2
    f3 = 170 if (w3 >= 170) else w3

    n1 = (f1/w1)*h1
    n2 = (f2/w1)*h2
    n3 = (f3/w3)*h3 if w3 else ''

    x = f1
    if f2+15 > x:
        x = f2+15
    if f3 != '' and f3+30 > x:
        x = f3+30

    y = n1 + 45
    if n2+30 > y:
        y = n2+30
    if n3 != '' and n3 != '' and n3 != '' and n3+15 > y:
        y = n3+15

    im = Image.new("RGBA", (x,y), (255, 255, 255, 0))

    print image3
    resizedImage3 = image3.resize((f3,n3))


    if n3 != '':
        im.paste(image3.resize((f3,n3)), (30, 0))
    im.paste(image2.resize((f2,n2)), (15, 15))
    im.paste(image1.resize((f1,n1)), (0, 30))

    f = ImageFont.load_default()
    dr = ImageDraw.Draw(im)
    dr.text( (2,n1+30), sys.argv[5], fill="#000000", font=f)

    im.save(sys.argv[4], "PNG")




