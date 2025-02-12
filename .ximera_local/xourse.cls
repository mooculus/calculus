%%
%% This is file `xourse.cls',
%% generated with the docstrip utility.
%%
%% The original source files were:
%%
%% ximera.dtx  (with options: `classXourse')
%% src/optionsxourse.dtx  (with options: `classXourse')
%% src/activity.dtx  (with options: `classXourse')
%% src/sectioning.dtx  (with options: `classXourse')
%% src/logo.dtx  (with options: `classXourse')
%% src/graded.dtx  (with options: `classXourse')
%% ------------:| ------------------------------------------------------------
%%       ximera:| Simultaneously writing print and online interactive materials
%%       Author:| Jim Fowler and Oscar Levin and Jason Nowell and Wim Obbels and Hans Parshall and Bart Snapp
%%       E-mail:| bart.snapp@gmail.com
%%      License:| Released under the LaTeX Project Public License v1.3c or later
%%          See:| http://www.latex-project.org/lppl.txt
%% 
\NeedsTeXFormat{LaTeX2e}[1999/12/01]
\ProvidesClass{xourse}
 [2024/05/12 v1.5.1
 Combining Ximera activities into Xourses]


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

\newif\ifnotoc
\notocfalse
\DeclareOption{notoc}{\notoctrue}
\newif\ifnonewpage
\nonewpagefalse
\DeclareOption{nonewpage}{\nonewpagetrue}
\DeclareOption*{\PassOptionsToClass{\CurrentOption}{ximera}}
\ProcessOptions\relax
\LoadClass{ximera}

\newcommand{\skip@preamble}{%
    \let\document\relax\let\enddocument\relax%
    \newenvironment{document}{\let\input\otherinput}{}%
    \renewcommand{\documentclass}[2][subfiles]{}}
\let\otherinput\input
\let\othermaketitle\maketitle
\renewcommand{\maketitle}{ %
\pagestyle{empty}
\begin{center}
~\\ %puts space at top of page to move title down.
\vskip .25\textheight
\hrulefill\\
\vskip 1em
\bfseries{\Huge \@title} \\
\hrulefill\\
\vskip 3em
{\Large \@author}
\vskip 2em
{\large \@date}
\end{center}
\clearpage
\ifnotoc
\else
  \tableofcontents\clearpage
  \clearpage
\fi
\pagestyle{main}
\let\maketitle\othermaketitle
}
\relax

\ifnonewpage
\newcommand{\activity}[2][]{%
\setkeys{activity}{#1}
  \renewcommand{\input}[1]{}
  \begingroup\skip@preamble\otherinput{#2}\endgroup\par\vspace{\topsep}
  \let\input\otherinput}
\else
\newcommand{\activity}[2][]{%
\setkeys{activity}{#1}
  \renewcommand{\input}[1]{}
  \begingroup\skip@preamble\otherinput{#2}\endgroup\clearpage
  \let\input\otherinput}
\fi
\relax


\ifxake
\renewcommand\activity[2][]{}
\fi

\ifhandout
\newcommand{\practice}[2][]{
\setkeys{practice}{#1}%!!!!!
  \renewcommand{\input}[1]{}
  \begingroup\skip@preamble\otherinput{#2}\endgroup
  \let\input\otherinput}
\else
\newcommand{\practice}[2][]{\texttt{\detokenize{#2}}%% gives file name for practice
\setkeys{practice}{#1}%!!!!!
  \renewcommand{\input}[1]{}
  \begingroup\skip@preamble\otherinput{#2}\endgroup
  \let\input\otherinput}
\fi
\relax

\ifxake
\renewcommand\practice[2][]{}
\fi


\renewcommand*\l@section{\@dottedtocline{1}{1.5em}{4.2em}}
\renewcommand*\l@subsection{\@dottedtocline{2}{3.8em}{4.2em}}
\newcommand*{\logo}[1]{%
  \ifx\@onlypreamble\@notprerr
    \ClassError{xourse}{logo can only be used in the preamble}
      {Move your logo command to the preamble}
  \else %
    \IfFileExists{#1}%
      {\gdef\xourse@logo{#1}}%
      {\ClassError{xourse}{logo file does not exist}
        {To use logo, make sure that the referenced image file exists}}%
  \fi%
}


\newenvironment{graded}[1]{}{}
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
%% End of file `xourse.cls'.
