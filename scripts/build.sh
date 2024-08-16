#!/bin/bash
#
# This script
#  - starts a xake docker container (unless we're already IN a container)
#  - starts xake, with the arguments passed to the script
#  - optionally gets you a shell inside the container
#  - optionally automates lots of other things

# Set environment variable 'export DEBUG=1' and/or use -d option for debugging/tracing

# default docker image to run; overwrite with 'export XAKE_IMAGE=myxake:0.1'
: "${XAKE_IMAGE:=ghcr.io/ximeraproject/xake2023:v2.1}"
# Which folder to mount INSIDE the container, under /code  (use with care: it should contain a build.sh !)
: "${MOUNTDIR:=$(pwd)}"

if [[ -f /.dockerenv ]]  
then
    echo "Running in docker container (with local hostname $HOSTNAME)"
elif [[ -n "$KUBERNETES_SERVICE_HOST" ]] 
then
    echo "Running in kubernetes container ($KUBERNETES_SERVICE_HOST)"
else 
    [[ -n "$DEBUG" ]] && echo "Running $0 on host ($HOSTNAME)"

    if [[ "$1" == "-i" ]]
    then
        INTERACTIVE="-it"
    fi 

    # LOCAL_IP is only needed if you want to serve to a ximeraServer on your localhost; do NOT use URL_XIMERA when using LOCAL_IP
    if [[ "$LOCAL_IP" == "" ]]
    then
        LOCAL_IP=$(set -- $(hostname -I); echo "$1")
        [[ -n "$DEBUG" ]] && echo "Setting LOCAL_IP=$LOCAL_IP"
    fi

    echo "Restarting myself in docker (from image $XAKE_IMAGE)"	
    [[ -n "$DEBUG" ]] && echo  docker run --env LOCAL_IP --env URL_XIMERA --env REPO_XIMERA --env GPG_KEY --env GPG_KEY_ID --network host --rm $INTERACTIVE --mount type=bind,source=$MOUNTDIR,target=/code $XAKE_IMAGE ./build.sh $*
    docker run --env LOCAL_IP --env URL_XIMERA --env REPO_XIMERA --env GPG_KEY --env GPG_KEY_ID --network host --rm $INTERACTIVE --mount type=bind,source=$MOUNTDIR,target=/code $XAKE_IMAGE ./build.sh $*
    exit 
fi

# We're for sure running in a container now

echo "Starting $0 $*"

# utility functions for errorhandling/debugging (and logging to be added ...?)
error() {
        echo "ERROR: $*" >&2
        exit 1
}

debug() {
        [[ -n "$DEBUG" ]] && echo "DEBUG: $*"
}

# Set reasonable defaults for variables
: "${LOCAL_IP:=localhost}"
: "${URL_XIMERA:=http://$LOCAL_IP:2000/}"     # default: publish to ximera-docker-instance, but 'localhost' does refer to THIS container
: "${REPO_XIMERA:=test}"
: "${NB_JOBS:=2}"
: "${XAKE:=xake}"

while getopts ":hitd" opt; do
  case ${opt} in
    h ) 
       cat <<EOF
        Build and publish a ximera-repository to a ximera-server (via bake/frost/serve)

        Publishes to $URL_XIMERA$REPO_XIMERA 

	This script is a (docker-)wrapper to 'xake', and contains some extra convenience-functions for building pdf's .
	
	Usage:
         ./build.sh compile path/to/file.tex
         ./build.sh compilePdf path/to/file.tex
         ./build.sh bake
    	 ./build.sh serve     (does ALSO do frost and setup gpg-keys ...!)
	     ./build.sh -i bash   (start a shell inside the container)
	   
EOF
       exit 0
      ;;
    i )
        echo "Interactive session"
        ;;
    d ) DEBUG=1 
        XAKE="$XAKE -v"
      ;;
    \? ) echo "Usage: build [-h] [-i] <commands>"
	 exit 1
      ;;
  esac
done
shift $((OPTIND -1))
COMMAND=$1


# If there are local versions of ximeraLatex, copy them to the right place  inside the container
if [[ -f .ximera/ximera.4ht ]]; then
    echo "USING ximera.4ht from local repo"
    cp .ximera/ximera.4ht /root/texmf/tex/latex/ximeraLatex/
