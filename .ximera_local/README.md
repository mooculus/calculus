
This repository contains the source for the `ximera` LaTeX package. 

Since  the summer of 2024, the Ximera document class is available in [CTAN](https://ctan.org/pkg/ximera?lang=en). Moreover it is strongly advised to use Ximera with [docker](https://github.com/XimeraProject/ximeraFirstSteps). 
This repo should therefore not be directly relevant for (prospective) Ximera authors or endusers.
They should consult the [Ximera Manual](https://ximera.osu.edu/xman) or [Example Ximera Xourse](https://go.osu.edu/ximera-examples) for more info on Ximera.


This repo also contains the optional (but strongly recommended) build (lua-) script `luaxake` and a wrapper (bash-) script `xmlatex` with some extra functionality but espaccially to transparently run `luaxake` in a docker container.

This repo also contain the `Dockerfile(s)` to build docker images which provide the most typical way to use Ximera.

Manual local installation of the Ximera LaTeX package is normally never needed, but (somewhat old) documentation remains [available](./installingLocally.md).


# Contents of the repository

* This README.md file. 

* The LPPL 1.3c license.

* The Ximera documented LaTeX file type, ximera.dtx. This file
  generates ximera.cls, xourse.cls, and ximeraLaTeX.pdf, as well as a
  few other files.

* In the `src` folder the ximeraLatex source files (as used by ximera.dtx)

* In the `luaxake` folder the LUA code of the `luaxake` build script. This has its own [README](luaxake/README.md).

* In the `xmScripts` folder, the (wrapper-) script `xmlatex`. One version goes into the docker image, a simplified 'header' part should go in each ximera-repo (or just once somewhere in the PATH) oo your PC.

* In the `docker` folder build files for docker images. Images are automatically build for each tag of this repo, and released versions are available from [github](https://github.com/orgs/XimeraProject/packages)

# Advanced: building (local) docker images

Check out this repo and run (from the root folder)
```
docker buildx build --tag ghcr.io/ximeraproject/ximeralatex:latest --file docker/Dockerfile.full .
```

and test or use the newly build image eg with 
```
XAKE_VERSION=latest  xmlatex bake mytestfile.tex
```
To further develop, test or manipulate Ximera, you can work inside the container with
```
XAKE_VERSION=latest  xmlatex bash
```
It is possible to extract this package from the container into a .ximera_local folder, and develop from there with 
```
XAKE_VERSION=latest  xmlatex copySettingsLocal
```

The default XAKE_VERSION (and thus the container to be used) can also be set in xmScripts/config.txt.

# Advanced: compiling the `ximera` LaTeX package

Running `make` generates the derived files README, ximera.pdf, ximera.cls, xourse.cls, ximera.cfg, ximera.4ht, xourse.4ht.

Running `make ctan` generates a submission suitable for CTAN

(OBSOLETE) Running `make inst` installs the files in the user's TeX tree.

(OBSOLETE) Running `make install` installs the files in the local TeX tree.

All this can (optionally) done INSIDE a ximeralatex docker container, ie after running
```
xmlatex bash
```
in the root folder of this repo.


# A Non-Official List Of Possible Future Features

- Ability to include \activities and \practice within a ximera document
  - when adding Xourses, the path to the xourse/file needs to be given
in some way. We have an example of this in the preamble of
examples/exerciseCollection/exerciseCollection.tex This enables an
author to print the file and know where to find the parts.
  - Perhaps by default, all Xourse files appear on the top page, but if modified with `\documentclass[hidden]{xourse}, they would no longer appear
  - A separate, perhaps password protected page with ALL content on it.