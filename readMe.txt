This repository contains the standardized datasets from 22 studies (standardized versions, please refer to the relevant studies for raw data) as well as preprocessing and analysis codes to reproduce the results and figures in the manuscript:

“Large-scale mega-analysis indicates that serial dependence deteriorates perceptual decision-making”

by Ozkirli, Chetverikov and Pascucci (2025) in Nature Human Behavior.

##########################################################################################
############################### IMPORTANT ABOUT LICENSING: ###############################
##########################################################################################

Future studies using this compiled dataset are obligated to cite the paper Ozkirli, Chetverikov & Pascucci (2025) published in Nature Human Behavior, as well as those original datasets that they are using. 
References to the 22 individual studies used in this study are provided below:

1) Abreo, S., Gergen, A., Gupta, N. & Samaha, J. Effects of satisfying and violating expectations on serial dependence. J. Vis. 23, 6–6 (2023).
2) Blondé, P., Kristjánsson, Á. & Pascucci, D. Tuning perception and decisions to temporal context. iScience 108008 (2023) doi:10.1016/j.isci.2023.108008.
3) Ceylan, G. & Pascucci, D. Attractive and repulsive serial dependence: The role of task relevance, the passage of time, and the number of stimuli. J. Vis. 23, 8 (2023).
4) Ceylan, G., Herzog, M. H. & Pascucci, D. Serial dependence does not originate from low-level visual processing. Cognition 212, 104709 (2021).
5) Chetverikov, A. & Jehee, J. F. M. Motion direction is represented as a bimodal probability distribution in the human visual cortex. Nat. Commun. 14, 7634 (2023).
6) Cicchini, G. M., Mikellidou, K. & Burr, D. The functional role of serial dependence. Proc. R. Soc. B 285, 20181722 (2018).
7) Fischer, J. & Whitney, D. Serial dependence in visual perception. Nat. Neurosci. 17, 738–743 (2014).
8) Fischer, C. et al. Context information supports serial dependence of multiple visual objects across memory episodes. Nat. Commun. 11, 1–11 (2020).
9) Fritsche, M. & de Lange, F. P. The role of feature-based attention in visual serial dependence. J. Vis. 19, 21 (2019).
10) Fritsche, M., Spaak, E. & de Lange, F. P. A Bayesian and efficient observer model explains concurrent attractive and repulsive history biases in visual perception. eLife 9, e55389 (2020).
11) Gallagher, G. K. & Benton, C. P. Stimulus uncertainty predicts serial dependence in orientation judgements. J. Vis. 22, 6–6 (2022).
12) Geurts, L. S., Cooke, J. R., van Bergen, R. S. & Jehee, J. F. Subjective confidence reflects representation of Bayesian probability in cortex. Nat. Hum. Behav. 6, 294–305 (2022).
13) Houborg, C., Pascucci, D., Tanrıkulu, Ö. D. & Kristjánsson, Á. The effects of visual distractors on serial dependence. J. Vis. 23, 1 (2023).
14) Houborg, C., Kristjánsson, Á., Tanrıkulu, Ö. D. & Pascucci, D. The role of secondary features in serial dependence. J. Vis. 23, 21 (2023).
15) Kondo, A., Murai, Y. & Whitney, D. The test-retest reliability and spatial tuning of serial dependence in orientation perception. J. Vis. 22, 5 (2022).
16) Lau, W. K. & Maus, G. W. Visual serial dependence in an audiovisual stimulus. J. Vis. 19, 20–20 (2019).
17) Moon, J. & Kwon, O.-S. Attractive and repulsive effects of sensory history concurrently shape visual perception. BMC Biol. 20, 247 (2022).
18) Moon, J., Tadin, D. & Kwon, O.-S. A key role of orientation in the coding of visual motion direction. Psychon. Bull. Rev. 30, 564–574 (2023).
19) Ozkirli, A. & Pascucci, D. It’s not the spoon that bends: Internal states of the observer determine serial dependence. (2023) doi:10.1101/2023.10.19.563128.
20) Pascucci, D. et al. Intact Serial Dependence in Schizophrenia: Evidence from an Orientation Adjustment Task. Schizophr. Bull. sbae106 (2024).
21) Sadil, P., Cowell, R. A. & Huber, D. E. The push–pull of serial dependence effects: Attraction to the prior response and repulsion from the prior stimulus. Psychon. Bull. Rev. 1–15 (2024).
22) Samaha, J., Switzky, M. & Postle, B. R. Confidence boosts serial dependence in orientation estimation. J. Vis. 19, 25–25 (2019).