fi

if [[ -f .ximera/ximera.cls ]]; then
    echo "USING ximera.cls from local repo"
    cp .ximera/ximera.cls /root/texmf/tex/latex/ximeraLatex/
fi

if [[ -f .ximera/ximera.cfg ]]; then
    echo "USING ximera.cfg from local repo"
    cp .ximera/ximera.cfg /root/texmf/tex/latex/ximeraLatex/
fi

if [[ -f .ximera/xourse.cls ]]; then
    echo "USING xourse.cls from local repo"
    cp .ximera/xourse.cls /root/texmf/tex/latex/ximeraLatex/
fi
if [[ -f .ximera/xourse.4ht ]]; then
    echo "USING xourse.4ht from local repo"
    cp .ximera/xourse.4ht /root/texmf/tex/latex/ximeraLatex/
fi

# HACK: is there a better solution for sagelatex ...?
if [[ -f .ximera/sagetex.sty ]]; then
    echo "USING sagetex.sty from local repo"
    cp .ximera/sagetex.sty /root/texmf/tex/latex/ximeraLatex/
fi

# Add anything that might not be installed in the container 
# HACK: hardcoded path ...
#if [[ -d .texmf ]]; then
#    echo "USING .texmf etc from local repo"
#    cp -r .texmf/* /usr/local/texlive/2019/texmf-dist/tex/generic/
#fi

