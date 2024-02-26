# MetaShiny

This is the code to run the app described in the manuscript: 

The app is hosted on Shinyapps.io here:

To run this app locally on your machine, download R or RStudio and run the following commands once to set up the environment:
```
source("server.R")
source("ui.R")
runApp()
```
You may now run the shiny app with just one command in R:

```
shiny::runGitHub("MetaShiny", "Nirmal2310")
```

Nirmal Singh Mahar<sup>1</sup>, Anshul Budhraja<sup>2</sup>, Suman Pakala<sup>3</sup>, Ishaan Gupta<sup>1</sup>*, Seesandra V. Rajagopala<sup>3</sup>\*.

<sup>1</sup>Department of Biochemical Engineering and Biotechnology, Indian Institute of Technology, New Delhi, India-110016

<sup>2</sup>Department of Medicine, Université de Montréal, Quebec, Canada

<sup>3</sup>Vanderbilt University Medical Center, Nashville, USA

*Corresponding Author

We would appreciate reports of any issues with the app via the issues option of 
[GitHub](https://github.com/Nirmal2310/MetaShiny) or by emailing metashiny.help@gmail.com.

# Instructions

Instructions can be found here: <https://github.com/Nirmal2310/MetaShiny/blob/main/Tabs/additional_information.md> 

# Licensing

This shiny code is licensed under the GPLv3. Please see the file LICENSE.txt for
information.

    MetaShiny App
    Shiny App for analysis and visualization of Metagenomics Data.
    Copyright (C) 2024 Nirmal Singh Mahar

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    and this program.  If not, see <http://www.gnu.org/licenses/>.

    You may contact the author of this code, Nirmal Singh Mahar, at <bez207518@iitd.ac.in>
    
# Software adapted for use in the pipeline:

- Fastp <https://academic.oup.com/bioinformatics/article/34/17/i884/5093234>
- BBSuite <https://jgi.doe.gov/data-and-tools/software-tools/bbtools/>
- SPAdes <https://www.ncbi.nlm.nih.gov/pmc/articles/PMC3342519/>
- metaWRAP <https://microbiomejournal.biomedcentral.com/articles/10.1186/s40168-018-0541-1>
- GTDB-tk v2 <https://academic.oup.com/bioinformatics/article/38/23/5315/6758240>
- RGI <https://academic.oup.com/nar/article/48/D1/D517/5608993>
- SAMtools <https://academic.oup.com/bioinformatics/article/25/16/2078/204688>

# DOI

[![DOI]()]
