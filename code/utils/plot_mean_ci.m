function [p,f] = plot_mean_ci(x, y, rep_size, mv_av, color, varargin)
if length(varargin) < 1
    stat_type   = 'mean';
    folding     = 1;
elseif length(varargin) < 2
    stat_type   = varargin{1};
    folding     = 1;
else
    stat_type   = varargin{1};
    folding     = varargin{2};
end

% Get unique x values
x_unique = unique(x);

if mv_av > 1
    mv_mean = nan(180,1);
    mv_std    = nan(180,1);
    mv_n      = nan(180,1);
else
    mv_mean = nan(91,1);
    mv_std    = nan(91,1);
    mv_n      = nan(91,1);
end

if any(x_unique<0)
    if folding
        y(x<0) = -y(x<0);
        mv_mean   = nan(91,1);
        mv_std    = nan(91,1);
        mv_n      = nan(91,1);
        mv_mean(ismember(0:90,unique(abs(x))))= grpstats(y,abs(x),'mean');
        mv_std(ismember(0:90,unique(abs(x)))) = grpstats(y,abs(x),'std');
        mv_n(ismember(0:90,unique(abs(x)))) = grpstats(y,abs(x),'numel');
        if strcmp(stat_type,'mean')
            mv_mean = [-mv_mean(end:-1:2); mv_mean];
        else
            mv_mean = [mv_mean(end:-1:2); mv_mean];
        end
        mv_std = [mv_std(end:-1:2); mv_std];
        mv_n(2:end) = mv_n(2:end)/2; % correct for the folding statistical boost in CI
        mv_n = [mv_n(end:-1:2); mv_n];
    else
        if ~any(x==-90) && any(x==90)
            mv_mean   = nan(180,1);
            mv_std    = nan(180,1);
            mv_n      = nan(180,1);
            mv_mean(ismember(-89:90,unique(x)))= grpstats(y,x,'mean');
            mv_std(ismember(-89:90,unique(x))) = grpstats(y,x,'std');
            mv_n(ismember(-89:90,unique(x))) = grpstats(y,x,'numel');
            if strcmp(stat_type,'mean')
                mv_mean = [-mv_mean(end); mv_mean];
            else
                mv_mean = [mv_mean(end); mv_mean];
            end
            mv_std = [mv_std(end); mv_std];
            mv_n(ismember([-89:-1 1:90],unique(abs(x)))) = mv_n(ismember([-89:-1 1:90],unique(abs(x))))/2; % correct for the folding statistical boost in CI
            mv_n = [mv_n(end); mv_n];
        else
            mv_mean(ismember(-90:90,unique(x)))= grpstats(y,x,'mean');
            mv_std(ismember(-90:90,unique(x))) = grpstats(y,x,'std');
            mv_n(ismember(-90:90,unique(x))) = grpstats(y,x,'numel');
        end

    end
    x_plot = -90:90; x_plot = x_plot(:)';
else
    mv_mean(x_unique+1) = grpstats(y,x,'mean');
    mv_std(x_unique+1) = grpstats(y,x,'std');
    mv_n(x_unique+1) = grpstats(y,x,'numel');
    x_plot = 0:length(mv_mean)-1;  x_plot = x_plot(:)';
end

mv_mean = movmean(repmat(mv_mean,rep_size,1),mv_av,'omitnan')';
mv_std = movmean(repmat(mv_std,rep_size,1),mv_av,'omitnan')';
mv_n  = movsum(repmat(mv_n,rep_size,1),mv_av,'omitnan')';

alpha = 0.05;
% Standard error of the mean
if strcmp(stat_type,'mean')
    y_plot = mv_mean;
    % Critical t-value for the confidence level
    t_crit = tinv(1 - alpha / 2, mv_n - 1);
    ci_lower = mv_mean - t_crit .* mv_std./sqrt(mv_n);
    ci_upper = mv_mean + t_crit .* mv_std./sqrt(mv_n);
else
    y_plot = mv_std;
    % Chi-squared values for CI
    chi2_upper = chi2inv(1 - alpha / 2, mv_n - 1);
    chi2_lower = chi2inv(alpha / 2, mv_n - 1);

    % Confidence intervals for standard deviation
    ci_lower = mv_std .* sqrt((mv_n - 1)  ./ chi2_upper);
    ci_upper = mv_std .* sqrt((mv_n - 1)  ./ chi2_lower);
end

if rep_size ~= 1
    y_plot   = y_plot(length(x_plot)+1:2*length(x_plot));
    % if strcmp(stat_type,'mean') & length(y_plot)>180
    %     y_plot   = y_plot-y_plot(x_plot==0);
    % end
    ci_lower = ci_lower(length(x_plot)+1:2*length(x_plot));
    ci_upper = ci_upper(length(x_plot)+1:2*length(x_plot));
end

% Plot confidence intervals as a shaded area
f = fill([x_plot fliplr(x_plot)], [ci_upper fliplr(ci_lower)], 'k', 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'FaceColor', color);
hold on;

% Plot the mean values line
p = plot(x_plot, y_plot, 'Color', color, 'LineWidth', 1.5);
xlim([x_plot(1) - 5, x_plot(end) + 5]);
% format
xticks(x_plot(1):30:x_plot(end));
set(gca, 'FontSize', 20, 'LineWidth', 2, 'FontName', 'Arial');
grid on;
box on;