**** IMPORTANT: Studies 9, 10, and 12 are currently undergoing a new licensing agreement. As soon as we receive authorization, we will upload them here and make them publicly available. *** 

#############################################################################################
############################### INFORMATION ABOUT REPOSITORY: ###############################
#############################################################################################

The code was implemented on MATLAB 2023b.

Folders:

- data: .csv files for each study and experiment in a specific format from the raw data available online
- code: MATLAB scripts to preprocess and analyse the datasets in the folder “data”. The MATLAB script “main.m” does all the job and creates the figures. The results, figures and tables are then saved in the “results“ folder.
- results: where the outputs are saved (tables, csv files, figures etc.), it is automatically created in preprocess_create_master_table.m. 

Columns of CSV files for standardized versions of original datasets:

- delta: acute angle calculated as sdp_acute_ang(previous target feature - current target feature) 
- theta: current target feature
- response: adjustment response
- error: adjustment error calculated as sdp_acute_ang(current adjustment response - current target feature)
- rt: adjustment response time (set to 9 if not available in the original dataset)
- obs: unique (within dataset) observer (participant) id
- block: unique block id 
- cond: unique condition id that influences error scatter (e.g., uncertainty of the target stimulus)
- study: char array for study reference
- experiment: experiment id within study
- stimulus: char array for the target feature type (Orientation or Motion)
- expnum: integer codes representing experiment variable

Preprocessed table after running the code:

In addition to the variables above, the preprocessing adds following columns to the master .csv file:

- studynum: integer code for study number, ranging from 1 to 22
- stimtype: integer code for stimulus variable, 1=Orientation 2=Motion
- code: char array describing the dataset (e.g., 01 Abreo et al. (2023))
- obsid: unique observer (participant) id across the master dataset, ranging from 1 to 733
- bin: delta bin used for model-free analyses, 1 if 0<=|delta|<=10; 2 if 40<=|delta|<=50; 3 if 80<=|delta|<=90; NaN else
- outliers_q: flag outlier trials for each grouping level (dataset/participant/condition) using isoutlier(X,'quartiles'), 1 if outlier, 0 otherwise (we recommend using this as it does not assume normality)
- outliers_sd: flag outlier trials for each grouping level (dataset/participant/condition) using isoutlier(X,'mean'), 1 if outlier, 0 otherwise
- outliers_rt: flag outlier trials based on adjustment response time, 1 if rt>10, 0 otherwise
- error_iqr: identical to error variable if not outlier, NaN if outlier based on outliers_iqr and outliers_rt
- error_sd: identical to error variable if not outlier, NaN if outlier based on outliers_sd and outliers_rt 
- mfree_ss_bias: error_iqr if ismember(theta,[10:25 100:115]), -error_iqr if ismember(theta,[65:80 155:170]), NaN otherwise. Used to calculate the model free stimulus-specific bias
- theta_cent: theta-90 if Orientation dataset, theta-180 if motion dataset
- error_ori_deb: adjustment errors after removing stimulus-specific bias, calculated as erroriqr - predicted orientation bias pattern using sine and cosine functions
- error_ori_deb_sd_deb: adjustment errors after removing stimulus-specific bias and serial dependence bias, calculated as error_ori_deb - predicted serial dependence bias pattern using sine and cosine functions
- error_norm: zscored error variable (for each grouping level separately)
- error_ori_deb_norm: zscored error_ori_deb variable (for each grouping level separately)
- error_ori_deb_sd_deb_norm: zscored error_ori_deb_sd_deb variable (for each grouping level separately)
- mfree_sd_bias_factor: 1 if ismember(delta,[1:45]), -1 if ismember(delta,[-45:-1]), 0 if delta==0, NaN otherwise. Used to calculate the model free serial dependence bias


