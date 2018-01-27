% A LaTeX2e document class for preparing handouts and online material
% via Ximera.

%% ximera.cls
%% Copyright (c) 2013 Bart Snapp and Jim Fowler
%
% This work may be distributed and/or modified under the
% conditions of the LaTeX Project Public License, either version 1.3c
% of this license or (at your option) any later version.
% The latest version of this license is in
%   http://www.latex-project.org/lppl.txt
% and version 1.3c or later is part of all distributions of LaTeX
% version 2013/12/01 or later.
%
% This work has the LPPL maintenance status "author-maintained".
% 
% This work consists of the files ximera.cls

%%% Bart Snapp
%%% Department of Mathematics
%%% The Ohio State University

\def\fileversion{1.31}
\def\filedate{2016/08/17}

% ---------------------------------------------------------------------
% ---------------------------------------------------------------------
% If there's some feature that you'd like that this file doesn't
% provide, tell Bart Snapp or Jim Fowler about it.  
%
% Thanks to: 
%
% Philip Hirschhorn as this document class is based on his
% ``exam.cls.'' The original work can be found at:
% http://www-math.mit.edu/~psh/
% --------------------------------------------------------------------
% --------------------------------------------------------------------


% --------------------------------------------------------------------
% --------------------------------------------------------------------
% Class Options
% --------------------------------------------------------------------
% --------------------------------------------------------------------

\NeedsTeXFormat{LaTeX2e}

\ProvidesClass{ximera}[\filedate\space Version \fileversion\space by
  Bart Snapp]

\newif\ifhandout
\handoutfalse
\DeclareOption{handout}{\handouttrue}

\newif\ifinstructornotes
\instructornotesfalse
\DeclareOption{instructornotes}{\instructornotestrue}   %% Yes. 
\DeclareOption{noinstructornotes}{\instructornotestrue} %% This is hilarious.

\newif\ifnooutcomes
\nooutcomesfalse
\DeclareOption{nooutcomes}{\nooutcomestrue}

\newif\ifnoauthor
\noauthorfalse
\DeclareOption{noauthor}{\noauthortrue}

\newif\ifhints
\hintsfalse
\DeclareOption{hints}{\hintstrue}


\newif\ifnewpage
\newpagefalse
\DeclareOption{newpage}{\newpagetrue}

\newif\ifnumbers
\numbersfalse
\DeclareOption{numbers}{\numberstrue}

\newif\ifwordchoicegiven%% suppresses choices in handout mode
\wordchoicegivenfalse
\DeclareOption{wordchoicegiven}{\wordchoicegiventrue}

\newif\ifshuffle
\shufflefalse

\newif\ifspace 
\spacefalse
\DeclareOption{space}{\spacetrue}
%% This basically works for exercises, though page breaks are weird. 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tikzexport will generate SVGs and PNGs for tikzpictures
%
% This option is automatically chosen when compiling inside the Ximera sandbox
%
\newif\iftikzexport
\tikzexportfalse
\DeclareOption{tikzexport}{%
  \tikzexporttrue%
  \handoutfalse%
  \shufflefalse%
  \spacefalse%  
  \numbersfalse%
  \newpagefalse%
  \hintsfalse%
  \nooutcomesfalse%
}

\newif\ifxake
\xakefalse
\DeclareOption{xake}{\xaketrue}

\DeclareOption*{%
  \PassOptionsToClass{\CurrentOption}{article}%
}
\ProcessOptions\relax
\LoadClass{article}

%%%% for allowing a ximera document to be input into a master ximera document
%%%% SNAPP COMMENTED THIS OUT.

%% % The first thing to do is to save the regular \LaTeX\ definitions of |\document|, |\enddocument|, and  |\documentclass|:
%% %    \begin{macrocode}
%% \let\old@document@subfiles\document
%% \let\old@enddocument@subfiles\enddocument
%% \let\old@documentclass@subfiles\documentclass
%% %    \end{macrocode}
%% %
%% % Now the |document| `environment' is redefined and equaled to |comment|. As a consequence, the body of the main file is ignored by \LaTeX, and only the preamble is read (and anything that comes after |\end{document}|!). For |\documentclass|, having been already loaded one (|subfiles|), it is redefined and equaled to |\LoadClass|. The class and options of the main file are loaded identically.
%% %    \begin{macrocode}
%% \let\document\comment
%% \let\enddocument\endcomment
%% \let\documentclass\LoadClass\relax
%% %    \end{macrocode}
%% %
%% % Here it comes something not so obvious. In the usual situations, the |\preamble@file| contains some |\usepackage| commands, which, at the end, make |@| no longer a letter. That is why the next part needs a |\catcode| command, grouping, and |\global|'s.
%% %    \begin{macrocode}
%% {\catcode`\@=11
%% \global\let\document\old@document@subfiles
%% \global\let\enddocument\old@enddocument@subfiles
%% \global\let\documentclass\old@documentclass@subfiles
%% \global\let\old@document@subfiles\undefined
%% \global\let\old@enddocument@subfiles\undefined
%% \global\let\old@documentclass@subfiles\undefined}
%% %</class>
%% %    \end{macrocode}
%% %





%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% externalize tikz images
\PassOptionsToPackage{table}{xcolor}
\RequirePackage{tikz}

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
        pdflatex \tikzexternalcheckshellescape -halt-on-error -interaction=batchmode -jobname "\image" "\\PassOptionsToClass{tikzexport}{ximera}\texsource";
        mutool draw -o \image.svg \image.pdf ;
        mutool draw -r 150 -c rgbalpha -o \image.png \image.pdf ;
      }
    }
    \tikzexternalize[optimize=false,prefix=./]
  \fi

  \fi

% Load sagetex if it exists
\IfFileExists{sagetex.sty}{\RequirePackage{sagetex}}{}

