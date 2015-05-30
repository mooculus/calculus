% A LaTeX2e document class for preparing handouts and online material
% via Ximera.
%% ximera.cls
%% Copyright (c) 2013 Bart Snapp and Jim Fowler
%
% This work may be distributed and/or modified under the
% conditions of the LaTeX Project Public License, either version 1.3c
% of this license or (at your option) any later version.
% The latest version of this license is in
% http://www.latex-project.org/lppl.txt
% and version 1.3c or later is part of all distributions of LaTeX
% version 2013/12/01 or later.
%
% This work has the LPPL maintenance status "author-maintained".
%
% This work consists of the files ximera.cls
%%% Bart Snapp
%%% Department of Mathematics
%%% The Ohio State University
\def\fileversion{.57}
\def\filedate{2015/01/14}
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
\newif\ifnooutcomes
\nooutcomesfalse
\DeclareOption{nooutcomes}{\nooutcomestrue}
\newif\ifhints
\hintsfalse
\DeclareOption{hints}{\hintstrue}
\newif\ifnewpage
\newpagefalse
\DeclareOption{newpage}{\newpagetrue}
\newif\ifnumbers
\numbersfalse
\DeclareOption{numbers}{\numberstrue}
\newif\ifshuffle
\shufflefalse
\newif\ifspace
\spacefalse
\DeclareOption{space}{\spacetrue}
%% This basically works for exercises, though page breaks are weird.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% tikzexport will activate standalone with "tikz"
%
% this exports each tikzpicture as a separate page in the PDF, which
% is run in a sandboxed copy of pdflatex
%
\newif\iftikzexport
\tikzexportfalse
\DeclareOption{tikzexport}{%
\tikzexporttrue%
}
\DeclareOption*{%
\PassOptionsToClass{\CurrentOption}{article}%
}
\ProcessOptions\relax
\LoadClass{article}
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% externalize tikz images
\PassOptionsToPackage{table}{xcolor}
\RequirePackage{tikz}
\iftikzexport
\usetikzlibrary{external}
\tikzexternalize[prefix=./]
\fi
\RequirePackage[colorlinks=true,urlcolor=blue]{hyperref}
\RequirePackage{enumitem}
\RequirePackage[pagestyles]{titlesec}
\RequirePackage{titletoc}
\RequirePackage{titling}
\RequirePackage{url}
\RequirePackage{xcolor}
\RequirePackage{pgfplots}
\usepgfplotslibrary{groupplots}
\usetikzlibrary{calc}
\RequirePackage{fancyvrb}
\RequirePackage{environ}
\RequirePackage{amssymb}
\RequirePackage{amsmath}
\RequirePackage{amsthm}
\RequirePackage{xifthen}% http://ctan.org/pkg/xifthen
\RequirePackage{multido}% http://ctan.org/pkg/multido
\RequirePackage{listings}
\RequirePackage{comment}
\oddsidemargin 62pt %% so we don't get weird margins in 2-sided mode
\evensidemargin 62pt %% so we don't get weird margins in 2-sided mode
\textwidth 345pt %% so we don't get weird margins in 2-sided mode
\headheight 14pt %% so we don't get weird margins in 2-sided mode
%\RequirePackage[margin=1in]{geometry}
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
\renewcommand{\thesection}{\arabic{titlenumber}} %% Makes section numbers work
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
\makeatletter
\renewcommand\@maketitle{%
\addtocounter{titlenumber}{1}\addcontentsline{toc}{subsection}{\thetitlenumber~\@title} %% puts titles in the toc
{\flushleft\large\bfseries \@pretitle\par\vspace{-1em}}
{\flushleft\LARGE\bfseries {\ifnumbers\thetitlenumber\fi}{\ifnumbers\hspace{1em}\else\hspace{0em}\fi}\@title \par }
\vskip .6em\noindent\textit\theabstract\setcounter{problem}{0}\setcounter{subsection}{0}\par\vspace{2em}
\ifnooutcomes\else\ifhandout\else\let\thefootnote\relax\footnote{Learning outcomes: \theoutcomes}\fi\fi
\aftergroup\@afterindentfalse
\aftergroup\@afterheading}
\makeatother
\ifnumbers
\renewcommand{\section}{\subsection}
\else
\renewcommand{\section}{\subsection*}
\fi
%% makes everymath display style even when inline, could be optional
\everymath{\displaystyle}
% --------------------------------------------------------------------
% --------------------------------------------------------------------
% Content
% --------------------------------------------------------------------
% --------------------------------------------------------------------
\def\theoutcomes{}
\newcommand{\outcome}[1]{\edef\theoutcomes{\theoutcomes #1~}}
\newcommand{\video}[1]{\footnote{Video link: \url{#1}}}
\newcommand{\youtube}[1]{\footnote{YouTube link: \url{#1}}}
\newcommand{\link}[1]{\footnote{Link: \url{#1}}}
%% image environment
\NewEnviron{image}[1][]{
\[
\BODY
\]}
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
\newtheorem{lemma}{Lemma}
\newtheorem{notation}{Notation}
\newtheorem{proposition}{Proposition}
\newtheorem{remark}{Remark}
\newtheorem{summary}{Summary}
\newtheorem{paradox}{Paradox}
\newtheorem{warning}{Warning}
\newtheorem{observation}{Observation}
\newtheorem{template}{Template}
\renewenvironment{proof}[1][\proofname]{\begin{trivlist}\item[\hskip \labelsep \itshape \bfseries #1{}\hspace{2ex}]}
{\qed\end{trivlist}}
\renewcommand{\qedsymbol}{$\blacksquare$}
% ---------------------------------------------------------------------
% ---------------------------------------------------------------------
% Problems
% ---------------------------------------------------------------------
% ---------------------------------------------------------------------
\SetEnumitemKey{hide}{} % hide flag for list environments
%% \newcommand{\problemName}{Problem }
%% \newlist{problemList}{enumerate}{1}
%% \setlist[problemList]{align=left, resume=\thetitle,label={\textbf{\problemName \arabic*.}},
%% leftmargin=0pt, itemindent=*, itemsep=0pt, topsep=5pt, itemsep=5pt}
%% \newenvironment{problem}
%% {\renewcommand{\problemName}{Problem }\begin{problemList} \item}
%% {\end{problemList}}
%% \newenvironment{question}
%% {\renewcommand{\problemName}{Question }\begin{problemList} \item}
%% {\end{problemList}}
%% \newenvironment{exploration}
%% {\renewcommand{\problemName}{Exploration }\begin{problemList} \item}
%% {\end{problemList}}
%% \newenvironment{exercise}
%% {\renewcommand{\problemName}{Exercise }\begin{problemList} \item}
%% {\end{problemList}}
\newlist{parts}{enumerate}{1}
\setlist[parts]{label={\textbf{\alph*)}}, leftmargin=*, itemindent=0pt, itemsep=0pt, topsep=5pt, itemsep=5pt}
%% Prompt environment
\newenvironment{prompt}{
\ifhandout\setbox0\vbox\bgroup\else\color{gray!50!black}
\fi}
{\ifhandout\egroup
\fi}
%% hints environment definition
%% \newlist{hintList}{itemize}{2}
%% \setlist[hintList]{label=\textsl{\textbf{Hint:}}, leftmargin=*, itemindent=0pt, itemsep=0pt, topsep=5pt, itemsep=5pt}
%% \NewEnviron{hints}{\ifhandout \else \begin{hintList} \BODY \end{hintList} \fi}
%% % use of hint should be discouraged
%% \NewEnviron{hint}{\ifhandout \else \begin{hintList} \item \BODY \end{hintList} \fi}
% ---------------------------------------------------------------------
% ---------------------------------------------------------------------
% Answers
% ---------------------------------------------------------------------
% ---------------------------------------------------------------------
\newboolean{given}
\setboolean{given}{true}
\newcommand{\answer}[2][false]{%
\ifthenelse{\boolean{#1}}%
{\ifhandout$#2$\else$\underset{\tiny{\text{given}}}{\fbox{\ensuremath{#2}}}$\fi}%
{\ifhandout\else\fbox{\ensuremath{#2}}\fi}%
{}}
%% multiple choice environment
\renewcommand{\theenumi}{$(\mathrm{\alph{enumi}})$} % this hack should be fixed via enumitem
\renewcommand{\labelenumi}{\theenumi}
%% correct answers for multiple choice
\newboolean{correct}
\setboolean{correct}{true}
\newcommand{\choice}[2][]{\item #2\ifthenelse{\boolean{#1}}{\ifhandout \else \quad\checkmark\fi}{}}
\newenvironment{multipleChoice}[1][]
{\begin{trivlist}\item[\hskip \labelsep\small\bfseries Multiple Choice:]\hfil\begin{enumerate}}
{\end{enumerate}\end{trivlist}}
%% In the future we need this to (optionally) be desplayed in the
%% problem, while the actual code lives in the solution. Here is how
%% this could be implemented: Like the title/maketitle commands, the
%% multiple-choice could be stored in \themultiplechoice, flip a
%% boolean, and execute \makemultiplechoice at the \end of the
%% problem. We should also make a command called "\showchoices" that
%% will show choices in the handout.
\ifhandout
\excludecomment{matrixAnswer}
\else
\newenvironment{matrixAnswer}[1][]
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
%% {\lstset{language=python,numbers=left}}
%% {}
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
% --------------------------------------------------------------------
% --------------------------------------------------------------------
% Commands that should be deprecated or replaced
% --------------------------------------------------------------------
% --------------------------------------------------------------------
\newcommand{\prerequisites}[1]{}
%%% shuffle environment
\newif\iffirstproblem% Condition for first problem
\firstproblemtrue
\newenvironment{shuffle}[1][]
{\shuffletrue\setcounter{problemType}{0}}
{\refstepcounter{problem}
\shufflefalse
\global\firstproblemtrue}
\newenvironment{exercise}[1][2in]
{\iffirstproblem
\def\spaceatend{#1}\refstepcounter{problem}\refstepcounter{problemType}
\begin{trivlist}\item[\hskip\labelsep\sffamily\bfseries
Exercise \ifhandout\theproblem\else\ifshuffle\theproblem.\theproblemType\else\theproblem\fi\fi]
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
\newenvironment{problem}[1][2in]
{\iffirstproblem
\def\spaceatend{#1}\refstepcounter{problem}\refstepcounter{problemType}
\begin{trivlist}\item[\hskip\labelsep\sffamily\bfseries
Problem \ifhandout\theproblem\else\ifshuffle\theproblem.\theproblemType\else\theproblem\fi\fi]
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
\newenvironment{question}[1][2in]
{\iffirstproblem
\def\spaceatend{#1}\refstepcounter{problem}\refstepcounter{problemType}
\begin{trivlist}\item[\hskip\labelsep\sffamily\bfseries
Question \ifhandout\theproblem\else\ifshuffle\theproblem.\theproblemType\else\theproblem\fi\fi]
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
\newenvironment{exploration}[1][2in]
{\iffirstproblem
\def\spaceatend{#1}\refstepcounter{problem}\refstepcounter{problemType}
\begin{trivlist}\item[\hskip\labelsep\sffamily\bfseries
Exploration \ifhandout\theproblem\else\ifshuffle\theproblem.\theproblemType\else\theproblem\fi\fi]
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
%% Solution environment
\newenvironment{solution}{
\ifhandout\setbox0\vbox\bgroup\else
\begin{trivlist}\item[\hskip \labelsep\small\itshape\bfseries Solution\hspace{2ex}]
\par\noindent\upshape\small
\fi}
{\ifhandout\egroup\else
\end{trivlist}
\fi}
\newenvironment{multiple-choice}[1][] %% should be deprecated
{\begin{enumerate}}
{\end{enumerate}}
%% interactive envrironment
\NewEnviron{interactive}[1][]{\BODY}
%% these may be changed in the future to work more like interactive.
%% expression-answer envrironment
\NewEnviron{expression-answer}[1][]{} %% should be deprecated
%% matrix-answer envrironment
\NewEnviron{matrix-answer}[1][]{} %% should be deprecated
%% free-response answer envrironment
\NewEnviron{free-response}[1][]{\BODY} %% should be deprecated
%% Feedback
\ifhandout
\newenvironment{feedback}{\setbox0\vbox\bgroup}
{\egroup}
\else
\newenvironment{feedback}[1][attempt]
{\begin{trivlist}\item[\hskip \labelsep\small\slshape\bfseries Feedback (#1):\hspace{2ex}]\small\slshape}
{\end{trivlist}}
\fi
%% Hints
\ifhandout
\newenvironment{hint}{\setbox0\vbox\bgroup}
{\egroup}
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
%% Dialogue
\newenvironment{dialogue}{%
\renewcommand\descriptionlabel[1]{\hspace{\labelsep}\textbf{##1:}}
\begin{description}%
}{%
\end{description}%
}
%% \newenvironment{hint}{
%% \ifhandout\setbox0\vbox\bgroup\else
%% \begin{trivlist}\item[\hskip \labelsep\small\slshape\bfseries Hint:\hspace{2ex}]
%% \small\slshape
%% \fi}
%% {\ifhandout\egroup\else
%% \end{trivlist}
%% \fi}
\newcounter{problem} %% for the main problem
\newcounter{problemType} %% for variations within shuffle
% SlantTheorem appears not to be used
%\newtheoremstyle{SlantTheorem}
% {\topsep}{\topsep} %%% space between body and thm
% {\slshape} %%% Thm body font
% {} %%% Indent amount (empty = no indent)
% {\bfseries} %%% Thm head font
% {} %%% Punctuation after thm head
% {\labelsep} %%% Space after thm head
% {\thmname{#1}\thmnumber{ #2}\thmnote{ \bfseries(#3)}}%%% Thm head spec
%\theoremstyle{SlantTheorem}
%---------------------------------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------
%---------------------------------------------------------------------