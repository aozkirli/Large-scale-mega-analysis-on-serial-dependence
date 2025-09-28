This repository contains the standardized datasets from 22 studies (standardized versions, please refer to the relevant studies for raw data) as well as preprocessing and analysis codes to reproduce the results and figures in the manuscript:

“Large-scale mega-analysis reveals detrimental effects of serial dependence on perceptual decision-making”

by Ozkirli, Chetverikov and Pascucci (2025) in Nature Human Behavior.

The code was implemented on MATLAB 2023b.

Folders:

- data: .csv files for each study and experiment in a specific format from the raw data available online
- code: MATLAB scripts to preprocess and analyse the datasets in the folder “data”. The MATLAB script “main.m” does all the job and creates the figures. The results, figures and tables are then saved in the “results“ folder.
- results: where the outputs are saved (tables, csv files, figures etc.), it is automatically created in preprocess_create_master_table.m. 
	