# If there is a .ximera_local folder, OVERWRITE the complete ximeraLatex install inside this container
#  ( This could/should replace the above one-by-one copies from .ximera ...)
if [[ -d .ximera_local ]]; then
    echo "USING .ximera_local from local repo"
    mv /root/texmf/tex/latex/ximeraLatex /root/ximeraLatex.ORI
    mkdir /root/texmf/tex/latex/ximeraLatex
    cp -r .ximera_local/* /root/texmf/tex/latex/ximeraLatex
fi

# Hack: some versions of xake start 'mypdflatex' (instead of hardcoded commands inside the xake-executable)
PATH=$(pwd):$PATH
chmod +x mypdflatex

# Longer lines in pdflatex output
export max_print_line=1000
export error_line=254
export half_error_line=238


# After git clone, ALL files seem recent; try to reset them (to prevent baking all files all the time)
#  (needed in gillab CI/CD ...)
reset_file_times() {
 if find . -maxdepth 1 -name "*.tex" -mtime +1 | grep .
 then
  # .tex files older then 1 day: presumably the git was not checked out just now,
  # and modittimes are correct
  echo "Skipping resetting file times"
 else
  # all .tex files are recent, presumable just after a git clone. This would cause re-compile of everything
  # therefore: restore all modif-dates
  echo "Resetting file times"
  apt install git-restore-mtime    # HACK: this should be in the container image !!!
  # git status   # in DETACHED HEAD in CI !!
  git restore-mtime -f
  ls -al *.tex *.sty *.pdf
 fi
}

if [[ "$COMMAND" == "bash" ]]
then
    # interactive shell (option -i needed when starting the container !)
    ${XAKE%xake} /bin/bash
elif [[ "$COMMAND" == "bake" ]]
then
    # files with beamer are IGNORED by bake and bakePdf   (should only be complied to pdf, not html)
    #  do it 'by hand' here
    reset_file_times
    mkdir -p ximera-downloads
    echo "Copying gif files ..."
    cp pictures/*.gif ximera-downloads
    echo "Compiling beamer and _pdf.tex files ..."
        find \( -name "*beamer*.tex" -o -name "*_pdf.tex" \) -printf '%P\n' | while read file; do
	ls -al ${file%tex}{tex,pdf,svg,log}
        if [[ "$file" -nt "${file/%.tex/.pdf}" ]]
        then
             echo "Compiling $file   (beamer)"
             $XAKE compilePdf $file
             echo "Copying $file to ximera-downloads"
             cp ${file/%.tex/.pdf} ximera-downloads
             echo "Converting $file to svg"
             pdf2svg ${file/%.tex/.pdf} ${file/%.tex/.svg}
        else
             echo "File $file uptodate"
        fi
    done
    echo "Baking other files ..."
    $XAKE  --skip-mathjax --jobs $NB_JOBS bake # Genereer de html files
elif [[ "$COMMAND" == "cleanstandaard" ]]
then
    NAME=standaard
    rm -rf ximera-downloads/"$NAME"_pdf
    find -name "*-$NAME.pdf" -printf '%P\n' | xargs -I{} sh -c 'echo "Removing $1"; rm "$1"' -- {} "$NAME" # remove .pdf's
elif [[ "$COMMAND" == "cleanhandout" ]]
then
    NAME=handout
    rm -rf ximera-downloads/"$NAME"_pdf
    find -name "*-$NAME.pdf" -printf '%P\n' | xargs -I{} sh -c 'echo "Removing $1"; rm "$1"' -- {} "$NAME" # remove .pdf's
elif [[ "$COMMAND" == "bakestandaard" ]]
then
    NAME=standaard
    reset_file_times
    $XAKE --jobs $NB_JOBS bakePdf "$NAME" 
    find -name "*-$NAME.pdf" -printf '%P\n' | xargs -I{} dirname ximera-downloads/"$NAME"_pdf/{} | xargs mkdir -p # create necessairy folders
    find -name "*-$NAME.pdf" -printf '%P\n' | xargs -I{} sh -c 'echo "Move $1 to ximera-downloads"; cp "$1" ximera-downloads/"$2"_pdf/"${1%-*}.pdf" || (echo "Failed moving" && exit 1)' -- {} "$NAME" # Copy to ximera-downloads
elif [[ "$COMMAND" == "bakehandout" ]]
then
    NAME=handout
    # files with _pdf are IGNORED by bake and bakePdf   (should only be complied to pdf, not html)
    #  do it 'by hand' here Needed to create the handouts including formularia
    reset_file_times
    mkdir -p ximera-downloads
    echo "Compiling _pdf.tex files ..."
        find \( -name "*_pdf.tex" \) -printf '%P\n' | while read file; do
	ls -al ${file%tex}{tex,pdf,log}
        if [[ "$file" -nt "${file/%.tex/.pdf}" ]]
        then
             echo "Compiling $file   (beamer)"
             $XAKE compilePdf $file
             cp ${file/%.tex/.pdf} ximera-downloads
             cp ${file/%.tex/.pdf} ${file/%_pdf.tex/-handout_pdf.pdf}
        else
             echo "File $file   uptodate (beamer)"
        fi
    done
    timeout 50m $XAKE --jobs $NB_JOBS bakePdf "$NAME" "\\PassOptionsToClass{handout}{ximera}\\PassOptionsToClass{handout}{xourse}"
    echo "Moving pdfs to ximera-downloads"
    find -name "*-$NAME.pdf" -printf '%P\n' | xargs -I{} dirname ximera-downloads/"$NAME"_pdf/{} | xargs mkdir -p # create necessairy folders
   #find -name "*-$NAME.pdf" -printf '%P\n' | xargs -I{} sh -c 'echo "Move $1 to ximera-downloads"; cp "$1" ximera-downloads/"$2"_pdf/"${1%-*}.pdf" || (echo "Failed moving" && exit 1)' -- {} "$NAME" # Copy to ximera-downloads
    find -name "*-$NAME.pdf" -printf '%P\n' | xargs -I{} sh -c 'cp "$1" ximera-downloads/"$2"_pdf/"${1%-*}.pdf" || (echo "Failed moving" && exit 1)' -- {} "$NAME" # Copy to ximera-downloads

elif [[ "$COMMAND" == "bakebeamer" ]]
then
    # files with beamer are IGNORED by bake ansd bakePdf   (should only be complied to pdf, not html)
    #  do it 'by hand' here
    NAME=handout
    reset_file_times
    echo "Compiling beamer files ..."
    find -name "*beamer*.tex" -printf '%P\n' |grep -v preamble | grep -v handout | while read file; do
	ls -al ${file%tex}{tex,pdf,log}
        if [[ "$file" -nt "${file/%.tex/.pdf}" ]]
        then
            echo "Compiling $file   (beamer)"
            $XAKE compilePdf $file
            $XAKE compilePdf $file  $NAME "\\PassOptionsToClass{handout}{beamer}"
        else
            echo "File $file   uptodate (beamer)"
        fi
        mkdir -p public
        basename=$(basename $file)
        cp ${file/%.tex/.pdf} public/${basename/%.tex/.pdf}
        cp ${file/%.tex/-handout.pdf} public/${basename/%.tex/-handout.pdf}
        mkdir -p $(dirname ximera-downloads/"$NAME"_pdf/$file})
        cp ${file/%.tex/.pdf} ximera-downloads/${NAME}_pdf/${file/%.tex/.pdf}
        cp ${file/%.tex/-handout.pdf} ximera-downloads/${NAME}_pdf/${file/%.tex/-handout.pdf}
    done
    echo "Compiling _pdf files ..."
    find -name "*_pdf.tex" -printf '%P\n' | while read file; do
	ls -al ${file%tex}{tex,pdf,log}
        #if [[ "$file" -nt "${file/%.tex/.pdf}" ]]
        #then
            echo "Compiling $file   (_pdf)"
            $XAKE compilePdf $file
        #else
        #    echo "File $file   uptodate (_pdf)"
        #fi
        mkdir -p public
        basename=$(basename $file)
        cp ${file/%.tex/.pdf} public/${basename/%.tex/.pdf}
        mkdir -p $(dirname ximera-downloads/"$NAME"_pdf/$file})
        cp ${file/%.tex/.pdf} ximera-downloads/${NAME}_pdf/${file/%.tex/.pdf}
    done
elif [[ "$COMMAND" == "serve" ]]
then
    echo "xake serve"
    debug "Loading GPG Key"
    if [[ -f "$GPG_KEY" ]]
    then
        echo "Importing private key from $GPG_KEY"
        # First try import as 'binary' file, if this fails, try base64 decoded version...
        if ! gpg -q $VERBOSE --import $GPG_KEY 
        then
            debug "Importing base64-encode private key from $GPG_KEY"
            cat $GPG_KEY | base64 --decode > .gpg # decode the base64 gpg key
            gpg -q $VERBOSE --import .gpg ||  error "gpg --import failed (encoded key)"
            rm .gpg # remove the gpg key so he is certainly not cached
        fi
    else 
        echo  "Importing private key in variable GPG_KEY"
        echo "$GPG_KEY" >.gpg # | base64 --decode > .gpg # decode the base64 gpg key
        gpg -q $VERBOSE --import .gpg  || error "gpg --import failed (key itself in variable)"
        rm .gpg # remove the gpg key so he is certainly not cached
    fi
    [[ -n "$DEBUG" ]] && gpg --list-keys
    debug "KEYSERVER gpg $VERBOSE --keyserver $URL_XIMERA --send-key $GPG_KEY_ID"
    gpg -q $VERBOSE --keyserver $URL_XIMERA --send-key "$GPG_KEY_ID" || echo "WARNING: gpg sendkey failed (to url $URL_XIMERA)"
    
    echo "xake NAME: on $URL_XIMERA set name to $REPO_XIMERA"
    debug "xake NAME: $XAKE -U $URL_XIMERA -k $GPG_KEY_ID name $REPO_XIMERA"
    $XAKE -U $URL_XIMERA -k "$GPG_KEY_ID" name "$REPO_XIMERA" || error "xake name failed" 

#    echo "Prepare git repo"
#    git fetch --unshallow # Zorg ervoor dat we de hele geschiedenis hebben ipv enkel een deel, anders werkt het serven niet
#   .git config core.fileMode false
#    git branch -D master || true    #ignore error
#    git checkout -B master # doe alsof we op master zitten

    echo "xake FROST"
    $XAKE frost || error "xake frost failed"  # Zorg voor juiste links etc = maak metadata.json en tag etc

    echo "xake SERVE"
    if [[ -n "$DEBUG" ]]
    then
        echo "git status:"
        git status
        echo "git tag -n:"
        git tag -n
        echo "git rev-parse --abbrev-ref --all:"
        git rev-parse --abbrev-ref --all
        echo "git remote -v:"
	    git remote -v
    fi
    $XAKE serve 2>&1 || error "xake serve failed"  # Upload files = push tag
elif [[ "$COMMAND" == "compile" ]]
then
    echo "xake $* (with --skip-mathjax ...)"
    $XAKE --skip-mathjax $*
else
    echo "Passing arguments: starting xake $*"
    xake $*
fi

#exit 0; % would ignore (some) errors; might be relevant in CI/CD context