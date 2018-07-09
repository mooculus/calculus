# Compiling the textbooks using Xake (and LaTeX)

Compiling these documents is a bit tricky. 

First install SAGE: http://www.sagemath.org/
This should install SageTeX.

Now if you are planning to use Xake to compile this repository, you
first need to compile:

frontCover.tex
spine.tex
backCover.tex

for every subdirectory of coverArt, for example:
~~~~
pdflatex coverArt/calculus1Cover/frontCover.tex
pdflatex coverArt/calculus1Cover/spine.tex
pdflatex coverArt/calculus1Cover/backCover.tex
~~~~

After this, you should be able to compile the .tex files and PDFlatex.

This work is licensed under the Creative Commons
Attribution-NonCommercial-ShareAlike License. To view a copy of this
license, visit

  http://creativecommons.org/licenses/by-nc-sa/4.0/

or send a letter to Creative Commons, 543 Howard Street, 5th Floor,
San Francisco, California, 94105, USA. If you distribute this work or
a derivative, include the history of the document.

The source code is available at

  https://github.com/mooculus/calculus

This text contains source material from several other open-source
texts:

* Single and Multivariable Calculus: Early
  Transcendentals. Guichard. Copyright 2015 Guichard, Creative Commons
  Attribution-NonCommercial-ShareAlike License 3.0.

	http://communitycalculus.org/

* APEX Calculus. Hartman, Heinold, Siemers, Chalishajar, Bowen
  (Ed.). Copyright 2014 Hartman, Creative Commons
  Attribution-Noncommercial 3.0.

	http://www.apexcalculus.com/
	
* Elementary Calculus: An Infinitesimal Approach. Keisler. Copyright
  2015 Keisler, Creative Commons Attribution-NonCommercial-ShareAlike
  License 3.0.

	http://www.math.wisc.edu/~keisler/calc.html

We will be glad to receive corrections and suggestions for improvement
at ximera@math.osu.edu