\RequirePackage[inline]{enumitem}
\RequirePackage[pagestyles]{titlesec} 
\RequirePackage{titletoc} 
\RequirePackage{titling}  
\RequirePackage{url}
\RequirePackage{xcolor}
\RequirePackage{pgfplots}
\usepgfplotslibrary{groupplots}
\usetikzlibrary{calc}
\RequirePackage{fancyvrb}
%\RequirePackage{verbatim}
\RequirePackage{environ}
\RequirePackage{amssymb}
\RequirePackage{amsmath}
\RequirePackage{amsthm}
\RequirePackage{xifthen}% http://ctan.org/pkg/xifthen
\RequirePackage{multido}% http://ctan.org/pkg/multido
\RequirePackage{listings} %% is this required???

\RequirePackage{xkeyval}

\RequirePackage[framemethod=TikZ]{mdframed} %% Used to make pretty foldable
% BADBAD: the amsthm/mdframed conflict also messes up the .jax file

\RequirePackage{comment}

\oddsidemargin 62pt %% so we don't get weird margins in 2-sided mode
\evensidemargin 62pt %% so we don't get weird margins in 2-sided mode
\textwidth 345pt %% so we don't get weird margins in 2-sided mode
\headheight 14pt %% so we don't get weird margins in 2-sided mode




% Don't use hyperref when using Tex4ht
\ifdefined\HCode
\RequirePackage{hyperref}
%\newcommand{\href}[1]{}
\else
\RequirePackage[pdfpagelabels,colorlinks=true,allcolors=blue!30!black]{hyperref}
\pdfstringdefDisableCommands{\def\hskip{}}%% quiets warning
\fi
% We put hyperref after all other packages becuase that is better.

% the article document class is made to have lines of text that are
% not too long. 

% http://tex.stackexchange.com/questions/71172/why-are-default-latex-margins-so-big

% ---------------------------------------------------------------------
% ---------------------------------------------------------------------
% Exercise Headers
% ---------------------------------------------------------------------
% ---------------------------------------------------------------------

\newcommand{\license}{\excludecomment}
\newcommand{\acknowledgement}{\excludecomment}
\renewcommand{\tag}{\excludecomment}
             
% ---------------------------------------------------------------------
% ---------------------------------------------------------------------
% Print Formatting
% ---------------------------------------------------------------------
% ---------------------------------------------------------------------

\setlength{\parindent}{0pt}
\setlength{\parskip}{5pt}

