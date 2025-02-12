FROM registry.gitlab.com/islandoftex/images/texlive:TL2024-2024-11-17-medium

RUN apt-get update -y;  \
    apt-get install -y \
    git  git-restore-mtime \
    # mupdf-tools \
    pdf2svg \
    gnupg \
    jq \
    curl \
    wget  \
    dos2unix  \
    vim-tiny strace less \
    nano file

# hashcash needed for setting up communication to ximeraServer; seems unfortunately not (easily?) installable with apt..
ADD docker/hashcash_1.22-1_amd64.deb .
RUN dpkg -i hashcash_1.22-1_amd64.deb    


# Extra packages (on top of 'medium')
RUN tlmgr update --self; \ 
    tlmgr install \
        # afterpage \
        amsmath \
        # amssymb \
        # amsthm \
        # bm \
        booktabs \
        cancel \
        caption \
        ccicons \
        changebar \
        chemfig \
        chemgreek \
        chemmacros \
        circuitikz \
        # color \
        comment \
        currfile \
        datetime \
        enumitem \
        environ \
        epstopdf \
        esint \
        eurosym \
        # extramarks \
        fancyhdr \
        fancyvrb \
        float \
        # fontenc \
        forloop \
        geometry \
        gettitlestring \
        # graphicx \
        hyperref \
        hypdoc \ 
        # ifpdf \
        # ifthen \
        # ifxetex \
        # inputenc \
        listings \
        makecell \
        makecmds \
        marginnote \
        mhchem \
        morewrites \
        # multicol \
        multido \
        multirow \
        # nameref \
        pdflscape \
        pgfplots \
        polynom \
        qrcode \
        relsize \
        # sagetex \
        silence \
        signchart \
        siunitx \
        tabto-ltx \
        # tabularx \
        tcolorbox \
        # textcomp \
        textpos \
        # tikz \
        tikz-3dplot \
        tikzsymbols \
        titlesec \
        # titletoc \
        titling \
        url \
        # verbatim \
        xcolor \
        xifthen \
        xkeyval \
        xstring \
        tikz-cd tkz-euclide \
        ifmtarg \
        etoolbox translations mathtools xfrac filehook \
        doclicense \
        simplekv fmtcount pdfcol \
        tikzfill \
        tkz-tab \
        csquotes \
        babel-dutch \
        microtype \
        tex4ht make4ht \
        luaxml \
        fontawesome stix  \
        latexindent \
        wallpaper

# make4ht is not in /usr/local/bin if installed with tlmgr!!!
ENV PATH="$PATH:/usr/local/texlive/2024/bin/x86_64-linux"

# Add this complete ximeraLatex repo (is overkill, but allows bugfixing/editing inside the docker image!
# It automatically adds the luaxake and xmlatex scripts
RUN mkdir -p /root/texmf/tex/latex
ADD . /root/texmf/tex/latex/ximeraLatex

# Add some needed/convenience setup
RUN ln -s /root/texmf/tex/latex/ximeraLatex/luaxake/luaxake /usr/local/bin/luaxake; \
    ln -s /root/texmf/tex/latex/ximeraLatex/xmScripts/xmlatex /usr/local/bin/xmlatex; \
    git config --global --add safe.directory /code

WORKDIR /code