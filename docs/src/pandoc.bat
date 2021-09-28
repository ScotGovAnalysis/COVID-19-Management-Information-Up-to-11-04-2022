@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

rem Most commonly modified variables
set output_filename=covid-19-mi-desk-instructions
set include_paths=metadata.yaml

rem Paths
set pandoc_path=C:\Program Files\Pandoc\pandoc.exe
set input_folder=markdown\
set output_folder=..\

rem Aesthetic settings
set toc_depth=1

rem Recursively get input file paths, and build input string
set input_paths="%include_paths%"
echo Finding input files in "%input_folder%" ...
for /r %input_folder% %%I in (*.md) do (
  echo - %%~nxI
  set input_paths=!input_paths! "!input_folder!%%~nxI"
)
echo Done.
echo.

rem Create output folder, if it does not already exist
if not exist %output_folder% (
  echo Output directory does not exist. Creating %output_folder% ...
  mkdir %output_folder%
  echo Done.
  echo.
)

rem Output to a Word Document (DOCX)
set output_path=%output_folder%%output_filename%.docx
echo Converting to a Word Document (DOCX) ...
echo Output path: "%output_path%"
"%pandoc_path%" %input_paths% -o "%output_path%" --reference-doc="pandoc\template.docx" --number-sections --toc --toc-depth=%toc_depth% --verbose
echo Done.
echo.

rem Output to PDF
set output_path=%output_folder%%output_filename%.pdf
echo Converting to a PDF document ...
echo Output path: "%output_path%"
"%pandoc_path%" "pandoc/pdf-latex-variables.yaml" %input_paths% -o "%output_path%" --pdf-engine=xelatex --number-sections --toc --toc-depth=%toc_depth% --verbose
echo Done.
echo.

pause
