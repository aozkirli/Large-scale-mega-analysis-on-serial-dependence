function figureS6()
%% Model-free control analysis for weighted flexible-degree polynomial fits
load(['..' filesep 'results' filesep 'sd_estimates.mat'],'tbl_scatter')
FontName = 'Arial';
%% Visualization of results
figure('Units','normalized','position',[.05 .4 .9 .4]);
titles = {'iso', 'mid', 'ortho'};
for i = 1:3
    subplot(1, 3, i);
    poly = tbl_scatter.ES(i:3:end);
    binned = tbl_scatter.bin_scatter(i:3:end);
    idx = ~isnan(poly) & ~isnan(binned);
    [rr, pp] = corr(binned(idx), poly(idx));
    scatter(binned(idx), poly(idx), 'filled','ko');
    hold on;
    l1 = lsline;
    l1.Color = 'r';
    l1.LineWidth = 3;
    xlabel('Binned scatter estimate (°)');
    ylabel('Polynomial scatter estimate (°)');
    title([titles{i}]);
    legend(l1,['r=' num2str(round(rr,2)) repmat('*', 1, (pp < 0.001) * 3 + (pp >= 0.001 & pp < 0.01) * 2 + (pp >= 0.01 & pp < 0.05) * 1)],'Location','southeast')
    set(gca, 'FontSize', 24);
    set(gca,'LineWidth',2)
    set(gca,'FontName',FontName)
    grid on;
    box on; 
end
set(gcf,'PaperOrientation','landscape')
set(gcf, 'PaperUnits', 'normalized');
exportgraphics(gcf,['..' filesep 'results' filesep 'figures' filesep 'SI_polyBinCorrelations.pdf'],'BackgroundColor','none')
savefig(gcf,['..' filesep 'results' filesep 'figures' filesep 'SI_polyBinCorrelations.fig'])

end