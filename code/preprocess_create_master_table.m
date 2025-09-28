function preprocess_create_master_table()
% Add the shared folder path containing necessary functions
addpath(genpath('utils'))
%% 
clear all; close all; clc 

nanunique = @(x) unique(x(~isnan(x)));

% Get the full path of the current script
scriptPath = mfilename('fullpath');

% Extract directory path of the current script
[currentDir, ~, ~] = fileparts(scriptPath);

% Change to 'studies' directory
cd(['..' filesep 'data'])

% List all .mat files in the directory
csvfiles = dir('*.csv'); 
csvfiles = {csvfiles.name};

% Get unique study names from the file list
study_list = unique(cellstr(csvfiles));

% Standardize key variables to be used from each dataset
variables = {'obs','theta','resp','delta','error','cond','rt','block','study','experiment','stimulus','expnum'};

fprintf('\nGenerating Master table\n\n');
master_tbl = table;  % Initialize empty master table

% Loop over each study to load and process its data
for i = 1:length(study_list)
    tbl = readtable(csvfiles{i});
    % load(csvfiles{i});
    
    % Add 'cond', 'block', and 'rt' columns if missing
    if nnz(ismember(tbl.Properties.VariableNames,'cond')) == 0
        tbl.cond = ones(size(tbl.obs));
    end
    if nnz(ismember(tbl.Properties.VariableNames,'block')) == 0
        tbl.block = ones(size(tbl.obs));
    end
    if nnz(ismember(tbl.Properties.VariableNames,'rt')) == 0
        tbl.rt = 9 * ones(size(tbl.obs));  % Default value if 'rt' is missing
    end

    % Keep only the standardized variables in 'tbl'
    idx = find(ismember(tbl.Properties.VariableNames, variables));
    tbl = tbl(:, idx);
    
    % Add 'stimtype' (logical flag for 'Orientation') and 'studynum'
    tbl.stimtype = strcmpi(tbl.stimulus, 'Orientation');
    tbl.studynum = i * ones(size(tbl.stimtype));
    
    % Append data to the master table
    master_tbl = vertcat(master_tbl, tbl);        
end

fprintf('Master table ready with %d studies combined.\n\n', i);

%% Recoding observer IDs and handling dataset specifics

fprintf('\nRecode each dataset and incremental observer ID...\n\n');

master      = master_tbl;    % Copy master table
id_study    = unique(master.study);  % Get unique study names
n           = numel(id_study);
master_coded= table();       % Initialize an empty table for recoded data
n_subjects  = nan(n, 5);     % Preallocate for number of subjects per study
count       = 0;             % Counter for recoding

% Loop over each study
for i = 1:n
    tbl     = master(strcmp(master.study, id_study{i}),:);  % Get data for the current study
    id_expe = unique(tbl.experiment);  % Get unique experiments within the study
    n_exp   = numel(id_expe);
    
    % Loop over experiments within the study
    for j = 1:n_exp
        tbl_e            = tbl(strcmp(tbl.experiment, id_expe{j}),:);  % Get data for the current experiment
        n_subjects(i, j) = numel(nanunique(tbl_e.obs));  % Track the number of subjects
        
        % Fix subject numbering if necessary
        if n_subjects(i, j) ~= max(tbl_e.obs)
            ids = unique(tbl_e.obs);
            for kk = 1:n_subjects(i, j)
                tbl_e.obs(tbl_e.obs == ids(kk)) = kk;  % Reassign subject IDs
            end
        end
        
        id_cond = nanunique(tbl_e.cond);  % Get unique conditions
        n_cond  = numel(id_cond);
        
        % Loop over conditions within the experiment
        for k = 1:n_cond
            tbl_e_k = tbl_e(tbl_e.cond==id_cond(k),:);  % Get data for the current condition
            count   = count + 1;  % Increment the dataset counter
            
            % Assign a new code based on the count
            if count < 10
                numcode = ['0' num2str(count)];
            else
                numcode = num2str(count);
            end
            name = [numcode ' ' id_study{i}];
            
            % Append experiment number to the code if multiple experiments exist
            if n_exp > 1
                exp_code = num2str(j);
                name     = [name ' E' exp_code];
            end
            
            % Append condition number to the code if multiple conditions exist
            if n_cond > 1
                cond_code = num2str(k);
                name      = [name ' C' cond_code];
            end
            
            tbl_e_k.code = repmat({name}, numel(tbl_e_k.obs), 1);  % Assign the code to all rows
            
            % Update 'obsid' with incremental IDs for each observer
            if i == 1
                tbl_e_k.obsid = tbl_e_k.obs;
            elseif i > 1 && strcmp(tbl_e_k.study(1), master_coded.study(end)) && ...
                    (tbl_e_k.expnum(1) == master_coded.expnum(end))
                tbl_e_k.obsid = max(master_coded.obsid) - n_subjects(i, j) + tbl_e_k.obs;
            elseif i > 1 && (~strcmp(tbl_e_k.study(1), master_coded.study(end)) || ...
                    (tbl_e_k.expnum(1) ~= master_coded.expnum(end)))
                disp([tbl_e_k.study(1) tbl_e_k.experiment(1) n_subjects(i, j) ...
                    max(master_coded.obsid) master_coded.obsid(end) sum(n_subjects(:), 'omitnan')]);
                tbl_e_k.obsid = max(master_coded.obsid) + tbl_e_k.obs;
            end
            
            % Append the current condition data to the recoded master table
            master_coded = vertcat(master_coded, tbl_e_k);
        end
    end