\makeatletter
\let\title\relax
\newcommand{\title}[1][]{{\protected@xdef\@pretitle{#1}}\protected@xdef\@title}
\makeatother

\title{}

\makeatletter
\let\abstract\relax
\let\endabstract\relax
\NewEnviron{abstract}{\protected@xdef\theabstract{\BODY}}
\makeatother

\newcounter{titlenumber}
\renewcommand{\thetitlenumber}{\arabic{titlenumber}}
%\renewcommand{\thesection}{\arabic{titlenumber}} %% Makes section numbers work
\setcounter{titlenumber}{0}


\makeatletter
\newpagestyle{main}{
\sethead[\textsl{\ifnumbers\thetitlenumber\quad\fi\@title}][][] % even
{}{}{\textsl{\ifnumbers\thetitlenumber\quad\fi\@title}} % odd
\setfoot[\thepage][][] % even
{}{}{\thepage} % odd
}
\pagestyle{main}
\makeatother

% Redefine maketitle and put them in a table of contents.  The \phantomsection is to fix the hrefs.
\makeatletter
\let\@emptyauthor\@author
\def\author#1{\gdef\@author{#1}}
\def\@author{\@latex@warning@no@line{No \noexpand\author given}}

\renewcommand\maketitle{%
  \addtocounter{titlenumber}{1}\phantomsection \ifnumbers\addcontentsline{toc}{section}{\thetitlenumber~\@title}\else\addcontentsline{toc}{section}{\@title}\fi %% puts titles in the toc, with or without numbers.
  {\flushleft\large\bfseries \@pretitle\par\vspace{-1em}}
  {\flushleft\LARGE\bfseries {\ifnumbers\thetitlenumber\fi}{\ifnumbers\hspace{1em}\else\hspace{0em}\fi}\@title \par }
  \vskip .6em\noindent\textit\theabstract\setcounter{problem}{0}\setcounter{section}{0}\setcounter{subsection}{0}\par\vspace{2em}
  \ifnooutcomes\else\let\thefootnote\relax\footnote{Learning outcomes: \theoutcomes}\fi
  \ifnoauthor\else\let\thefootnote\relax\footnote{Author(s):~\@author}\fi
  \aftergroup\@afterindentfalse
  \aftergroup\@afterheading}
\makeatother
\relax

\ifnumbers
\setcounter{secnumdepth}{2}
\renewcommand{\thesection}{\arabic{titlenumber}.\arabic{section}~} 
\else
\setcounter{secnumdepth}{-2}
%\renewcommand{\thesection}{}
%%magic to unindent unnumbered sections:
%\makeatletter
%\def\@seccntformat#1{\csname #1ignore\expandafter\endcsname\csname the#1\endcsname\quad}
%\let\sectionignore\@gobbletwo
%\let\latex@numberline\numberline
%\def\numberline#1{\if\relax#1\relax\else\latex@numberline{#1}\fi}
%\makeatother
\fi
\relax

\makeatletter
\def\activitystyle{}
\newcounter{sectiontitlenumber}
\setcounter{secnumdepth}{0}
\newcommand\chapterstyle{%
  \def\activitystyle{activity-chapter}
  \def\maketitle{%
    \addtocounter{titlenumber}{1}%
    \addcontentsline{toc}{section}{\textbf{\thetitlenumber\quad\@title}}%
                    {\flushleft\small\sffamily\bfseries\@pretitle\par\vspace{-1.5em}}%
                    {\flushleft\LARGE\sffamily\bfseries\thetitlenumber\quad\@title \par }%
                    {\vskip .6em\noindent\textit\theabstract\setcounter{problem}{0}\setcounter{sectiontitlenumber}{0}}%
                    \par\vspace{2em}}}

\newcommand\sectionstyle{%
  \def\activitystyle{activity-section}
  \def\maketitle{%
    \addtocounter{sectiontitlenumber}{1}
    \addcontentsline{toc}{subsection}{\thetitlenumber.\thesectiontitlenumber\quad\@title}%
    {\flushleft\small\sffamily\bfseries\@pretitle\par\vspace{-1.5em}}%
    {\flushleft\Large\sffamily\bfseries\thetitlenumber.\thesectiontitlenumber\quad\@title \par}%
    {\vskip .6em\noindent\textit\theabstract}%
    \par\vspace{2em}}}
\makeatother

\iftikzexport%% allows xake to handle \chapterstyle and \sectionstye
\renewcommand\chapterstyle{\def\activitystyle{chapter}}
\renewcommand\sectionstyle{\def\activitystyle{section}}
\else
\fi


%% makes everymath display style even when inline, could be optional
\everymath{\displaystyle} 
%% Ok not everything, we also need this
\let\prelim\lim 
\renewcommand{\lim}{\displaystyle\prelim} 
%% for display style limits

% --------------------------------------------------------------------
% --------------------------------------------------------------------
% Content
% --------------------------------------------------------------------
% --------------------------------------------------------------------

\def\theoutcomes{}

\ifdefined\HCode%
  \newcommand{\outcome}[1]{}
\else%
  \newwrite\outcomefile
  \immediate\openout\outcomefile=\jobname.oc

  \newcommand{\outcome}[1]{\edef\theoutcomes{\theoutcomes #1~}%
  \immediate\write\outcomefile{\unexpanded{\outcome}{#1}}}
\fi%

% --------------------------------------------------------------------
% Videos

%\newcommand{\video}[1]{\footnote{Video link: \url{#1}}}

% Youtube link
\newcommand{\youtube}[1]{YouTube link: \url{https://www.youtube.com/watch?v=#1}}

% --------------------------------------------------------------------
% Interactives

\DefineVerbatimEnvironment{javascript}{Verbatim}{numbers=left,frame=lines,label=SAGE,labelposition=topline}
\def\js#1{\mbox{\texttt{\detokenize{#1}}}}

%Geogebra link
\newcommand{\geogebra}[3]{Geogebra link: \url{https://tube.geogebra.org/m/#1}}

%Desmos link
\newcommand{\desmos}[3]{Desmos link: \url{https://www.desmos.com/calculator/#1}}

% Google Spreadsheet link (read only)
\newcommand{\googleSheet}[5]{%
  Google Spreadsheet link: \url{https://docs.google.com/spreadsheets/d/#1}%
}

% Embedded graph (in math mode)
\newcommand{\graph}[2][]{\text{Graph of $#2$}}

% Interactive element
\makeatletter
\define@key{interactive}{id}{\def\interactive@id{#1}}
\setkeys{interactive}{id=}
\newcommand{\includeinteractive}[2][]{
\setkeys*{interactive}{#1}%
\ifthenelse{\equal{\interactive@id}{}}{}{\recordvariable{\interactive@id}}
Interactive
}
\makeatother

%HTML 
\NewEnviron{html}{\textbf{INTERACTIVE NOT AVAILABLE.}}
	
% --------------------------------------------------------------------
% Hyperlinks to outside documents

\newcommand*{\link}[2][]{#1%
\ifthenelse{\equal{#1}{}}%
{\footnote{Link: \url{#2}}}%
{\footnote{See #1 at \url{#2}}}}
                              

%% image environment
%\newenvironment{image}[1][]{\begin{center}}{\end{center}}
\NewEnviron{image}[1][3in]{% 
  \begin{center}\resizebox{#1}{!}{\BODY}\end{center}% resize and center
}

\newtheorem{theorem}{Theorem}
%\newtheorem{acknowledgement}{Acknowledgement}
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
\newtheorem{formula}{Formula}
\newtheorem{idea}{Idea}
\newtheorem{lemma}{Lemma}
\newtheorem{model}{Model}
\newtheorem{notation}{Notation}
\newtheorem{observation}{Observation}
\newtheorem{paradox}{Paradox}
\newtheorem{procedure}{Procedure}
\newtheorem{proposition}{Proposition}
\newtheorem{remark}{Remark}
\newtheorem{summary}{Summary}
\newtheorem{template}{Template}
\newtheorem{warning}{Warning}



\renewenvironment{proof}[1][\proofname]{\begin{trivlist}\item[\hskip \labelsep \itshape \bfseries #1{}\hspace{2ex}]}
{\qed\end{trivlist}}

\renewcommand{\qedsymbol}{$\blacksquare$}

% ---------------------------------------------------------------------
% ---------------------------------------------------------------------
% Problems
% ---------------------------------------------------------------------
% ---------------------------------------------------------------------

%% Prompt environment
\ifhandout
\NewEnviron{prompt}{}
\else
\newenvironment{prompt}
               {\bgroup\color{gray!50!black}}
               {\egroup}
               \fi

               %% Prompt environment
\ifhandout
\NewEnviron{onlineOnly}{\iftikzexport\BODY
\else\fi}
\else
\newenvironment{onlineOnly}
               {\bgroup\color{red!50!black}}
               {\egroup}
               \fi
               
%\newenvironment{pdfOnly}{\iftikzexport\else}{\fi}
\newcommand{\pdfOnly}[1]{\iftikzexport\else #1\fi}
 
               

%% \newenvironment{prompt} %broke in true math mode
%%                {\ifhandout\setbox0\vbox\bgroup\else\bgroup\color{gray!50!black}\fi}
%%                {\ifhandout\egroup\else\egroup\fi}

% ---------------------------------------------------------------------
% ---------------------------------------------------------------------
% Answers
% ---------------------------------------------------------------------
% ---------------------------------------------------------------------

\makeatletter
\ifdefined\HCode
\newcommand{\recordvariable}[1]{}
\else
\newwrite\idfile
\immediate\openout\idfile=\jobname.ids
\newcommand{\recordvariable}[1]{\ifthenelse{\equal{#1}{}}{}{\immediate\write\idfile{var #1;}}}
\fi

%defining keys for answer command key=value pairs
\define@key{answer}{given}[true]{\def\ans@given{#1}}
\define@key{answer}{tolerance}{\def\ans@tol{#1}} %note: currently no affect on pdf output
\define@key{answer}{validator}{}
\define@key{answer}{id}{\def\ans@id{#1}} %note: currently no affect on pdf output
\define@key{answer}{format}{}

%setting default values for answer command key=value pairs
\setkeys{answer}{id=,given=false}
\newcommand{\answer}[2][]{%
  \ifmmode%
	\setkeys{answer}{#1}%
	%% when given=true, show answer in handout mode, show answer in "given box" outside handout mode
	%% when given=false, do not show answer in handout mode, show answer outside handout mode
        \recordvariable{\ans@id}
	\ifthenelse{\boolean{\ans@given}}
		{\ifhandout #2\else\underset{\scriptstyle\mathrm{given}}{\fbox{\ensuremath{#2}}}\fi}
		{\ifhandout\fbox{\rm{?}}\else\fbox{\ensuremath{#2}}\fi}% show answer in box outside handout mode
  \else%
  \GenericError{\space\space\space\space}
  {Attempt to use \@backslashchar answer outside of math mode}
  {See https://github.com/ximeraProject/ximeraLatex for explanation.}
  {Need to use either use inline or display math.}%
  \fi
}
             
\makeatother

%% multiple choice environment

% Jim: Originally this was \renewcommand{\theenumi}{$(\mathrm{\alph{enumi}})$}
% but that breaks tex4ht because mathmode can only be processed by mathjax.
% so now I made this just italicized.
\renewcommand{\theenumi}{\textup{(\alph{enumi})}}
\renewcommand{\labelenumi}{\theenumi}
\renewcommand{\theenumii}{\textup{(\roman{enumii})}}
\renewcommand{\labelenumii}{\theenumii}

%% correct answers for multiple choice
\makeatletter
\define@key{choice}{value}[]{\def\choice@value{#1}}
\define@boolkey{choice}{correct}[true]{\def\choice@correct{#1}}
\setkeys{choice}{correct=false,value=}
\newcommand{\choice}[2][]{%
\setkeys{choice}{#1}%
\item #2\ifthenelse{\boolean{\choice@correct}}{\ifhandout \else \,\checkmark\,\setkeys{choice}{correct=false}\fi}{}}
\makeatother

%% Not really meant to be used outside this package (used in wordChoice)
%% \otherchoice outputs the item if correct and nothing if incorrect.
\makeatletter
\define@key{otherchoice}{value}[]{\def\otherchoice@value{#1}}
\define@boolkey{otherchoice}{correct}[true]{\def\otherchoice@correct{#1}}
\setkeys{otherchoice}{correct=false,value=}
\newcommand{\otherchoice}[2][]{%
  \ignorespaces
  \setkeys{otherchoice}{#1}
  \ifthenelse{\boolean{\otherchoice@correct}}{#2\setkeys{otherchoice}{correct=false}}{}\ignorespaces}
\makeatother
%%%

%setting default values for multipleChoice command key=value pairs
\makeatletter
\define@key{multipleChoice}{id}{\def\mc@id{#1}}
\setkeys{multipleChoice}{id=}

\newenvironment{multipleChoice}[1][]
{\setkeys{multipleChoice}{#1}%
\recordvariable{\mc@id}%
\begin{trivlist}\item[\hskip \labelsep\small\bfseries Multiple Choice:]\hfil\begin{enumerate}}
{\end{enumerate}\end{trivlist}}

%multipleChoice* is for internal use only! (used in wordChoice)
%It displays all choices in a list separated by /
\newenvironment{multipleChoice*}[1][]
{\setkeys{multipleChoice}{#1}%
\ifthenelse{\equal{\mc@id}{}}{}{\immediate\write\idfile{var \mc@id;}}%
\begin{enumerate*}[before={\upshape{(\hspace{-.25em}}}, itemjoin={/\hspace{-.25em}}, after={\upshape{)}}, label={}]}
{\end{enumerate*}}
\makeatother

%multipleChoice** is for internal use only! (used in wordChoice)
%this is simply a wrapper for the sole showing (other)choice.
\newenvironment{multipleChoice**}[1][]{}{}



%wordChoice is an in-line version of multipleChoice:  uses enumitem package
%note, it is coded as a single line to avoid unwanted spaces in "given" mode
\newcommand{\wordChoice}[1]{\let\choicetemp\choice\ifwordchoicegiven\def\choice{\otherchoice}\begin{multipleChoice**}#1\end{multipleChoice**}\else\begin{multipleChoice*}#1\end{multipleChoice*}\fi\let\choice\choicetemp}

\newenvironment{selectAll}[1][]
{\begin{trivlist}\item[\hskip \labelsep\small\bfseries Select All Correct Answers:]\hfil\begin{enumerate}}
{\end{enumerate}\end{trivlist}}

%% In the future we need this to (optionally) be desplayed in the
%% problem, while the actual code lives in the solution. Here is how
%% this could be implemented: Like the title/maketitle commands, the
%% multiple-choice could be stored in \themultiplechoice, flip a
%% boolean, and execute \makemultiplechoice at the \end of the
%% problem.  We should also make a command called "\showchoices" that
%% will show choices in the handout.

\ifhandout
	\excludecomment{matrixAnswer}
%% Note:  This workaround will throw an error "File ended while scanning use of \next" if "\end{matrixAnswer}" does not appear on its own line with no spaces preceding it.  This is a documented issue with the \excludecomment command.

\else
	\newenvironment{matrixAnswer}
	{
    % First, we tell fancyvrb that we're inside a verbatim environment.
    \VerbatimEnvironment
    % Now we start the actual environment:
    \begin{Verbatim}[
        frame=lines,
        label=Matrix Answer,
        labelposition=topline,
      ]%
	}
	{\end{Verbatim}}
\fi


\newboolean{given} %% required for freeResponse
\setboolean{given}{true} %% could be replaced by a key=value pair later if needed

\ifhandout
\newenvironment{freeResponse}[1][false]%
{%
\def\givenatend{\boolean{#1}}\ifthenelse{\boolean{#1}}{\begin{trivlist}\item}{\setbox0\vbox\bgroup}{}
}
{%
\ifthenelse{\givenatend}{\end{trivlist}}{\egroup}{}
}
\else
\newenvironment{freeResponse}[1][false]%
{%
  \ifthenelse{\boolean{#1}}{\begin{trivlist}\item[\hskip \labelsep\bfseries Free Response (Given):\hspace{2ex}]}
{\begin{trivlist}\item[\hskip \labelsep\bfseries Free Response:\hspace{2ex}]}
{}
}
{\end{trivlist}}
\fi


%% instructor intro/instructor notes
%%
\ifhandout % what follows is handout behavior
\ifinstructornotes
\newenvironment{instructorIntro}%
{%
  \begin{trivlist}\item[\hskip \labelsep\bfseries Instructor Introduction:\hspace{2ex}]
}
% %% line at the bottom} 
{\end{trivlist}\par\addvspace{.5ex}\nobreak\noindent\hung}
\else
\newenvironment{instructorIntro}%
{%
\setbox0\vbox\bgroup
}
{%
\egroup\ignorespacesafterend %% If this mysteriously starts breaking remove \ignorespacesafterend
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
  \begin{trivlist}\item[\hskip \labelsep\bfseries Instructor Introduction:\hspace{2ex}]
}
% %% line at the bottom} 
{\end{trivlist}\par\addvspace{.5ex}\nobreak\noindent\hung}
\fi
\fi




%% instructorNotes environment
\ifhandout % what follows is handout behavior
\ifinstructornotes
\newenvironment{instructorNotes}%
{%
  \begin{trivlist}\item[\hskip \labelsep\bfseries Instructor Notes:\hspace{2ex}]
}
% %% line at the bottom} 
{\end{trivlist}\par\addvspace{.5ex}\nobreak\noindent\hung}
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
  \begin{trivlist}\item[\hskip \labelsep\bfseries Instructor Notes:\hspace{2ex}]
}
% %% line at the bottom} 
{\end{trivlist}\par\addvspace{.5ex}\nobreak\noindent\hung}
\fi
\fi









%% code answer environment
%% You cannot use Envrion with the fancyvrb/listings package if you want nested environments

\DefineVerbatimEnvironment{code}{Verbatim}{numbers=left,frame=lines,label=Code,labelposition=topline}
%% \lstnewenvironment{python}
%% {\lstset{language=python,numbers=left}}
%% {}


%% python answer environment
%% You cannot use Envrion with the fancyvrb/listings package if you want nested environments

\DefineVerbatimEnvironment{python}{Verbatim}{numbers=left,frame=lines,label=Python,labelposition=topline}
 %% \lstnewenvironment{python}
 %%                   {\lstset{language=python,numbers=left}}
 %%                   {}



% ---------------------------------------------------------------------
% Problem environment decorations (these should be user invoked, not default)

% The decoration for these envrionments were inspired by
% http://tex.stackexchange.com/questions/11098/nice-formatting-for-theorems?lq=1

%\makeatletter%
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%		  Randomize Commands		%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% This section loads and defines all the commands needed for randomizing content. Hacked together by Jason Nowell

\RequirePackage{tikz, pgfplots}
\pgfmathsetseed{\number\pdfrandomseed}
\RequirePackage{forloop}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%   Generate and Store Random Latex Number   %%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Create a command to randomly generate a number and record it into a given name. Recorded as the command \#1 for given input to not break things in LaTeX.
\newcommand{\genrand}[3]
{
\expandafter\pgfmathtruncatemacro\csname #1\endcsname{int(random(#2,#3))}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  Random Permutation Command  %%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcounter{Iteration1}%	Dummy Iteration variable.
\newcounter{RndQuant}%		Tracks the number of desired counters
\newcounter{Temp@Hold}%		Temp counter to hold the command value because tex is weird.
\newcounter{Temp@RandMe}%	Temp counter like previous.

\newcommand*\ifcounter[2]{% Function checks if a counter named #1 exists. If not it creates it. After existance is confirmed (or implemented), set the counter to #2.
  \ifcsname c@#1\endcsname
  \else
    \newcounter{#1}
  \fi
\setcounter{#1}{#2}
}

\newcommand{\RandMe}[3]
{% #1 is the max number for range, #2 is the name of the counter to hold the list, and #3 is how many from that list to generate. Thus \RandMe{100}{TEMP}{5} will generate 5 counters, named \TEMPI, \TEMPII, \TEMPIII, \TEMPIV, \TEMPV. Each of which will have a (unique) number between 1 and 100.

%Assign a maximum on how many numbers to pick. Set default to the max list size, and save in counter "RndQuant"
\ifthenelse{\isempty{#3}}
{
\setcounter{RndQuant}{#1+1}
}
{
\setcounter{RndQuant}{#3+1}
}

%Generate a starting list of numbers 1 to maximum number given
\forloop{Iteration1}{1}{\arabic{Iteration1} < \arabic{RndQuant}}{
\ifcounter{#2\Roman{Iteration1}}{\arabic{Iteration1}}
}


%Permute using Knuth method
\forloop{Iteration1}{1}{\arabic{Iteration1} < \arabic{RndQuant}}{
\genrand{TempRandMe}{\arabic{Iteration1}}{#1}

\ifcounter{Temp@RandMe}{\TempRandMe}
\ifcounter{Temp@Hold}{\arabic{#2\Roman{Temp@RandMe}}}

\ifcounter{#2\Roman{Temp@RandMe}}{\arabic{#2\Roman{Iteration1}}}
\ifcounter{#2\Roman{Iteration1}}{\arabic{Temp@Hold}}
}
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%  		Shuffle Environment		%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% THE ENVRON PACKAGE CANNOT BE USED TO WRAP VERBATIM.
% THE ENVRON PACKAGE CANNOT BE USED TO WRAP VERBATIM.
\RequirePackage{environ}	% The environ package saves environment contents as commands. We will use this to save problem contents and then randomly place them.
% THE ENVRON PACKAGE CANNOT BE USED TO WRAP VERBATIM.
% THE ENVRON PACKAGE CANNOT BE USED TO WRAP VERBATIM.


\newif\iffirstproblem% Condition for first problem This may become obsolete once someone can clean up the \problemEnvironmentStart/End code.
\firstproblemtrue

%Necessary counters
\newcounter{shuffle@maxCount}%	Tracks how many questions we want in shuffle.
\newcounter{shuffle@count}%		Tracks which shuffle we're on (on the page).
\newcounter{shuffle@trackProblem}% Tracks which problem in shuffle we're on.
\newcounter{shuffle@desiredProblems}% takes min of desired and available random Qs.

% Shuffle has changed from truncating to randomizing (and possibly truncating). There will likely be a lot of redundant/pointless code that use to track truncation when we don't need it anymore.

\newenvironment{shuffle}[1][1] % shuffle takes an optional argument as a number. It will collect all the problem-type environments within it (anything configured with \problemEnvironConfig below should work), and randomly select/order the optionally given number of them. If the optional argument exceeds the number of problems in the shuffle environment, shuffle will only randomize up to the number of available problems (i.e. no random extra empty problems listed on the page.) 
	{% Shuffle Start: Collect and save numbers that will be needed later.
	\shuffletrue\setcounter{problemType}{0}
	\setcounter{shuffle@maxCount}{#1}
	\stepcounter{shuffle@maxCount}% Need to step for the < logic check
	\setcounter{shuffle@count}{\theproblem}% Fluke of how tex records things.
	\setcounter{shuffle@trackProblem}{1}
	}
	{
	\setcounter{shuffle@desiredProblems}{\value{shuffle@trackProblem} - 1} % Select questions from any question in the shuffle environment.
	
	\ifthenelse{\arabic{shuffle@trackProblem} < \arabic{shuffle@maxCount}}{% If there are fewer problems than the optional argument, only take up to the number of problems available.
		\setcounter{shuffle@maxCount}{\value{shuffle@trackProblem}}
		}
		{
		}
	%Below code randomizes which problems go where.
	\RandMe{\arabic{shuffle@desiredProblems}}{shuffleOrder}{}
	\forloop{Iteration1}{1}{\arabic{Iteration1} < \arabic{shuffle@maxCount}}{
		\expandafter\problemEnvironmentStart{2in}{% This first one finds the env name
		\csname\roman{shuffle@count}ContentProblemType\expandafter\Roman{shuffleOrder\Roman{Iteration1}}\endcsname}% Now we find the env content
		\csname\roman{shuffle@count}ContentProblem\expandafter\Roman{shuffleOrder\Roman{Iteration1}}\endcsname
		\problemEnvironmentEnd
		}
	\ifhandout\else\refstepcounter{problem}\fi
	\shufflefalse\global\firstproblemtrue% Legacy code that can probably be removed with minor editing.
	}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%  		Problem Environments		%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% Configure environment configuration commands

% The \problemEnvironmentStart and \problemEnvironmentEnd are now
% being depreciated in favor of \problemEnvironConfig. There is plenty
% of code here to cleanup now that the termination is done at the
% shuffle level, instead of this 'first problem' nonsense.

%% %Configure environments start content
%% \newcommand{\problemEnvironmentStart}[2]{%This takes in 2 arguments. The first is optional and is the old optional argument from existing environments. The second argument is mandatory and is the name of the 'problem' environment, such as problem, question, exercise, etc. It then configures everything needed at the start of that environment.

%% \iffirstproblem
%% \def\spaceatend{#1}\refstepcounter{problem}\refstepcounter{problemType}
%% \begin{trivlist}\item[\hskip\labelsep\sffamily\bfseries 
%% #2 \ifhandout\theproblem\else\ifshuffle\theproblem.\theproblemType\else\theproblem\fi\fi]
%% \slshape
%% \else\setbox0\vbox\bgroup\fi
%% }

%% %Configure environments end content
%% \newcommand{\problemEnvironmentEnd}{%This configures all the end content for a problem.
%% \iffirstproblem
%% 	\ifhandout
%% 		\ifspace
%% 			\vspace{\spaceatend}
%% 		\fi
%% 	\fi %% space at end
%% 	\par\addvspace{.5ex}\nobreak\noindent\hung %% line at the bottom
%% 	\ifhandout
%% 	\else
%% 	\ifshuffle
%% 		\addtocounter{problem}{-1}
%% 	\fi
%% \fi %% the problem does not increase within shuffle
%% %\ifhandout\ifshuffle\global\firstproblemfalse\fi\fi %% removes other problems from shuffle in handout
%% \ifhandout
%% 	\ifnewpage
%% 		\newpage
%% 	\fi
%% \fi 
%% \end{trivlist}
%% \else
%% 	\egroup
%% \fi

%% }


%%%%%%%%%%%%%%%%%%%%%%%

%%%%%% Configure various problem environment commands

%Configure environments start content
\newcommand{\problemEnvironmentStart}[2]{%This takes in 2 arguments. The first is optional and is the old optional argument from existing environments. The second argument is mandatory and is the name of the 'problem' environment, such as problem, question, exercise, etc. It then configures everything needed at the start of that environment.
\ifshuffle
	\ifthenelse{\arabic{track@Problem}<\arabic{shuffle@Count}}
		{% If we haven't gotten to the last problem yet, track the problem
		\stepcounter{track@Problem}
		}
		{%	If we have all our problems, turn off the problem environment.
		\global\firstproblemfalse
		}
\fi
\iffirstproblem
\def\spaceatend{#1}\refstepcounter{problem}\refstepcounter{problemType}
\begin{trivlist}\item[\hskip\labelsep\sffamily\bfseries 
#2 \ifhandout\theproblem\else\ifshuffle\theproblem.\theproblemType\else\theproblem\fi\fi]
\slshape
\else\setbox0\vbox\bgroup\fi
}

%Configure environments end content
\newcommand{\problemEnvironmentEnd}{%This configures all the end content for a problem.
\iffirstproblem
	\ifhandout
		\ifspace
			\vspace{\spaceatend}
		\fi
	\fi %% space at end
	\par\addvspace{.5ex}\nobreak\noindent\hung %% line at the bottom
	\ifhandout
	\else
	\ifshuffle
		\addtocounter{problem}{-1}
	\fi
\fi %% the problem does not increase within shuffle
%\ifhandout\ifshuffle\global\firstproblemfalse\fi\fi %% removes other problems from shuffle in handout
\ifhandout
	\ifnewpage
		\newpage
	\fi
\fi 
\end{trivlist}
\else
	\egroup
\fi

}

\newenvironment{problem}[1][2in]
{%Env start code
\problemEnvironmentStart{#1}{Problem}
}
{%Env end code
\problemEnvironmentEnd
}

\newenvironment{exercise}[1][2in]
{%Env start code
\problemEnvironmentStart{#1}{Exercise}
}
{%Env end code
\problemEnvironmentEnd
}

\newenvironment{exploration}[1][2in]
{%Env start code
\problemEnvironmentStart{#1}{Exploration}
}
{%Env end code
\problemEnvironmentEnd
}

\newenvironment{question}[1][2in]
{%Env start code
\problemEnvironmentStart{#1}{Question}
}
{%Env end code
\problemEnvironmentEnd
}










%% % This is currently a small shell to contain the
%% % soon-to-be-depreciated start/stop commands. Once we merge them into
%% % the below command, we can then remove the above commands.
%% \newcommand{\problemEnvironConfig}[2]{
%% \ifshuffle{
%% \global\expandafter\edef\csname\roman{shuffle@count}ContentProblem\Roman{shuffle@trackProblem}\endcsname{% Record problem env content
%% \BODY
%% }
%% \global\expandafter\edef\csname\roman{shuffle@count}ContentProblemType\Roman{shuffle@trackProblem}\endcsname{% Record problem env type
%% #2
%% }
%% \stepcounter{shuffle@trackProblem}
%% }
%% \else{
%% \problemEnvironmentStart{#1}{#2}
%% \BODY
%% \problemEnvironmentEnd
%% }
%% \fi
%% }

%% %%%%%%%%%%% Config specific problem environments. Note new
%% %%%%%%%%%%% environments can be added easily if you simply want a new
%% %%%%%%%%%%% "name".

%% \NewEnviron{problem}[1][2in]
%% {
%% \problemEnvironConfig{#1}{Problem}
%% }

%% \NewEnviron{exercise}[1][2in]
%% {
%% \problemEnvironConfig{#1}{Exercise}
%% }

%% \NewEnviron{exploration}[1][2in]
%% {
%% \problemEnvironConfig{#1}{Exploration}
%% }

%% \NewEnviron{question}[1][2in]
%% {
%% \problemEnvironConfig{#1}{Question}
%% }

%% Below is included the old code in case it needs referencing. Should probably delete it at some point.


%\newenvironment{problem}[1][2in]
%{
%\ifshuffle
%	\ifthenelse{\arabic{track@Problem}<\arabic{shuffle@maxCount}}
%		{% If we haven't gotten to the last problem yet, track the problem
%		\stepcounter{track@Problem}
%		}
%		{%	If we have all our problems, turn off the problem environment.
%		\global\firstproblemfalse
%		}
%\fi
%\iffirstproblem
%\def\spaceatend{#1}\refstepcounter{problem}\refstepcounter{problemType}
%\begin{trivlist}\item[\hskip\labelsep\sffamily\bfseries 
%Problem \ifhandout\theproblem\else\ifshuffle\theproblem.\theproblemType\else\theproblem\fi\fi]
%\slshape
%\else\setbox0\vbox\bgroup\fi
%} %% removes exercise if in shuffle and not first problem
%{
%\iffirstproblem
%\ifhandout\ifspace\vspace{\spaceatend}\fi\fi %% space at end
%\par\addvspace{.5ex}\nobreak\noindent\hung %% line at the bottom
%\ifhandout\else\ifshuffle\addtocounter{problem}{-1}\fi\fi %% the problem does not increase within shuffle
%%\ifhandout\ifshuffle\global\firstproblemfalse\fi\fi %% removes other problems from shuffle in handout
%\ifhandout\ifnewpage\newpage\fi\fi %% adds newpage
%\end{trivlist}
%\else\egroup\fi
%}



\newenvironment{xarmaBoost}[1][2in]
{\iffirstproblem
\def\spaceatend{#1}\refstepcounter{problem}\refstepcounter{problemType}
\begin{trivlist}\item[\hskip\labelsep\sffamily\bfseries 
Xarma Boost \ifhandout\theproblem\else\ifshuffle\theproblem.\theproblemType\else\theproblem\fi\fi]
\slshape
\else\setbox0\vbox\bgroup\fi} %% removes exercise if in shuffle and not first problem
{\iffirstproblem
\ifhandout\ifspace\vspace{\spaceatend}\fi\fi %% space at end
\par\addvspace{.5ex}\nobreak\noindent\hung %% line at the bottom
\ifshuffle\addtocounter{problem}{-1}\fi %% the problem does not increase within shuffle
\ifhandout\ifshuffle\global\firstproblemfalse\fi\fi %% removes other problems from shuffle in handout
\ifhandout\ifnewpage\newpage\fi\fi %% adds newpage
\end{trivlist}
\else\egroup\fi}

%%%%%%%%%%%%%%%%
%% validator

\def\validator[#1]{\mbox{\texttt{\detokenize{#1}}}}
\def\endvalidator{}

%% Feedback
\makeatletter
\ifhandout

\def\feedback{\@ifnextchar[{\@feedbackcode}{\@feedbackattempt}}
\def\@feedbackcode[#1]{\setbox0\vbox\bgroup}
\def\@feedbackattempt{\setbox0\vbox\bgroup}
\def\endfeedback{\egroup}

\else

\def\feedback{\@ifnextchar[{\@feedbackcode}{\@feedbackattempt}}
\def\@feedbackcode[#1]{\begin{trivlist}\item[\hskip \labelsep\small\slshape\bfseries Feedback (\texttt{\detokenize{#1}}):\hspace{2ex}]\small\slshape}
\def\@feedbackattempt{\begin{trivlist}\item[\hskip \labelsep\small\slshape\bfseries Feedback (attempt):\hspace{2ex}]\small\slshape}
\def\endfeedback{\end{trivlist}}
               
\fi
\makeatother               


%% Hints
\ifhandout
\newenvironment{hint}{\setbox0\vbox\bgroup}
{\egroup\ignorespacesafterend}

\else

\newenvironment{hint}{
\begin{trivlist}\item[\hskip \labelsep\small\slshape\bfseries Hint:\hspace{2ex}]
\small\slshape}
{\end{trivlist}}
\fi

\ifhints
\renewenvironment{hint}{
\begin{trivlist}\item[\hskip \labelsep\small\slshape\bfseries Hint:\hspace{2ex}]
\small\slshape}
{\end{trivlist}}
\fi


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Dialogue

\newenvironment{dialogue}{%
   \renewcommand\descriptionlabel[1]{\hspace{\labelsep}\textbf{##1:}}
   \begin{description}%
}{%
   \end{description}%
}

\newcounter{problem} %% for the main problem
\newcounter{problemType} %% for variations within shuffle

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Foldables

%% \newcounter{globalFold} %Global Flag to tell if environments should be folded.
%%     % Set to 0 to fold, 
%%     % Set to 1 to unfold, 
%%     % Set to 2 to unfold without the foldable option (\unfoldable)
%%     % Set to any other value to remove global override
%% \setcounter{globalFold}{3} %default to no global override

%% \newcounter{localFold} %Local Flag to tell if environments should be folded. 
%%     % Set to 0 to fold, 
%%     % Set to 1 to unfold, 
%%     % Set to 2 to unfold without the foldable option (\unfoldable)
%%     % Set to any other value to remove global override
%% \setcounter{localFold}{3} %default to no local value


%% %% Global set commands:

%% %set global override to folded
%% \newcommand{\expandAllFolds}{%
%% \setcounter{globalFold}{0} 
%% }

%% %set global override to expanded
%% \newcommand{\collapseAllFolds}{%
%% \setcounter{globalFold}{1} 
%% }

%% %set global to override with printable pdf form
%% \newcommand{\expandAllFoldsPDF}{%
%% \setcounter{globalFold}{2}
%% }

%% %Reset global variable to return to local control
%% \newcommand{\noGlobalFolds}{%
%% \setcounter{globalFold}{3}
%% }

\colorlet{textColor}{black} % since textColor is referenced below
\colorlet{background}{white} % since background is referenced below

% The core environments. Find results in 4ht file.
%% pretty-foldable
\iftikzexport
\newenvironment{foldable}{%
}{%
}
\else
\renewmdenv[
  font=\upshape,
  outerlinewidth=3,
  topline=false,
  bottomline=false,
  leftline=true,
  rightline=false, 
  leftmargin=0,
  innertopmargin=0pt,
  innerbottommargin=0pt,
  skipbelow=\baselineskip,
  linecolor=textColor!20!white,
  fontcolor=textColor,
  backgroundcolor=background
]{foldable}%
\fi

%% pretty-expandable
\iftikzexport\newenvironment{expandable}{%
}{%
}
\else
\newmdenv[
  font=\upshape,
  outerlinewidth=3,
  topline=false,
  bottomline=false,
  leftline=true,
  rightline=false, 
  leftmargin=0,
  innertopmargin=0pt,
  innerbottommargin=0pt,
  skipbelow=\baselineskip,
  linecolor=black,
]{expandable}%
\fi
%% \newenvironment{expandable}{%
%% }{%
%% }

\newcommand{\unfoldable}[1]{#1}

%% % Command to set folded or unfolded.
%% % \flexFold{#1}{#2}, #1 is the fold state, #2 is the content. 
%%     % For fold state:
%%     % Set to 0 to fold, 
%%     % Set to 1 to unfold, 
%%     % Set to 2 to unfold without the foldable option (\unfoldable)
%%     % Set to any other value to remove global override

%% \newcommand{\flexFold}[2]{%

%% \setcounter{localFold}{#1} %set local fold flag to user's value.

%% \ifthenelse{\value{globalFold} = 0}{
%%     \begin{expandable} %Make an unfolded version
%%     #2
%%     \end{expandable}
%%     }
%%     {
%%     \ifthenelse{\value{globalFold} = 1}{
%%         \begin{foldable} %make an unfolded version
%%         #2
%%         \end{foldable}
%%         }
%%         {
%%         \ifthenelse{\value{globalFold} = 2}{
%%             \unfoldable{#2}
%%             }
%%             {
%%             \ifthenelse{\value{localFold}=0}
%%                 {
%%                 \begin{expandable}
%%                 #2
%%                 \end{expandable}
%%                 }
%%                 {
%%                 \ifthenelse{\value{localFold} = 1}
%%                     {
%%                     \begin{foldable}
%%                     #2
%%                     \end{foldable}
%%                     }
%%                     {
%%                     \unfoldable{#2}
%%                     }
%%                 }
%%             }
%%         }
%%     }
%%     %Reset local fold flag
%% \setcounter{localFold}{3} %reset to remove local fold flag
%% }


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\DefineVerbatimEnvironment{sageCell}{Verbatim}{numbers=left,frame=lines,label=SAGE,labelposition=topline}
\DefineVerbatimEnvironment{sageOutput}{Verbatim}{numbers=left,frame=lines,label=SAGE-Output,labelposition=topline}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newcommand{\xkcd}[1]{#1}



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Leash

\newenvironment{leash}[1]{%
}{%
}

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% When designing new elements, it is nice to be able to wrap things in a class

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% When using mathjax, it is useful to dump all the newcommands to a "jax" file

\ifdefined\HCode
  \else
    \newwrite\myfile
    \immediate\openout\myfile=\jobname.jax
    \immediate\write\myfile{\unexpanded{\newenvironment}{prompt}{}{}}

    \makeatletter

\let\@oldargdef\@argdef
\long\def\@argdef#1[#2]#3{%
\immediate\write\myfile{\unexpanded{\newcommand}{\unexpanded{#1}}[\unexpanded{#2}]{\unexpanded{#3}}}%
\@oldargdef#1[#2]{#3}%
}

\let\@OldDeclareMathOperator\DeclareMathOperator
\renewcommand{\DeclareMathOperator}[2]{\@OldDeclareMathOperator{#1}{#2}\immediate\write\myfile{\unexpanded{\DeclareMathOperator}{\unexpanded{#1}}{\unexpanded{#2}}}}

    \makeatother
\fi
