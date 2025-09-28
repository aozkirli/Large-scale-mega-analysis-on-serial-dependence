function figureS1()
%% Assessing the effectiveness of bias removals for both stimulus-specific and serial dependence biases
tbl = readtable(['..' filesep 'results' filesep 'SD_ma_master_table.csv']);
FontName = 'Arial';
%% Figure S1: Stimulus-specific bias and serial dependence bias cleaning checks
% Check how cleaning went:
figure('Units','normalized','position',[.05 .4 .6 .4]);
tmp = tbl(abs(tbl.delta)<=90 & tbl.theta<=180,:);

% Orientation bias removal
rep_size = 3;
bin_size = 21;

subplot(121)
p0 = plot_mean_ci(tmp.theta,tmp.error_norm,rep_size,bin_size,'k','mean');
hold on;
p1 = plot_mean_ci(tmp.theta,tmp.error_iqr_norm,rep_size,bin_size,'r','mean');
p2 = plot_mean_ci(tmp.theta,tmp.error_ori_deb_norm,rep_size,bin_size,'b','mean');
p3 = plot_mean_ci(tmp.theta,tmp.error_ori_deb_sd_deb_norm,rep_size,bin_size,'g','mean');
ylim([-.5 .5])
xticks(0:45:180)
xlabel('θ(°)')
ylabel('Stimulus-specific bias (a.u.)')
set(gca, 'FontSize', 20, 'LineWidth', 2, 'FontName', FontName);
pos = get(gca, 'Position');
annotation('textbox', [pos(1)-0.08, pos(2)+0.01 + pos(4), 0.05, 0.05], ...
    'String', 'A)', 'HorizontalAlignment', 'center', ...
    'FontName', FontName, 'FontSize', 22, 'EdgeColor', 'none', 'Units', 'normalized');

subplot(122)
p0 = plot_mean_ci(tmp.delta,tmp.error_norm,rep_size,bin_size,'k','mean');
hold on;
p1 = plot_mean_ci(tmp.delta,tmp.error_iqr_norm,rep_size,bin_size,'r','mean');
p2 = plot_mean_ci(tmp.delta,tmp.error_ori_deb_norm,rep_size,bin_size,'b','mean');
p3 = plot_mean_ci(tmp.delta,tmp.error_ori_deb_sd_deb_norm,rep_size,bin_size,'g','mean');
ylim([-.5 .5])
xticks(-90:45:90)
xlabel('Δ (°)')
ylabel('Serial dependence bias (a.u.)')
set(gca, 'FontSize', 20, 'LineWidth', 2, 'FontName', FontName);
legend([p0 p1 p2 p3],{'raw data' 'outliers removed' 'stimulus bias removed' 'serial dependence bias removed'}, 'Location', 'best')
pos = get(gca, 'Position');
annotation('textbox', [pos(1)-0.08, pos(2)+0.01  + pos(4), 0.05, 0.05], ...
    'String', 'B)', 'HorizontalAlignment', 'center', ...
    'FontName', FontName, 'FontSize', 22, 'EdgeColor', 'none', 'Units', 'normalized');

set(gcf,'PaperOrientation','landscape')
set(gcf, 'PaperUnits', 'normalized');
exportgraphics(gcf,['..' filesep 'results' filesep 'figures' filesep 'SI_removalChecks.pdf'],'BackgroundColor','none')
savefig(gcf,['..' filesep 'results' filesep 'figures' filesep 'SI_removalChecks.fig'])

end
