function linear_mixed_models()
%% runs LMMs (full and reduced) to compare the error scatter at different feature distances
load(['..' filesep 'results' filesep 'sd_estimates.mat'],'tbl_scatter')

%% Linear Mixed Models
% Using polynomial estimates
delete(['..' filesep 'results' filesep 'tables' filesep 'LME.txt'])
diary(['..' filesep 'results' filesep 'tables' filesep 'LME.txt'])
disp('----------------------------------------------------------------------')
disp('**********************************************************************')
disp('----------------------------------------------------------------------')
disp(' ')
disp('Using polynomial estimates:')
disp(' ')

% fit full LMM
tbl_scatter.SI = categorical(tbl_scatter.SI);
lmm             = fitlme(tbl_scatter,'ES ~ SI + (1+SI|obsid) + (1+SI|codenum) + (1+SI|codenum:obsid)');
disp(lmm)

% fit reduced LMM
tbl_scatter.new_SI = repmat(categorical([1 2 1]'),height(tbl_scatter)/3,1);
reduced_lmm = fitlme(tbl_scatter, 'ES ~ new_SI + (1+new_SI|obsid) + (1+new_SI|codenum) + (1+new_SI|codenum:obsid)');


% to compare the models
bic_full = lmm.ModelCriterion.BIC;
bic_reduced = reduced_lmm.ModelCriterion.BIC;
dBIC = bic_reduced-bic_full;
BF_reduced_over_full = 1/exp((bic_reduced-bic_full)/2);
disp(['dBIC = ' num2str(dBIC) ', and BF_reduced_over_full = ' num2str(BF_reduced_over_full)])

[heterogeneity_results] = assess_categorical_heterogeneity(lmm);

% Using model-free estimates
disp(' ')
disp('----------------------------------------------------------------------')
disp('**********************************************************************')
disp('----------------------------------------------------------------------')
disp(' ')
disp('Using model-free estimates:')
disp(' ')
lmm             = fitlme(tbl_scatter,'bin_scatter ~ SI + (1+SI|obsid) + (1+SI|codenum) + (1+SI|codenum:obsid)');
disp(lmm)
tbl_scatter.new_SI = repmat(categorical([1 2 1]'),height(tbl_scatter)/3,1);
reduced_lmm = fitlme(tbl_scatter, 'bin_scatter ~ new_SI + (1+new_SI|obsid) + (1+new_SI|codenum) + (1+new_SI|codenum:obsid)');

bic_full = lmm.ModelCriterion.BIC;
bic_reduced = reduced_lmm.ModelCriterion.BIC;
dBIC = bic_reduced-bic_full;
BF_reduced_over_full = 1/exp((bic_reduced-bic_full)/2);

disp(['dBIC = ' num2str(dBIC) ', and BF_reduced_over_full = ' num2str(BF_reduced_over_full)])
diary off;

    function [heterogeneity_results] = assess_categorical_heterogeneity(lmm)
        % ASSESS_CATEGORICAL_HETEROGENEITY Calculate I² for categorical fixed effects
        % Input: lmm - fitted linear mixed effects model with categorical predictors
        % Output: heterogeneity_results - structure with I² values and interpretation

        % Get model components
        [psi, mse] = covarianceParameters(lmm);
        grouping_vars = {};
        for i = 1: length(lmm.Formula.GroupingVariableNames)-1
            if length(lmm.Formula.GroupingVariableNames{i})>1
                tmp = [];
                for j = 1: length(lmm.Formula.GroupingVariableNames{i})
                    tmp = [tmp lmm.Formula.GroupingVariableNames{i}{j}];
                    if j~= length(lmm.Formula.GroupingVariableNames{i})
                        tmp = [tmp ':'];
                    end
                end
                grouping_vars = [grouping_vars tmp];
            else
                grouping_vars = [grouping_vars lmm.Formula.GroupingVariableNames{i}{1}];
            end
        end
        fixed_effects = lmm.CoefficientNames;

        fprintf('=== HETEROGENEITY ASSESSMENT FOR CATEGORICAL SI ===\n\n');
        fprintf('Fixed Effects: ');
        for i = 1:length(fixed_effects)-1
            fprintf('%s ', fixed_effects{i});
        end
        fprintf('\n\n');

        % Initialize results
        heterogeneity_results = struct();

        % Process each grouping variable
        for g = 1:length(grouping_vars)
            group_name = grouping_vars{g};
            cov_matrix = psi{g};

            fprintf('\n===================================================================== \n')
            fprintf('\t\t Grouping Variable: %s \n', group_name);
            fprintf('===================================================================== \n')

            % Display the covariance matrix
            fprintf('Covariance Matrix:\n');
            for i = 1:size(cov_matrix,1)
                for j = 1:size(cov_matrix,2)
                    fprintf('   %8.4f ', cov_matrix(i,j));
                end
                fprintf('\n');
            end
            fprintf('\n');

            % Extract variances and calculate I²
            n_effects = size(cov_matrix, 1);

            fprintf('Heterogeneity by SI level/contrast:\n');

            % First element is usually intercept (reference category)
            % if n_effects >= 1
            %     intercept_var = cov_matrix(1,1);
            %     fprintf('  SI_iso');
            % end

            % Subsequent elements are contrasts vs reference
            for i = 1:n_effects
                contrast_var = cov_matrix(i,i);

                % Calculate I² = τ²/(τ² + σ²) where σ² is residual variance
                I_squared = (contrast_var / (contrast_var + mse)) * 100;

                % Interpretation
                if I_squared < 25
                    interpretation = 'Weak to no heterogeneity';
                elseif I_squared < 50
                    interpretation = 'Small heterogeneity';
                elseif I_squared < 75
                    interpretation = 'Medium heterogeneity';
                else
                    interpretation = 'Large heterogeneity';
                end

                % Try to match with fixed effect names (skip intercept)
                if i <= length(fixed_effects)
                    effect_name = fixed_effects{i};
                else
                    effect_name = sprintf('Contrast_%d', i-1);
                end

                fprintf('  %s: \tτ² = %.2f, \tI² = %.2f%% \t(%s)\n', ...
                    effect_name, contrast_var, I_squared, interpretation);

                % Store results
                field_name = sprintf('%s_%s', matlab.lang.makeValidName(group_name), ...
                    matlab.lang.makeValidName(effect_name));
                heterogeneity_results.(field_name) = struct(...
                    'GroupingVariable', group_name, ...
                    'Effect', effect_name, ...
                    'TauSquared', contrast_var, ...
                    'I_Squared', I_squared, ...
                    'Interpretation', interpretation);
            end
            fprintf('\n');
        end

        % Summary
        % fprintf('=== SUMMARY ===\n');
        % fprintf('Residual variance (σ²): %.6f\n\n', mse);

    end

end