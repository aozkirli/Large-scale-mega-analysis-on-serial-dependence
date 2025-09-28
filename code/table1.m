function table1()
%% Table1: summary of datasets
tbl = readtable(['..' filesep 'results' filesep 'SD_ma_master_table.csv']);

datasets     = unique(tbl.studynum);  % Get unique dataset codes
n_datasets   = numel(datasets);
variable     = 'error_ori_deb';  % Variable for which to compute trial counts
report_table = table();  % Initialize report table

% Loop over each dataset and compute trial counts
for i = 1:n_datasets
    tmp          = tbl(tbl.studynum==i, :);  % Subset data for the current dataset

    % Prepare report row with dataset info
    [ID, Study, Datasets, Stimulus, N, AllTrials, CleanTrials] = deal(...
        {num2str(i)}, tmp.study(1), length(unique(tmp.codenum)), tmp.stimulus(1), ...
        numel(unique(tmp.obsid)), length(tmp.(variable)), sum(isfinite(tmp.(variable)) & abs(tmp.delta)<=90));

    % Append report row to report table
    report_i     = table(ID, Study, Stimulus, Datasets,  N, AllTrials, CleanTrials);
    report_table = vertcat(report_table, report_i);
end
[ID, Study, Stimulus, Datasets, N, AllTrials, CleanTrials] = deal({' '},{' '},{'Total'},sum(report_table.Datasets),sum(report_table.N),sum(report_table.AllTrials),sum(report_table.CleanTrials));
report_i     = table(ID, Study, Stimulus, Datasets,  N, AllTrials, CleanTrials);
report_table = vertcat(report_table, report_i);
writetable(report_table,['..' filesep 'results' filesep 'tables' filesep 'summary_studies.csv'])

end