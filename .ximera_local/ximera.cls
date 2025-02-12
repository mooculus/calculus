%%
%% This is file `ximera.cls',
%% generated with the docstrip utility.
%%
%% The original source files were:
%%
%% ximera.dtx  (with options: `classXimera')
%% src/banner.dtx  (with options: `classXimera')
%% src/options.dtx  (with options: `classXimera')
%% src/packages.dtx  (with options: `classXimera')
%% src/tikzexport.dtx  (with options: `classXimera')
%% src/hyperref.dtx  (with options: `classXimera')
%% src/suppress.dtx  (with options: `classXimera')
%% src/makeCounter.dtx  (with options: `classXimera')
%% src/pagesetup.dtx  (with options: `classXimera')
%% src/metadata.dtx  (with options: `classXimera')
%% src/outcomes.dtx  (with options: `classXimera')
%% src/macros.dtx  (with options: `classXimera')
%% src/theorems.dtx  (with options: `classXimera')
%% src/enumerate.dtx  (with options: `classXimera')
%% src/proof.dtx  (with options: `classXimera')
%% src/only.dtx  (with options: `classXimera')
%% src/problem.dtx  (with options: `classXimera')
%% src/hints.dtx  (with options: `classXimera')
%% src/abstract.dtx  (with options: `classXimera')
%% src/title.dtx  (with options: `classXimera')
%% src/image.dtx  (with options: `classXimera')
%% src/interactives/javascript.dtx  (with options: `classXimera')
%% src/interactives/include.dtx  (with options: `classXimera')
%% src/interactives/geogebra.dtx  (with options: `classXimera')
%% src/interactives/desmos.dtx  (with options: `classXimera')
%% src/interactives/google.dtx  (with options: `classXimera')
%% src/interactives/graph.dtx  (with options: `classXimera')
%% src/link.dtx  (with options: `classXimera')
%% src/interactives/video.dtx  (with options: `classXimera')
%% src/answer.dtx  (with options: `classXimera')
%% src/choice.dtx  (with options: `classXimera')
%% src/solution.dtx  (with options: `classXimera')
%% src/feedback.dtx  (with options: `classXimera')
%% src/freeresponse.dtx  (with options: `classXimera')
%% src/verbatim.dtx  (with options: `classXimera')
%% src/dialogue.dtx  (with options: `classXimera')
%% src/instructornotes.dtx  (with options: `classXimera')
%% src/xkcd.dtx  (with options: `classXimera')
%% src/foldable.dtx  (with options: `classXimera')
%% src/leash.dtx  (with options: `classXimera')
%% src/interactives/sagemath.dtx  (with options: `classXimera')
%% src/jax.dtx  (with options: `classXimera')
%% src/accordion.dtx  (with options: `classXimera')
%% src/ungraded.dtx  (with options: `classXimera')
%% src/clearEnv.dtx  (with options: `classXimera')
%% src/hideEnv.dtx  (with options: `classXimera')
%% src/preamble.dtx  (with options: `classXimera')
%% ------------:| ------------------------------------------------------------
%%       ximera:| Simultaneously writing print and online interactive materials
%%       Author:| Jim Fowler and Oscar Levin and Jason Nowell and Wim Obbels and Hans Parshall and Bart Snapp
%%       E-mail:| bart.snapp@gmail.com
%%      License:| Released under the LaTeX Project Public License v1.3c or later
%%          See:| http://www.latex-project.org/lppl.txt
%% 
\NeedsTeXFormat{LaTeX2e}[1999/12/01]
\ProvidesClass{ximera}
 [2024/05/12 v1.5.1
 Simultaneously write print and online interactive materials]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\let\m\message
\def\w{\m{::}}\def\t{\m{:::}}\def\s{\m{ }}\def\n{\m{^^J}}\def\u{::'}\def\d{'::}\def\v{:::::}
\n
\m{\d.}\s\m{.\u}\w\m{}\m{\v}\s\s\m{\v}\m{}\m{.\v\v\v::::.}\s\m{}\t\n
\s\m{\d.\u}\s\w\t\t\s\t\t\w\m{}\s\s\s\s\s\s\s\t\s\m{\u::}\n
\s\s\t\s\s\w\t\m{}\t\t\m{}\t\m{ ::::\v}\m{.\v:\u}\m{}\m{\u}\m{\d}\n
\s\m{.\u::.}\s\w\t\m{}\t\t\m{}\t\w\s\s\s\s\w\m{}\m{\d.}\s\m{\u}\s\m{\d}\n
\m{.\u}\s\m{\d.}\w\t\s\m{':\u}\s\t\m{\d\v::}\w\s\m{}\m{\d.\u}\s\s\m{\d}\n
\n
\let\w\undefined
\let\t\undefined
\let\s\undefined
\let\n\undefined
\let\u\undefined
\let\d\undefined
\let\v\undefined
\let\m\undefined
\newif\ifhandout
\handoutfalse
\DeclareOption{handout}{\handouttrue}
\newif\ifnoauthor
\noauthorfalse
\DeclareOption{noauthor}{\noauthortrue}
\newif\ifnooutcomes
\nooutcomesfalse
\DeclareOption{nooutcomes}{\nooutcomestrue}
\newif\ifinstructornotes
\instructornotesfalse
\DeclareOption{instructornotes}{\instructornotestrue}
\DeclareOption{noinstructornotes}{\instructornotestrue}
\newif\ifhints
\hintsfalse
\DeclareOption{hints}{\hintstrue}
\newif\ifnewpage
\newpagefalse
\DeclareOption{newpage}{\newpagetrue}
\newif\ifnumbers
\numbersfalse
\DeclareOption{numbers}{\numberstrue}
\newif\ifwordchoicegiven
\wordchoicegivenfalse
\DeclareOption{wordchoicegiven}{\wordchoicegiventrue}
\newif\iffirstinlinechoice% Support for other wordchoice command contents.
\firstinlinechoicetrue

\newif\ifxake
\xakefalse
\DeclareOption{xake}{\xaketrue}

\newif\iftikzexport
\tikzexportfalse
\DeclareOption{tikzexport}{%
  \tikzexporttrue%
  \handoutfalse%
  \numbersfalse%
  \newpagefalse%
  \hintsfalse%
  \nooutcomesfalse%
}

\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{article}%
}
\ProcessOptions\relax
\LoadClass{article}

\ifdefined\HCode
  \xaketrue%
  \tikzexporttrue%
  \handoutfalse%
  \numbersfalse%
  \newpagefalse%
  \hintsfalse%
  \nooutcomesfalse%
\fi


\RequirePackage[makeroom]{cancel}
\RequirePackage[inline]{enumitem}
\RequirePackage[pagestyles]{titlesec}
\RequirePackage{titletoc}
\RequirePackage{titling}
\RequirePackage{url}
\RequirePackage[table]{xcolor}
\RequirePackage{tikz}
\RequirePackage{pgfplots}
\usepgfplotslibrary{groupplots}
\usetikzlibrary{calc}
\RequirePackage{fancyvrb}
\RequirePackage{forloop}
\RequirePackage{environ}% Included to allow saving of environment contents. This does *not* play well with various verbatem environments however and would be great to find a way around utilizing this package. One option is the "Suppress" command included below.
\RequirePackage{amssymb}% Included to have access to math typeset.
\RequirePackage{amsmath}% Included to have access to math typeset.
\RequirePackage{amsthm}%  Included to have access to math typeset.
\RequirePackage{xifthen}% http://ctan.org/pkg/xifthen
\RequirePackage{multido}% http://ctan.org/pkg/multido
\RequirePackage{listings} %% is this required???

\RequirePackage{xkeyval}

\RequirePackage{comment}
\RequirePackage{gettitlestring}
\RequirePackage{nameref}
\RequirePackage{epstopdf}
\ifdefined\reallyneverever

\ifdefined\HCode
  \tikzexporttrue
\fi

\iftikzexport
  \usetikzlibrary{external}

  \ifdefined\HCode
    % in htlatex, just include the svg files
    \def\pgfsys@imagesuffixlist{.svg}

    \tikzexternalize[prefix=./,mode=graphics if exists]
  \else
    % in pdflatex, actually generate the svg files
    \tikzset{
      /tikz/external/system call={
        pdflatex \tikzexternalcheckshellescape
        -halt-on-error -interaction=batchmode
        -jobname "\image" "\\PassOptionsToClass{tikzexport}{ximera}\texsource";
        mutool draw -F svg \image.pdf > \image.svg ;     % mutool adds "1" to filename ????
        mutool draw -o \image.svg \image.pdf ;
        mutool draw -r 150 -c rgbalpha -o \image.png \image.pdf ;
        ebb -x \image.png
      }
    }
    \tikzexternalize[optimize=false,prefix=./]
  \fi

  \fi
\fi
\ifdefined\HCode
\RequirePackage{hyperref}
\else
\RequirePackage[pdfpagelabels,colorlinks=true,allcolors=blue!30!black]{hyperref}
\pdfstringdefDisableCommands{\def\hskip{}}%% quiets warning
\fi
\font\dummyft@=dummy \relax
\def\suppress{%
  \begingroup\par
  \parskip\z@
  \offinterlineskip
  \baselineskip=\z@skip
  \lineskip=\z@skip
  \lineskiplimit=\maxdimen
  \dummyft@
  \count@\sixt@@n
  \loop\ifnum\count@ >\z@
    \advance\count@\m@ne
    \textfont\count@\dummyft@
    \scriptfont\count@\dummyft@
    \scriptscriptfont\count@\dummyft@
  \repeat
  \let\selectfont\relax
  \let\mathversion\@gobble
  \let\getanddefine@fonts\@gobbletwo
  \tracinglostchars\z@
  \frenchspacing
  \hbadness\@M}
\def\endsuppress{\par\endgroup}
\newcommand{\Make@Counter}[1]{% This is an internal macro that should probably be depreciated for the below universal macro.
  \@ifundefined{c@#1}% Check to see if counter exists
       {     % If not, create it and set it to 0.
\newcounter{#1}
\setcounter{#1}{0}
}
{%If so, reset to 0.
\setcounter{#1}{0}
}
}

\newcommand{\MakeCounter}[1]{%% Code located in "Utilitymacros.dtx"
  \@ifundefined{c@#1}% Check to see if counter exists
       {     % If not, create it and set it to 0.
\newcounter{#1}
\setcounter{#1}{0}
}
{%If so, reset to 0.
\setcounter{#1}{0}
}
}

\setlength{\parindent}{0pt}
\setlength{\parskip}{5pt}
\oddsidemargin 62pt
\evensidemargin 62pt
\textwidth 345pt
\headheight 14pt

\newcommand{\license}{\excludecomment}

\newcommand{\acknowledgement}{\excludecomment}

\renewcommand{\tag}{\excludecomment}
\def\theoutcomes{}

\ifdefined\HCode%
  \newcommand{\outcome}[1]{}
\else%
  \newwrite\outcomefile
  \immediate\openout\outcomefile=\jobname.oc

  \newcommand{\outcome}[1]{\edef\theoutcomes{\theoutcomes #1~}%
  \immediate\write\outcomefile{\unexpanded{\outcome}{#1}}}
  \fi%
\everymath{\displaystyle}
\let\prelim\lim
\renewcommand{\lim}{\displaystyle\prelim}
\theoremstyle{definition} % No italic (because this makes also text in TikZ italic !!!)


      \newtheorem{theorem}{Theorem}

      \newtheorem{algorithm}{Algorithm}

      \newtheorem{axiom}{Axiom}

      \newtheorem{claim}{Claim}

      \newtheorem{conclusion}{Conclusion}

      \newtheorem{condition}{Condition}

      \newtheorem{conjecture}{Conjecture}

      \newtheorem{corollary}{Corollary}

      \newtheorem{criterion}{Criterion}

      \newtheorem{definition}{Definition}

      \newtheorem{example}{Example}

      \newtheorem*{explanation}{Explanation}

      \newtheorem{fact}{Fact}

      \newtheorem{lemma}{Lemma}

      \newtheorem{formula}{Formula}

      \newtheorem{idea}{Idea}

      \newtheorem{notation}{Notation}

      \newtheorem{model}{Model}

      \newtheorem{observation}{Observation}

      \newtheorem{proposition}{Proposition}

      \newtheorem{paradox}{Paradox}

      \newtheorem{procedure}{Procedure}

      \newtheorem{remark}{Remark}

      \newtheorem{summary}{Summary}

      \newtheorem{template}{Template}

      \newtheorem{warning}{Warning}
\renewcommand{\theenumi}{\textup{(\alph{enumi})}}
\renewcommand{\labelenumi}{\theenumi}
\renewcommand{\theenumii}{\textup{(\roman{enumii})}}
\renewcommand{\labelenumii}{\theenumii}
\renewcommand{\qedsymbol}{$\blacksquare$}
\renewenvironment{proof}[1][\proofname]
  {\begin{trivlist}\item[\hskip \labelsep \itshape \bfseries #1{}\hspace{2ex}]}
{\qed\end{trivlist}}


\ifxake
        \newenvironment{prompt}{}{}
\else
\ifhandout
\NewEnviron{prompt}{}
    % Breaks when put in mathmode ?
    % \newenvironment{prompt}{\suppress}{\endsuppress}
\else
\newenvironment{prompt}{\bgroup\color{gray!50!black}}{\egroup}
\fi
\fi
\ifdefined\HCode
\newenvironment{onlyPdf}{\setbox0\vbox\bgroup}{\egroup}
\newenvironment{onlyHtml}{\bgroup}{\egroup}
\newenvironment{onlineOnly}{\bgroup}{\egroup}
\else
\newenvironment{onlyPdf}{\bgroup}{\egroup}
\ifdefined\xmPrintHtmlOnlyAlsoInPdf
\newenvironment{onlyHtml}{\bgroup\color{red!50!black}}{\egroup}
\newenvironment{onlineOnly}{\bgroup\color{red!50!black}}{\egroup}
\else
\newenvironment{onlyHtml}{\setbox0\vbox\bgroup}{\egroup}
\newenvironment{onlineOnly}{\setbox0\vbox\bgroup}{\egroup}
\fi
\fi


\ifdefined\HCode
\newcommand{\pdfOnly}[1]{}
\newcommand{\htmlOnly}[1]{#1}
\else
\ifdefined\xmPrintHtmlOnlyAlsoInPdf
\newcommand{\pdfOnly}[1]{#1}
\newcommand{\htmlOnly}[1]{\bgroup\color{red!50!black}#1\egroup}
\else
\newcommand{\pdfOnly}[1]{#1}
\newcommand{\htmlOnly}[1]{}
\fi
\fi

\providecommand{\ifonlineTF}[2]{\htmlOnly{#1}\pdfOnly{#2}}
\newif{\ifonline}
\ifdefined\HCode
\onlinetrue
\else
\onlinefalse
\fi


\providecommand{\latexProblemContent}[1]{#1}
\Make@Counter{Iteration@probCnt}
\newcommand{\hang}{% top theorem decoration
  \begingroup%
  \setlength{\unitlength}{.005\linewidth}% \linewidth/200
    \begin{picture}(0,0)(1.5,0)%
      \linethickness{1pt} \color{black!50}%
      \put(-3,2){\line(1,0){206}}% Top line
      \multido{\iA=2+-1,\iB=50+-10}{5}{% Top hangs
        \color{black!\iB}%
        \put(-3,\iA){\line(0,-1){1}}% Top left hang
        %\put(203,\iA){\line(0,-1){1}}% Top right hang
      }%
    \end{picture}%
  \endgroup%
}%
\newcommand{\hung}{% bottom theorem decoration
  \nobreak
  \begingroup%
    \setlength{\unitlength}{.005\linewidth}% \linewidth/200
    \begin{picture}(0,0)(1.5,0)%
      \linethickness{1pt} \color{black!50}%
      \put(60,0){\line(1,0){143}}% Bottom line
      \multido{\iA=0+1,\iB=50+-10}{5}{% Bottom hangs
        \color{black!\iB}%
        %\put(-3,\iA){\line(0,1){1}}% Bottom left hang
        \put(203,\iA){\line(0,1){1}}% Bottom right hang
        \put(\iB,0){\line(60,0){10}}% Left fade out
      }%
    \end{picture}%
  \endgroup%
}%
\MakeCounter{problem}
\newcommand{\problemNumber}{
\ifcsname c@depth\Roman{problem@Depth}Count\endcsname% Check to see if counter exists
\else
\expandafter\newcounter{depth\Roman{problem@Depth}Count}
\expandafter\setcounter{depth\Roman{problem@Depth}Count}{0}
\fi

\expandafter\stepcounter{depth\Roman{problem@Depth}Count}
\arabic{depthICount}% The first problem depth, what use to be |\theproblem|.

\forloop{Iteration@probCnt}{2}{\arabic{Iteration@probCnt} < \numexpr \value{problem@Depth} + 1 \relax}{%
    .\expandafter\arabic{depth\Roman{Iteration@probCnt}Count}% Get the problem number of the next depth level and append it with a ".".
}
}

%%%%%% Configure various problem environment commands
\Make@Counter{problem@Depth}

%%%% Configure environments start content

\newcommand{\problemEnvironmentStart}[2]{%

\stepcounter{problem@Depth}% Started a problem, so we've sunk another problem layer.
\def\spaceatend{#1}%
\begin{trivlist}%
\item%
  [%
    \hskip\labelsep\sffamily\bfseries
    #2 \problemNumber% Determine the correct number of the problem, and the format of that number.
]%
\slshape
}

%%%%% Configure environments end content

\newcommand{\problemEnvironmentEnd}{%This configures all the end content for a problem.
\stepcounter{problem@Depth}
\ifcsname c@depth\Roman{problem@Depth}Count\endcsname
\expandafter\ifnum\expandafter\value{depth\Roman{problem@Depth}Count}>0
\expandafter\setcounter{depth\Roman{problem@Depth}Count}{0}
\fi
\fi

\addtocounter{problem@Depth}{-2}% Exited a problem so we've exited a problem layer. Need -2 because we steppped once at the start to check for needing a depth-level count reset.


\ifhandout
\ifnewpage
\newpage
\fi
\fi
\end{trivlist}
}

%%%% Now populate the old environment names

\newenvironment{problem}[1][2in]%
{%Env start code
\problemEnvironmentStart{#1}{Problem}
}
{%Env end code
\problemEnvironmentEnd
}

\newenvironment{exercise}[1][2in]%
{%Env start code
\problemEnvironmentStart{#1}{Exercise}
}
{%Env end code
\problemEnvironmentEnd
}

\newenvironment{exploration}[1][2in]%
{%Env start code
\problemEnvironmentStart{#1}{Exploration}
}
{%Env end code
\problemEnvironmentEnd
}

\newenvironment{question}[1][2in]%
{%Env start code
\problemEnvironmentStart{#1}{Question}
}
{%Env end code
\problemEnvironmentEnd
}

\newcounter{hintLevel}
\setcounter{hintLevel}{0}
\newenvironment{hint}{}{}
\renewenvironment{hint}
{
\ifhandout
\setbox0\vbox\bgroup
\else
\begin{trivlist}\item[\hskip \labelsep\small\slshape\bfseries Hint:\hspace{2ex}]
\small\slshape
\fi
\stepcounter{hintLevel}
}
{
\ifhandout
\egroup\ignorespacesafterend
\else
\end{trivlist}
\fi
\addtocounter{hintLevel}{-1}
}

\ifhints
\renewenvironment{hint}{
\begin{trivlist}\item[\hskip \labelsep\small\slshape\bfseries Hint:\hspace{2ex}]
\small\slshape}
{\end{trivlist}}
\fi

\let\abstract\relax
\let\endabstract\relax
\NewEnviron{abstract}{\protected@xdef\theabstract{\BODY}}
\let\@emptyauthor\@author
\def\author#1{\gdef\@author{#1}}
\def\@author{\@latex@warning@no@line{No \noexpand\author given}}
\def\and{and }

\let\title\relax
\newcommand{\title}[1][]{{\protected@xdef\@pretitle{#1}}\protected@xdef\@title}

\title{}

\newcounter{titlenumber}
\renewcommand{\thetitlenumber}{\arabic{titlenumber}}
\setcounter{titlenumber}{0}

\newpagestyle{main}{
\sethead[\textsl{\ifnumbers\thetitlenumber\hspace{1em}\fi\@title}][][] % even
{}{}{\textsl{\ifnumbers\thetitlenumber\hspace{1em}\fi\@title}} % odd
\setfoot[\thepage][][] % even
{}{}{\thepage} % odd
}
\pagestyle{main}
\renewcommand\maketitle{%
  \addtocounter{titlenumber}{1}%
  {\flushleft\large\bfseries \@pretitle\par\vspace{-1em}}
  {\flushleft\LARGE\bfseries {\ifnumbers\thetitlenumber\fi}{\ifnumbers\hspace{1em}\else\hspace{0em}\fi}\@title \par }
  \phantomsection%
  \ifnumbers\addcontentsline{toc}{section}{\thetitlenumber~\@title}\else\addcontentsline{toc}{section}{\@title}\fi
  \vskip .6em\noindent\textit\theabstract\setcounter{problem}{0}\setcounter{section}{0}\setcounter{subsection}{0}\par\vspace{2em}
  \ifnooutcomes\else\let\thefootnote\relax\footnote{Learning outcomes: \theoutcomes}\fi
  \ifnoauthor\else\let\thefootnote\relax\footnote{Author(s):~\@author}\fi
  \aftergroup\@afterindentfalse
  \aftergroup\@afterheading}

\ifnumbers
\setcounter{secnumdepth}{2}
\renewcommand{\thesection}{\arabic{titlenumber}.\arabic{section}}
\renewcommand{\thesubsection}{\arabic{titlenumber}.\arabic{section}.\arabic{subsection}}
\else
\setcounter{secnumdepth}{-2}
\fi

\def\activitystyle{}
\newcounter{sectiontitlenumber}
\setcounter{secnumdepth}{2}
\setcounter{tocdepth}{2}
\newcommand\chapterstyle{%
  \def\activitystyle{activity-chapter}
  \def\maketitle{%
    \addtocounter{titlenumber}{1}%
                    {\flushleft\small\sffamily\bfseries\@pretitle\par\vspace{-1.5em}}%
                    {\flushleft\LARGE\sffamily\bfseries\thetitlenumber\hspace{1em}\@title \par }%
                    {\vskip .6em\noindent\textit\theabstract\setcounter{problem}{0}\setcounter{section}{0}}%
                    \par\vspace{2em}
                    \phantomsection\addcontentsline{toc}{section}{\textbf{\thetitlenumber\hspace{1em}\@title}}%
}}

\newcommand\sectionstyle{%
  \def\activitystyle{activity-section}
  \def\maketitle{%
    \addtocounter{section}{1}
    \setcounter{sectiontitlenumber}{\value{section}}
    {\flushleft\small\sffamily\bfseries\@pretitle\par\vspace{-1.5em}}%
    {\flushleft\Large\sffamily\bfseries\thetitlenumber.\thesectiontitlenumber\hspace{1em}\@title \par}%
    {\vskip .6em\noindent\textit\theabstract\setcounter{subsection}{0}}%
    \par\vspace{2em}
    \phantomsection\addcontentsline{toc}{section}{\thetitlenumber.\thesectiontitlenumber\hspace{1em}\@title}%
 \renewcommand\section{\@startsection{subsection}{2}{\z@}%
                                       {-3.25ex\@plus -1ex \@minus -.2ex}%
                                       {1.5ex \@plus .2ex}%
                                       {\normalfont\large\bfseries}}

 \renewcommand\subsection{\@startsection{subsubsection}{3}{\z@}%
                                          {-3.25ex\@plus -1ex \@minus -.2ex}%
                                          {1.5ex \@plus .2ex}%
                                          {\normalfont\normalsize\bfseries}}

}}

\iftikzexport%% allows xake to handle \chapterstyle and \sectionstye
\renewcommand\chapterstyle{\def\activitystyle{chapter}}
\renewcommand\sectionstyle{\def\activitystyle{section}}
\else
\fi

\providecommand{\xmDefaultGraphicsPath}{/xmPictures}
\graphicspath{  %% When looking for images,
{./}            %% look here first,
{.\xmDefaultGraphicsPath/}   %% then look for a pictures folder,
{..\xmDefaultGraphicsPath/}   %% then look for a pictures folder,
{../..\xmDefaultGraphicsPath/}   %% then look for a pictures folder,
{../../..\xmDefaultGraphicsPath/}   %% then look for a pictures folder,
}
\NewEnviron{image}[1][3in]{%
  \begin{center}\resizebox{#1}{!}{\BODY}\end{center}% resize and center
}
\newcommand{\alt}[1]{}


\DefineVerbatimEnvironment{javascript}{Verbatim}{numbers=left,frame=lines,label=JavaScript,labelposition=topline}


\def\js#1{\mbox{\texttt{\detokenize{#1}}}}


\define@key{interactive}{id}{\def\interactive@id{#1}}
\setkeys{interactive}{id=}
\newcommand{\includeinteractive}[2][]{
\setkeys*{interactive}{#1}%
\ifthenelse{\equal{\interactive@id}{}}{}{\recordvariable{\interactive@id}}
Interactive
}

\newcommand{\geogebra}[3]{GeoGebra link: \url{https://www.geogebra.org/m/#1}}
\newcommand{\desmos}[3]{Desmos link: \url{https://www.desmos.com/calculator/#1}}
\newcommand{\desmosThreeD}[3]{Desmos3D link: \url{https://www.desmos.com/3d/#1}}
\newcommand{\googleSheet}[5]{%
  Google Spreadsheet link: \url{https://docs.google.com/spreadsheets/d/#1}%
}


\newcommand{\graph}[2][]{\text{Graph of $#2$}}


\newcommand*{\link}[2][]{#1%
\ifthenelse{\equal{#1}{}}%
{\footnote{Link: \url{#2}}}%
{\footnote{See #1 at \url{#2}}}
}

\newcommand{\youtube}[1]{YouTube link: \url{https://www.youtube.com/watch?v=#1}}

\ifdefined\HCode
\newcommand{\recordvariable}[1]{}
\else
\newwrite\idfile
\immediate\openout\idfile=\jobname.ids
\newcommand{\recordvariable}[1]{\ifthenelse{\equal{#1}{}}{}{\immediate\write\idfile{var #1;}}}
\fi
\define@key{answer}{given}[true]{\def\ans@given{#1}}
\define@key{answer}{tolerance}{\def\ans@tol{#1}}
\define@key{answer}{validator}{}
\define@key{answer}{id}{\def\ans@id{#1}}
\define@key{answer}{format}{}
\define@key{answer}{onlinenoinput}[false]{}
\define@key{answer}{onlineshowanswerbutton}[false]{}
\setkeys{answer}{id=,given=false,onlinenoinput=false,onlineshowanswerbutton=false}

\newcommand{\answerFormatLength}{2cm}

\newcommand{\answerFormatDots}[1]{\ldots\ldots}
\newcommand{\answerFormatLine}[1]{\protect\rule{\answerFormatLength}{0.4pt}}
\newcommand{\answerFormatFlexibleLine}[1]{\protect\rule{\widthof{$#1$}*2}{0.4pt}}
\newcommand{\answerFormatFlexibleBox}[1]{\fbox{\scalebox{2}{\phantom{$#1$}}}}

\newcommand{\answerFormatPlain}[1]{\ensuremath{#1}}
\newcommand{\answerFormatBlue}[1]{\color{blue}\ensuremath{#1}}
\newcommand{\answerFormatBoxed}[1]{\fbox{\ensuremath{#1}}}
\newcommand{\answerFormatBoxedGiven}[1]{\underset{\scriptstyle\mathrm{given}}{\fbox{\ensuremath{#1}}}}

\let\handoutAnswerFormat\answerFormatDots
\let\defaultAnswerFormat\answerFormatBlue
\let\givenAnswerFormat\answerFormatBoxedGiven

\newcommand{\answer}[2][]{%
\ifmmode%
\setkeys{answer}{#1}%
\recordvariable{\ans@id}
\ifthenelse{\boolean{\ans@given}}
{% Start then statement
\ifhandout
#2
\else
\givenAnswerFormat{#2} %% in case the argument helps formatting
\fi
}% End then statement
{% Start else statement
\ifhandout
\handoutAnswerFormat{#2} %% in case the argument helps formatting
\else% show answer in box outside handout mode
\defaultAnswerFormat{#2} %% in case the argument helps formatting
\fi
}% End else statement
\else%
\GenericError{\space\space\space\space}% Throw an error based on... something? -- Jason
{Attempt to use \@backslashchar answer outside of math mode}
{See https://github.com/ximeraProject/ximeraLatex for explanation.}
{Need to use either inline or display math.}%
\fi
}
\define@key{choice}{value}[]{\def\choice@value{#1}}
\define@boolkey{choice}{correct}[true]{\def\choice@correct{#1}}
\define@key{multipleChoice}{id}{\def\mc@id{#1}}
\define@key{otherchoice}{value}[]{\def\otherchoice@value{#1}}
\define@boolkey{otherchoice}{correct}[true]{\def\otherchoice@correct{#1}}
\setkeys{choice}{correct=false,value=}
\setkeys{multipleChoice}{id=}
\setkeys{otherchoice}{correct=false,value=}
\newcommand{\choice}[2][]{%
\setkeys{choice}{#1}%
\item{#2}
\ifthenelse{\boolean{\choice@correct}}
    {% Begin then result
    \ifhandout% if it's a handout do nothing.
    \else% otherwise place a checkmark when you select the "correct choice"... maybe? -- Jason
        \,\checkmark\,\setkeys{choice}{correct=false}
    \fi
    }% End then result
    {}% Begin/End else result.
}

\newcommand{\choiceEXP}[2][]{%
\expandafter\setkeys\expandafter{choice}{#1}%
\item{#2}
\ifthenelse{\boolean{\choice@correct}}
{% Begin then result
\ifhandout
\else
\,\checkmark\,\setkeys{choice}{correct=false}
\fi
}% End then result
{}% Begin/End else result.
} %% note all the {} are needed in case the choice has [] in it.

\newcommand{\otherchoice}[2][]{%
\ignorespaces%
\setkeys{otherchoice}{#1}%
\ifthenelse{\boolean{\otherchoice@correct}}%
{% Start then result
#2\ignorespaces\setkeys{otherchoice}{correct=false}\ignorespaces%
}% End then result
{}% Start/End else result
\ignorespaces%
}%
\newcommand{\inlinechoice}[2][]{%
\setkeys{choice}{#1}%
\iffirstinlinechoice
(\hspace{-.25em}
\firstinlinechoicefalse
\else
/
\fi
#2
\ifthenelse{\boolean{\choice@correct}}%
{% Start then result
\ifhandout\else\checkmark\ignorespaces\setkeys{choice}{correct=false}\ignorespaces\fi%
}% End then result
{}% Start/End else result
\hspace{-.25em}\ignorespaces%
}


\newenvironment{multipleChoice}[1][]
{% Environment Start Code
\setkeys{multipleChoice}{#1}%
\recordvariable{\mc@id}%
\begin{trivlist}
\item[\hskip \labelsep\small\bfseries Multiple Choice:]\hfil
\begin{enumerate}
}% Note this means that \item has to be the first line after \begin{multipleChoice}.
{% Environment End Code
\end{enumerate}
\end{trivlist}
}

\newenvironment{multipleChoice@}[1][]{}{)}


\newcommand{\wordChoice}[1]{%
\let\choicetemp\choice% Assign a "choicetemp" command to duplicate choice.
\ifwordchoicegiven% If wordchoice option is on, we need to juggle around some definitions.
\let\choice\otherchoice%
#1
\else% If it isn't the regular "choice" command should work.
\let\choice\inlinechoice%
\begin{multipleChoice@}%
#1%
\end{multipleChoice@}%
\fi%
\let\choice\choicetemp% Now that choicetmp has been manipulated to what we want, replace choice with it.
}%


\newenvironment{selectAll}[1][]
{\begin{trivlist}\item[\hskip \labelsep\small\bfseries Select All Correct Answers:]\hfil\begin{enumerate}}
    {\end{enumerate}\end{trivlist}}



%% solution environment
\ifhandout % what follows is handout behavior
\newenvironment{solution}%
       {%
 \setbox0\vbox\bgroup
       }
               {%
 \egroup
       }
\else
\newenvironment{solution}%
       {%
 \begin{trivlist}
 \item[\hskip \labelsep\bfseries Solution:\hspace{2ex}]
       }
       % %% line at the bottom}
       {
\end{trivlist}
 % (202410: no longer \par\addvspace{.5ex}\nobreak\noindent\hung
       }
\fi

\newcommand{\PH@Command}{}
\newenvironment{validator}[1][]{
\def\PH@Command{#1}% Use PH@Command to hold the content and be a target for "\expandafter" to expand once.
\mbox{\texttt{\detokenize\expandafter{\PH@Command}}}% Now expand PH@Command once and then detokenize.
}{}
\ifhandout%
\newenvironment{feedback}
               {%
 \setbox0\vbox\bgroup
       }
               {%
 \egroup
       }
\else
\newenvironment{feedback}[1][attempt]{

\def\PH@Command{#1}% Use PH@Command to hold the content and be a target for "\expandafter" to expand once.

\begin{trivlist}% Begin the trivlist to use formating of the "Feedback" label.
\item[\hskip \labelsep\small\slshape\bfseries Feedback% Format the "Feedback" label. Don't forget the space.
(\texttt{\detokenize\expandafter{\PH@Command}}):% Format (and detokenize) the condition for feedback to trigger
\hspace{2ex}]\small\slshape% Insert some space before the actual feedback given.
}{
\end{trivlist} 
}

\fi
\newboolean{given} %% required for freeResponse
\setboolean{given}{true} %% could be replaced by a key=value pair later if needed

\ifhandout
\newenvironment{freeResponse}[1][false]%
{%
\def\givenatend{\boolean{#1}}
\ifthenelse{\boolean{#1}}
{% Begin then result
\begin{trivlist}
\item
}% End then result
{% Begin else result
\setbox0\vbox\bgroup
}% End else result
}
{%
\ifthenelse{\givenatend}
{% Begin then result
\end{trivlist}
}% End then result
{% Begin else result
\egroup
}% End else result
}
\else
\newenvironment{freeResponse}[1][false]%
{% Environment Beginning Code
  \ifthenelse{\boolean{#1}}%% Could probably change this with just putting the (given) in the boolean?-- Jason
   {% Begin then result
   \begin{trivlist}
   \item[\hskip \labelsep\bfseries Free Response (Given):\hspace{2ex}]
   }% End then result
{% Begin else result
\begin{trivlist}
\item[\hskip \labelsep\bfseries Free Response:\hspace{2ex}]
}% End else result
}
{% Environment Ending Code
\end{trivlist}
}
\fi


\DefineVerbatimEnvironment{code}{Verbatim}{numbers=left,frame=lines,label=Code,labelposition=topline}
\DefineVerbatimEnvironment{python}{Verbatim}{numbers=left,frame=lines,label=Python,labelposition=topline}
\DefineVerbatimEnvironment{javascriptCode}{Verbatim}{numbers=left,frame=lines,label=JavaScript,labelposition=topline}
%%% On the web, translate verbatim and lstlisting blocks into |<pre>|
%%% elements.
%%%    \begin{macrocode}
%%%<*cfgXimera>
%%\ConfigureEnv{verbatim}{\ifvmode\IgnorePar\fi\EndP\HCode{<pre style="white-space: pre; background-color: lightgray;" >}}{\ifvmode\IgnorePar\fi\EndP\HCode{</pre>}}{}{}
%%\ConfigureEnv{lstlisting}{\ifvmode\IgnorePar\fi\EndP\HCode{<pre>}}{\ifvmode\IgnorePar\fi\EndP\HCode{</pre>}}{}{}
%%%</cfgXimera>
%%%    \end{macrocode}
\newenvironment{dialogue}{%
   \renewcommand\descriptionlabel[1]{\hspace{\labelsep}\textbf{##1:}}
   \begin{description}%
}{%
   \end{description}%
}

%% instructor intro/instructor notes
%%
\ifhandout % what follows is handout behavior
\ifinstructornotes
\newenvironment{instructorIntro}%
       {%
 \begin{trivlist}
 \item[\hskip \labelsep\bfseries Instructor Introduction:\hspace{2ex}]
}
       % %% line at the bottom}
       {
 \end{trivlist}
 \par\addvspace{.5ex}\nobreak\noindent\hung
       }
\else
\newenvironment{instructorIntro}%
       {%
 \setbox0\vbox\bgroup
       }
       {%If this mysteriously starts breaking
                        % remove \ignorespacesafterend
 \egroup\ignorespacesafterend
       }
               \fi
\else% for handout, so what follows is default
\ifinstructornotes
\newenvironment{instructorIntro}%
       {%
         \setbox0\vbox\bgroup
       }
{%
  \egroup
}
                \else
        \newenvironment{instructorIntro}%
{%
  \begin{trivlist}
  \item[\hskip \labelsep\bfseries Instructor Introduction:\hspace{2ex}]
}
{
  \end{trivlist}
  \par\addvspace{.5ex}\nobreak\noindent\hung
}
                \fi
\fi

%% instructorNotes environment
\ifhandout % what follows is handout behavior
\ifinstructornotes
\newenvironment{instructorNotes}%
       {%
 \begin{trivlist}
 \item[\hskip \labelsep\bfseries Instructor Notes:\hspace{2ex}]
       }
       % %% line at the bottom}
       {
\end{trivlist}
 \par\addvspace{.5ex}\nobreak\noindent\hung
       }
       \else
\newenvironment{instructorNotes}%
       {%
         \setbox0\vbox\bgroup
       }
{%
  \egroup
}
                \fi
\else% for handout, so what follows is default
\ifinstructornotes
\newenvironment{instructorNotes}%
       {%
 \setbox0\vbox\bgroup
       }
       {%
 \egroup
       }
       \else
       \newenvironment{instructorNotes}%
              {%
        \begin{trivlist}
        \item[\hskip \labelsep\bfseries Instructor Notes:\hspace{2ex}]
              }
              % %% line at the bottom}
              {
        \end{trivlist}
        \par\addvspace{.5ex}\nobreak\noindent\hung
              }
                      \fi
                              \fi

\newcommand{\xkcd}[1]{#1}

\colorlet{textColor}{black} % since textColor is referenced below
\colorlet{background}{white} % since background is referenced below

%% pretty-foldable
\newenvironment{foldable}{%
}{%
}

%% pretty-expandable
%% Overwritten in .4ht, but probably also in accordion!
\ifdefined\xmNotExpandableAsAccordion
\newenvironment{expandable}{}{}
\else
\newenvironment{expandable}[2]{}{}
\fi

\newcommand{\unfoldable}[1]{#1}


\newenvironment{leash}[1]{%
}{%
}


\IfFileExists{sagetex.sty}{\RequirePackage{sagetex}}{}

\DefineVerbatimEnvironment{sageCell}{Verbatim}{numbers=left,frame=lines,label=SAGE,labelposition=topline}

\DefineVerbatimEnvironment{sageOutput}{Verbatim}{numbers=left,frame=lines,label=SAGE-Output,labelposition=topline}


%% Pre-202412: .jax file written in non-\HCode, and in a next run inserted by ximera.cfg in .html file
%% Post-202501: .mjax file written only in \HCode, and in luaxake post-processing inserted in .html file
%%   ( used luaxake rather than sed ...)
\newwrite\myfile
\ifdefined\HCode
\immediate\openout\myfile=\jobname.xmjax

%% From |only.dtx| we must also create |prompt| on the MathJax side.
\immediate\write\myfile{\unexpanded{\newenvironment}{prompt}{}{}}

%% Write all newcommands to .xmjax file, that will be included in the .html via luaxake
\let\@oldargdef\@argdef
\long\def\@argdef#1[#2]#3{%
\immediate\write\myfile{\unexpanded{\newcommand}{\unexpanded{#1}}[\unexpanded{#2}]{\unexpanded{#3}}}%
\@oldargdef#1[#2]{#3}%
}

%% Same for \DeclareMathOperator
\let\@OldDeclareMathOperator\DeclareMathOperator
\renewcommand{\DeclareMathOperator}[2]{\@OldDeclareMathOperator{#1}{#2}\immediate\write\myfile{\unexpanded{\DeclareMathOperator}{\unexpanded{#1}}{\unexpanded{#2}}}}

\fi


\colorlet{textColor}{black} % since textColor is referenced below
\colorlet{background}{white} % since background is referenced below

%% accordion container
\newenvironment{accordion}{%
}{%
}
%% pretty-accordion
\iftikzexport
  \newenvironment{accordion-item}[1][]{%
  }{%
  }
\else
  \newenvironment{accordion-item}[1][]{%
  \paragraph{#1}
  }{%
  }
\fi

\newenvironment{ungraded}{}{}
\newcommand{\clearEnv}[1]{
    %% Syntax: \clearEnv{envName}
    %   #1 is envName is the name of the environment you want to clear. This will (re)define the
    %       begin and end environments, as well as the internal counter from \newtheoremenv to \relax.
    \expandafter\let\csname #1\endcsname\relax
    \expandafter\let\csname end#1\endcsname\relax
    \expandafter\let\csname c@#1\endcsname\relax
    }

\newcommand{\hideEnv}[2][]{
    %% Syntax: \hideEnv[NewCode]{environmentName}

    \expandafter\def\csname temp@#2\endcsname\csname #2\endcsname
    \expandafter\def\csname temp@end#2\endcsname\csname end#2\endcsname
    \expandafter\def\csname#2\endcsname{
        \ifnum\value{depth@Check}<1
        Suppress Should start here.
        \suppress
        \fi
        \stepcounter{depth@Check}

        }
    \expandafter\def\csname end#2\endcsname{
        \addtocounter{depth@Check}{-1}
        \ifnum\value{depth@Check}<1
        Suppress Should End Here.
        \endsuppress
        \fi

    \noexpand{#1}
    }
    }

\def\input@path{{./}{../}{../../}{../../../}}    % Mmm, do we need to reset it to the previous value ?
\providecommand{\xmDefaultPreamble}{xmPreamble.tex}
    \IfFileExists{\xmDefaultPreamble}
    {
        \typeout{Loading Ximera defaultPreamble \xmDefaultPreamble}
        \input{\xmDefaultPreamble}
    }{
        \typeout{Info: No default preamble loaded (\xmDefaultPreamble)}
    }
\providecommand{\xmDefaultPrintstyle}{xmPrintstyle.sty}
\iftikzexport\else   % only in PDF
    \IfFileExists{\xmDefaultPrintstyle}
    {
        \typeout{Loading Ximera defaultPrintstyle \xmDefaultPrintstyle}
        \input{\xmDefaultPrintstyle}
    }{
        \typeout{Info: No default printstyle loaded (\xmDefaultPrintstyle)}
    }
\fi


%% 
%% Copyright (C) 2024 by Bart Snapp <bart.snapp@gmail.com> and Jim Fowler <kisonecat@gmail.com>
%% 
%% This work may be distributed and/or modified under the
%% conditions of the LaTeX Project Public License (LPPL), either
%% version 1.3c of this license or (at your option) any later
%% version.  The latest version of this license is in the file:
%% 
%% http://www.latex-project.org/lppl.txt
%% 
%% This work is "maintained" (as per LPPL maintenance status) by
%% Bart Snapp. The source code can be found at:
%% 
%% https://github.com/XimeraProject/ximeraLatex
%% 
%% This work consists of the file ximera.dtx, the associated files
%% under src/, and a Makefile.
%% 
%% Running "make" generates the derived files README, ximera.pdf, ximera.cls, xourse.cls.
%% 
%% Running "make inst" installs the files in the user's TeX tree.
%% 
%% Running "make install" installs the files in the local TeX tree.
%% 
%%
%% End of file `ximera.cls'.