end

master              = master_coded;  % Finalize the recoded master table
clear master_coded
fprintf('\nRecoding done.\n\n');

%% Error Preprocessing
nbasis  = 6;  % Number of basis functions for bias removal
st      = unique(master.study);  % Get unique study names
new_tbl = table();  % Initialize table to store preprocessed data
sd_mfreethr = [1:45;-45:-1]; % model free serial dependence bias abs delta range
ss_mfreethr = [10:25 100:115; 65:80 155:170];

% Loop over each study
for s = 1:numel(st)
    tbl_study = master(strcmp(master.study, st{s}),:);  % Subset data for the current study
    ex        = unique(tbl_study.experiment);  % Get unique experiments within the study
    
    % Round to integers both theta and delta
    tbl_study.theta    = round(tbl_study.theta);
    tbl_study.delta    = round(tbl_study.delta);

    % Loop over each experiment
    for j = 1:numel(ex)
        tbl_experiment = tbl_study(strcmp(tbl_study.experiment, ex{j}),:);  % Subset data for the current experiment
        cn             = unique(tbl_experiment.cond);  % Get unique conditions
        
        % Loop over each condition
        for k = 1:numel(cn)
            tbl_condition = tbl_experiment(tbl_experiment.cond==cn(k),:);  % Subset data for the current condition
            sb            = unique(tbl_condition.obs);  % Get unique subjects
            
            % Loop over each subject
            for i = 1:numel(sb)
                tbl_subject   = tbl_condition(tbl_condition.obs==sb(i),:);  % Subset data for the current subject
                
                % Create bins for model-free analyses
                tbl_subject.bin = nan(size(tbl_subject.resp));
                tbl_subject.bin(abs(tbl_subject.delta)<=10) = 1;
                tbl_subject.bin(abs(tbl_subject.delta)>=40 & abs(tbl_subject.delta)<=50) = 2;
                tbl_subject.bin(abs(tbl_subject.delta)>=80 & abs(tbl_subject.delta)<=90) = 3;

                % Remove improbable data (errors > 90° likely only in motion data)
                out           = abs(tbl_subject.error) > 90;
                erroriqr      = tbl_subject.error;
                errorsd       = tbl_subject.error;
                erroriqr(out) = nan;
                errorsd(out)  = nan;
                
                % Remove outliers based on quartiles
                out_q         = isoutlier(erroriqr, 'quartiles');
                erroriqr(out_q)  = nan;

                % Separate variable removing errors based on 3std
                out_sd        = abs(errorsd)>(mean(abs(errorsd),'omitnan')+3*std(errorsd,'omitnan'));
                errorsd(out_sd)  = nan;
                
                % Remove outliers based on reaction time (> 10s)
                out_rt        = tbl_subject.rt > 10;
                erroriqr(out_rt) = nan;
                errorsd(out_rt)  = nan;

                % Store outliers in new columns
                tbl_subject.outliers_q = out_q;
                tbl_subject.outliers_sd = out_sd;
                tbl_subject.outliers_rt  = out_rt;
                
                % Store the 3SD cleaned error with no other prep 
                tbl_subject.error_iqr = erroriqr;
                tbl_subject.errorsd = errorsd;

                % Save model-free stimulus-specific bias 
                tbl_subject.mfree_ss_bias_factor = nan(size(tbl_subject.theta));
                tbl_subject.mfree_ss_bias_factor(ismember(tbl_subject.theta,ss_mfreethr(1,:))) = tbl_subject.error_iqr(ismember(tbl_subject.theta,ss_mfreethr(1,:)));
                tbl_subject.mfree_ss_bias_factor(ismember(tbl_subject.theta,ss_mfreethr(2,:))) = -tbl_subject.error_iqr(ismember(tbl_subject.theta,ss_mfreethr(2,:)));

                %% Orientation Bias Correction
                % Convert angles to full angular space and radians
                if strcmp(tbl_subject.stimulus, 'Orientation')
                    theta360 = tbl_subject.theta * 2;  % Scale by 2 for orientation data
                    tbl_subject.theta_cent = tbl_subject.theta - 90;  % Center angles around 90°
                else
                    theta360 = tbl_subject.theta;
                    tbl_subject.theta_cent = tbl_subject.theta - 180;  % Center angles around 180°
                end
                
                % Create sine and cosine basis sets
                Xsin = nan(size(theta360, 1), nbasis);
                Xcos = nan(size(theta360, 1), nbasis);
                for b = 1:nbasis
                    Xsin(:, b) = sin(deg2rad(theta360 * b));
                    Xcos(:, b) = cos(deg2rad(theta360 * b));
                end
                
                % Fit and remove orientation bias using regression
                X              = horzcat(ones(size(Xsin, 1), 1), Xsin, Xcos);  % Include intercept
                nanout         = isnan(erroriqr) | isnan(X(:, 2));  % Identify rows with NaN values
                beta           = pinv(X(~nanout, :)) * erroriqr(~nanout);  % Fit model
                predicted      = X * beta;  % Predicted error based on orientation]
                tbl_subject.error_ori_deb = erroriqr - predicted;  % Demean the errors

                
                %% Serial Dependence Bias Correction
                % Convert angles to full angular space
                if strcmp(tbl_subject.stimulus, 'Orientation')
                    delta360 = tbl_subject.delta * 2;  % Scale by 2 for orientation data
                else
                    delta360 = tbl_subject.delta;
                end
                
                % Create sine and cosine basis sets
                Xsin = nan(size(delta360, 1), nbasis);
                Xcos = nan(size(delta360, 1), nbasis);
                for b = 1:nbasis
                    Xsin(:, b) = sin(deg2rad(delta360 * b));
                    Xcos(:, b) = cos(deg2rad(delta360 * b));
                end
                
                % Fit and remove serial dependence bias using regression
                error          = tbl_subject.error_ori_deb;  % Start with errors corrected for orientation bias
                X              = horzcat(Xsin, Xcos);  % Intercept already removed above
                nanout         = isnan(error) | isnan(X(:, 2));  % Identify rows with NaN values
                beta           = pinv(X(~nanout, :)) * error(~nanout);  % Fit model
                predicted      = X * beta;  % Predicted error based on serial dependence
                tbl_subject.error_ori_deb_sd_deb = error - predicted;  % Demean the errors

                % Add a normalized version of the errors
                tbl_subject.error_norm = normalize(tbl_subject.error);
                tbl_subject.error_iqr_norm = normalize(tbl_subject.error_iqr);
                tbl_subject.error_ori_deb_norm = normalize(tbl_subject.error_ori_deb);
                tbl_subject.error_ori_deb_sd_deb_norm = normalize(tbl_subject.error_ori_deb_sd_deb);
        
                % Save model-free sd bias after cleaning
                tbl_subject.mfree_sd_bias_factor = nan(size(tbl_subject.delta));
                tbl_subject.mfree_sd_bias_factor(ismember(tbl_subject.delta,sd_mfreethr(1,:))) = tbl_subject.error_ori_deb(ismember(tbl_subject.delta,sd_mfreethr(1,:)));
                tbl_subject.mfree_sd_bias_factor(ismember(tbl_subject.delta,sd_mfreethr(2,:))) = -tbl_subject.error_ori_deb(ismember(tbl_subject.delta,sd_mfreethr(2,:)));
                tbl_subject.mfree_sd_bias_factor(tbl_subject.delta==0) = 0;

                % Append preprocessed data to new_tbl
                new_tbl        = vertcat(new_tbl, tbl_subject);
            end
        end
    end
end

% Add a numeric version of code
new_tbl.codenum = double(categorical(new_tbl.code));

master          = new_tbl;  % Update master table with preprocessed data
 
%% save
if ~exist(['..' filesep 'results'])
    mkdir(['..' filesep 'results'])
    mkdir(['..' filesep 'results' filesep 'figures'])
    mkdir(['..' filesep 'results' filesep 'tables'])
end
cd(['..' filesep 'results'])
tbl             = master;
clear master
tbl.theta(tbl.theta==180) = 0; % as 0 and 180 are the same in terms of orientation
tbl.delta(tbl.delta==-90) = 90; % as 90 and -90 are the same in terms of orientation
writetable(tbl,'SD_ma_master_table.csv','Delimiter',';')
cd(currentDir)
end
