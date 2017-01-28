# Doctoral Thesis Work

In this repo I catalogue the research in support of my dissertation in the Economic Analysis PhD program at the Autonomous University of Barcelona. A lot of this work is currently in progress and changes are always happening.

The current project analyses the effects of internal migration on the human capital attainment of children in Indonesia. Given the endogeneity due to self-selection associated with migration and educational decisions, a discrete choice model is proposed and currently under evaluation as the causal mechanism.

## Data Sources
The source of my data is the [RAND corporation's Indonesian Family Life Survey](http://www.rand.org/labor/FLS/IFLS.html), an on-going longitudinal study of Indonesian households. Hypothesizing that expected wages form the basis of economic migration decisions, I augment the wages of this dataset with the 1995 Indonesian Census available at [IPUMS International.](https://international.ipums.org/international) This is done to yield more consistent estimates of median wages across provinces. To realize wages and other pecuniary costs I utilize GDP deflator and PPP data from the World Bank to transform hourly wages into international dollars for more interpretable results.

## Files and Folders of Interest

### Presentations and Draft Thesis Chapters

Work pertaining to the development of thesis chapters and presentations given in the evaluation phases. These are drafts and should not be reproduced. In particular, and as is usually the case, the introduction of the chapters are to be revisited and revised, particularly those of the first chapter contained in the folder 'Year 3 Evaluation/Year 3 Paper' (corresponding to the first year of the PhD phase). Furthermore, several aspects of the appendix located in Chapter 2's draft (located in the Year 4 folder, corresponding the second year of the PhD phase) need to be folded into Chapter 1's descriptive sections (such as the wage analysis section). 

## Project Files

This folder contains the bulwark of the analysis regarding the data. Within this section one will find the STATA DO files associated with the cleaning and analysis of the dataset, including the code to reconstruct the longitudinal aspects of the IFLS survey. 

Here I have reconstructed the longitudinal datasets of wages, educational attainment, migrations, and marriage histories of the interviewed households for waves 1-4 (wave 5, released in May 2016 has not been incorporated, nor has the IFLS East 2012 survey - an offshoot of the IFLS study to account for the eastern portions of the country). The goal of this as can be seen in the subsection concerning the construction of the dynasties, is to produce a dataset similar in structure to the PSID and NLSY. 

### IPUMS and Inflation

STATA Do files and data sourced from IPUMS international and the World Bank. The chosen method of realizing monetary data (such as hourly wages, bride price/dowries, property and other endowments, household per capita expenditures, etc.) is on a PPP basis. The benefit is that the data is now in international dollars and so is easier to conceptualize vs. utilizing the CPI and maintaining data in Indonesian Rupiahs (converting to US$ ad hoc with fluctuating exchange rates when needed to provide interpretable figures). The downside of realizing the data at the country level is that there is heterogeneity within Indonesian provinces, and even within regions, concerning PPP and CPI which is not accounted for with this data. However, yearly data at a finer level is not available and so I am forced to accept the measurement error. 

### Python Visualization of Indonesian Statistics

This folder contains the work associated with identifying the geocodes of administrative levels for geospatial work. As migration distances are a primary cost that may inhibit migration between regions, these geocodes provide the basis of calculating great-circle distances between the centroids of regions as identified by the Google Maps API. 

To visualize data using shape files variously scattered across the web, and taking into consideration that Indonesian administrative regions are ever-changing, I provide the Python code associated with the scraping and cleaning of a text file provided by another user's repo. This repo contains the Indonesian Statistical Office (BPS) hierarchical coding of provinces and regencies with their associated names. This is the scheme used by RAND to codify household locations, migrations, and place of birth in the IFLS dataset. However, shape files may or may not contain these BPS identifiers of the admin levels. And if they do, they may be for a year in which provinces switched codes due to fragmentation of regions to construct new administration levels. This creates a challenge when attempting to map the codes of locations in the dataset to their admin levels by names. 

I use the Google Maps API, which is robust to misspellings, to scrape the JSON geographical data and create a SQLite database with the geocodes of all provinces, regencies/municipalities, and districts. I use the Python GeoPandas data frame to merge these locations by their geocodes into the polygons provided by the shape files to identify the regions. Once the locations are identifed spatial statistics can be visualized. These codes and the SQLite database are provided within a Jupyter Notebook. The spatial distributions of median wages (in Int$) and average schooling (in years) are provided as figures.

### Simulation of Model found in Draft Thesis Chapter 2

This folder contains the codes for modelling a simplified version of the model presented in the draft thesis chapter describing the proposed mechanism of study. To study a simple example I consolidate provinces into two island regions: all the provinces of Jawa and Sumatra are considered to be Region 1; and all other island groupings are considered as Region 2. I solve the model in Python and Matlab. However, due to the increase in speed afforded by the coupling of Python with Cython I choose to stick with these languages to develop the simulation of the model. I further make use of the GNU Sciendtific Library wrapped in Cython to reduce a critical bottleneck (forked from another user). The bottleneck results from the overhead generated when Cython calls the CPython API to execute the code that uses the SciPy stack to add the shocks to the simulation (an increase in speed of 3 orders of magnitude is afforded by using GSL-based methods). 

The folder contains the solution of a one period OLG model and the simulation of dynasties across generations for risk-neutral households subject to GE type 3 extreme value shocks (which makes the model analytically tractable and the dynamic programming simple). These codes are located both in Jupyter Notebooks and in Python and Cython codes scripts (along with the associated C codes and shared library .so files from compiling the Cython code - Windows users may recompile the C code to obtain the dll for the generation of the extension module). There is also a Jupyter Notebook containing some light unit testing of the functions in the simulation code for easier identification of problems prior to implementation. 

Finally, there is a Jupyter Notebook that contains modules of Fortran BLAS subroutines programmed in Cython as these (matrix multiplication and inversion) will be needed for future work with low-level optimisation. Of interest is that my Cython matrix inversion function that both checks for singularity and inverts the matrix when it is non-singular is slightly faster than the corresponding numpy inversion method (the numpy inversion routine is not robust against singularity).

