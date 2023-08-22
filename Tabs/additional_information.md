---
output:
  html_document:
    theme: united
---
### **MetaShiny app allows users to analyze and visualize metagenomic short-read sequencing data.**

- It takes a list containing the sample name and the condition. 

- The Fastq file must have a the same name as the sample name in the list.

- The app will perform end to end analysis using the sequencing data with appropriate tools.

# **Instructions**

Code can be found on github: https://github.com/Nirmal2310/MetaShiny

Please post [issues on github](https://github.com/Nirmal2310/MetaShiny), and feel free to contribute by forking and submitting development branches.

To run this app locally on your machine, download R or RStudio in the local system.


You may now run the shiny app with just one command in R:

```
shiny::runGitHub("MetaShiny", "Nirmal2310")
```

If you are running the App for the first time please tick the checkbox "setup" in the Input Data tab to install the required tools, R packages and databases.

# **Input Data**

<a name="inputdata"></a> 

### **Input Data**

You can use this app by

1. Exploring the pre-loaded example data set. This is a pre-loaded metagenome DNA sequencing of ten samples example for exploring the app's features.
2. Upload your own data

<a name="dataformat"></a> 

### **Data Format** 

- Must be a .CSV *comma-separated-value* file.
- File must have a header row.
- First column must be named as `Sample_Id`.
- Second column must be named as `Group`.

<img src="input_data.png" alt="Input Data" style="width: 25%"/>

<a name="outputdata"></a> 

### **Ouput MetaData**

- Each row of the 3rd column represents the ARG term.
- Additional columns provide information about 
1) Sample Id
2) Bacterial Classification 
3) ARO Term
4) Counts
5) ARG Length
6) Percentage Identity
7) Drug Class
8) Resistance Mechanism
9) AMR Gene Family
10) Percentage Coverage
11) Normalized Counts
12) Bacterial Family
13) Group

All the subsequent visualizations will be done using this metadata.

Example file: <Sample_information.csv>

Analysis: When the list is uploaded, the data is then analyzed by the app. The app first utilizes fastp and bbtools for data pre-processing. The preprocessed FASTQ reads are then assembled using SPADES. The de novo assembled metagenome is then binned in MAGs using metaWRAP. The binned MAGs are annotated using GTDBtk. Antimicrobial Resistance Genes (AMRs) are then identified using RGI with CARD database. The counts for each ARG are calculated using SAMtools and the table from the unix pipeline contains the ARO term, Counts, Bacterial Classification and other terms. The counts for each ARG terms are then normalized using GPCM method in R and then utilized for further analysis and visualization in R.

<img src="gpcm_equation.png" alt="Output Data" style="width: 50%"/>

### **Analyzed Data**

<img src="output_data.png" alt="Output Data" style="width: 75%"/>

Example file: <consolidated_data.csv>

<a name="vis"></a> 

# **Visualizations**

### **ARG Cohort Analysis**

<a name="cohortanalysis"></a>

### **Drug Class**

This plot represents the resistance genes for antimicrobial drugs classified by the CARD database. The Y-axis represents the Drug class and X-axis represents the sum of all the ARG abundance belonging to the drug class.

<img src="Drug_class.png" alt="Drug Class vs. ARG Abundance" style="width: 100%"/>
 
### **Resistance Mechanism**

This plot displays the mechanism of resistance of each ARG, depicted as a proportion of all ARGs detected in the given cohort.
 
<img src="Resistance_mechanism.png" alt="Resistance Mechanism" style="width: 100%"/>

<a name="distributionplot"></a>

# **ARG Distribution among Bacterial Species**

### **ARG Richness Per Bacterial Species**
The circular plot shows the ARG richness (number of unique ARGs) for each bacterial species. The bars are grouped by the bacterial species family information. This plot shows the diversity of ARGs per bacterial species across the cohort.

<img src="ARG_cohort_richness.png" alt="Cohort ARG Richness" style="width: 100%"/>

### **ARG Abundance Per Bacterial Species**
The circular plot shows the AMR Gene Family abundance {(Normalized Counts/sum(Normalized counts))*100} that are grouped by the bacterial species. This plot shows the abundance of ARGs per bacterial species across the cohort.

<img src="ARG_Cohort_Abundance.png" alt="Cohort ARG Abundance" style="width: 100%"/>

Both these plots can be utilized to target the most significant AMR causing bacterial species.

<a name="alphadiversity"></a>

### **Alpha Diversity**

The plot shows the alpha diversity for each ARG terms. Alpha diversity is a measure of the number of species that are present in a given community. This plot compares the ARG diversity between Control and Case.

<img src="Alpha_diversity.png" alt="Alpha Diversity" style="width: 100%"/>

### **Abundance Diversity**

The plot shows the comparison between the abundance of each ARG term between the Control and Case. This plot is useful to identify the ARGs that are abundant in the Control but not in the Case. The *p-value* was calculated using Kruskal-Walis test.

<img src="Abundance_Kruskal_Walis.png" alt="Abundance Diversity" style="width: 100%"/>

<a name="betadiversity"></a>

### **PCA Plot**

This plot uses Principal Component Analysis (PCA) to calculate the principal components of the count data using data from all ARO terms. Samples are projected on the first two principal components (PCs) and the percent variance explained by those PCs are displayed along the x and y axes. Ideally your samples will cluster by group identifier.

<img src="PCA_plot.png" alt="PCA Plot" style="width: 100%"/>

### **HeatMap** 

This plot shows Heatmap with ARG abundance in terms of the log2(Normalized Counts) across the samples. Both samples and ARGs were clustered based on ARG abundance with Euclidean distance by complete linkage hierarchical clustering.

<img src="HeatMap.png" alt="HeatMap" style="width: 100%"/>