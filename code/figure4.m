function figure4()
%% Figure 4: bin comparison with boxplots (all datasets) 
tbl = readtable(['..' filesep 'results' filesep 'SD_ma_master_table.csv']);
load(['..' filesep 'results' filesep 'sd_estimates.mat'],'tbl_scatter')
FontName        = 'Arial';
datasets        = unique(tbl.code);
row_spacing     = 18;
x_spacing       = 1:row_spacing:row_spacing*max(tbl.codenum);
colors          = linspecer(max(tbl.codenum));%
% main figure options
optfg           = [];
optfg.dotshift  = 8;
optfg.dotssize  = 8;
optfg.jitfactor = .5;
optfg.showdots  = true;
optfg.boxshift  = 0.05;
optfg.rescaling = 18;
optfg.connline  = false;
optfg.facecolor = 'sameas_noalpha';
optfg.viorefine = false;
optfg.ksdensamp = 10;

addpath('model')
Sd          = 9;    % sigma (witdh) of decoding transition distribution, fixed
Pt          = 0.5;  % probability of integration
tau         = 1;    % temporal decay parameter, fixed
nback       = 1;
meas        = 0;
theta       = datasample(0:179,10000)';
opt_scat   = @(delta,sigma) sqrt(1./(2+(delta/sigma).^2).^2.*sigma.^2+(1-1./(2+(delta/sigma).^2)).^2.*sigma^2);
for i = 1:max(tbl_scatter.codenum)
    tmp = tbl_scatter(tbl_scatter.codenum==i,:);
    simulationScat = mean(tmp.ES);
    model = SD_ma_model_bayesian(simulationScat,Sd,Pt,tau,theta,nback,meas);
    optIntSig = opt_scat(model.delta,simulationScat);
    for k = 1:3
        bayes(i,k) = mean(model.sigma(ismember(abs(model.delta),45*(k-1))));
        optInt(i,k) = mean(optIntSig(ismember(abs(model.delta),45*(k-1))));
    end
end

figure('Units','normalized','position',[0 0 .7 1]);
tiledlayout(1,3,'TileSpacing','none','Padding','tight')
compnames       = {'\bf Iso vs Mid','\bf Iso vs Ortho','\bf Ortho vs Mid'};
compindex       = [1 2; 1 3; 3 2];
medcomp_all     = cell(3,1);
n_datasets      = max(tbl_scatter.codenum);

for k = 1:3
    nexttile
    % collect all medians
    medcomp         = nan(max(tbl_scatter.codenum),1);
    effs            = medcomp;
    for i = 1:n_datasets
        tmp = tbl_scatter(tbl_scatter.codenum==i,:);
        scatter_bin = {tmp.ES(tmp.SI == 'iso')  tmp.ES(tmp.SI == 'mid')  tmp.ES(tmp.SI == 'ortho')};
        comparison  = scatter_bin{compindex(k,1)} - scatter_bin{compindex(k,2)};
        compBayes(i)  = bayes(i,compindex(k,1))-bayes(i,compindex(k,2));
        compOptInt(i)  = optInt(i,compindex(k,1))-optInt(i,compindex(k,2));
        hedgesg     = computeHedges_g(scatter_bin{compindex(k,1)},scatter_bin{compindex(k,2)});
        optfg.x     = x_spacing(i);
        optfg.color = colors(i,:);
        plot_violin(comparison,optfg);
        hold on
        medcomp(i)  = median(comparison,'omitnan');
        effs(i)     = hedgesg;
        % add the effect size (Hedge's g)
        if abs(hedgesg)>=.2
            scatter(optfg.x,median(comparison),abs(hedgesg)*50,'markerfacecolor',optfg.color,'markeredgecolor',[.2 .2 .2],'LineWidth',1);
            % small effect size criterion as reference
            scatter(optfg.x,median(comparison),.2*50,'markerfacecolor',[1 1 1],'markeredgecolor',[1 1 1],'LineWidth',1);
        else
            % smaller than the effect size criterion of reference
            scatter(optfg.x,median(comparison),.2*50,'markerfacecolor',[1 1 1],'markeredgecolor',[1 1 1],'LineWidth',1);
        end
        set(gca, 'FontSize', 14, 'LineWidth', 2, 'FontName', FontName,'TickLength', [0.005 0.005]); % Removes both major ticks

    end
    [~,pp,~,stats] = ttest(medcomp,0);
    disp(['Medians for ' compnames{k}(4:end) ': t(' num2str(round(stats.df,2)) ')=' num2str(round(stats.tstat,2)) ', p=' num2str(round(pp,3))])
    optfg.x         = x_spacing(i)+40;
    optfg.color     = [0.01 0.44 0.65];
    optfg.ksdensamp = 15;
    % then add the median statistic
    plot_violin(compBayes',optfg);
    hold on
    % add the median effect size (Hedge's g)
    scatter(optfg.x,median(compBayes),abs(computeHedges_g(compBayes,zeros(size(compBayes)))*50),'markerfacecolor',optfg.color,'markeredgecolor',[.2 .2 .2],'LineWidth',1);
    % small effect size criterion as reference
    scatter(optfg.x,median(compBayes),.2*50,'markerfacecolor',[1 1 1],'markeredgecolor',[1 1 1]);
    
    optfg.x         = x_spacing(i)+60;
    optfg.color     = '#74A9CF';
    optfg.ksdensamp = 15;
    % then add the median statistic
    plot_violin(compOptInt',optfg);
    hold on
    % add the median effect size (Hedge's g)
    scatter(optfg.x,median(compOptInt),abs(computeHedges_g(compOptInt,zeros(size(compOptInt)))*50),'markerfacecolor',optfg.color,'markeredgecolor',[.2 .2 .2],'LineWidth',1);
    % small effect size criterion as reference
    scatter(optfg.x,median(compOptInt),.2*50,'markerfacecolor',[1 1 1],'markeredgecolor',[1 1 1]);
    
    optfg.x         = x_spacing(i)+80;
    optfg.color     = [0.5 0.5 0.5];
    optfg.ksdensamp = 15;
    % then add the median statistic
    plot_violin(medcomp,optfg)
    hold on
    % add the median effect size (Hedge's g)
    scatter(optfg.x,median(medcomp),abs(median(effs)*50),'markerfacecolor',optfg.color,'markeredgecolor',[.2 .2 .2],'LineWidth',1);
    % small effect size criterion as reference
    scatter(optfg.x,median(medcomp),.2*50,'markerfacecolor',[1 1 1],'markeredgecolor',[1 1 1]);
    medcomp_all{k} = medcomp; 

    % aestetichs
    box on;
    % grid on;
    view([90 -90])
    set(gca,'ytick',-8:4:8)
    ylim([-15 15])
    if k==1
        datname                   = strrep(datasets,'_',' ');
        datname{n_datasets+1}     = '\bf Bayesian Model Prediction';
        datname{n_datasets+2}     = '\bf Optimal Integration Prediction';
        datname{n_datasets+3}     = '\bf Median (Data)';
        set(gca,'xtick',[x_spacing x_spacing(end)+(40:20:80)],'xticklabel',datname,'XDir','reverse','XGrid','on')
    else
        set(gca,'xtick',[x_spacing x_spacing(end)+(40:20:80)],'xticklabel','','XDir','reverse','XGrid','on')
    end
    hline(0,'k--');
    xlim([-20 x_spacing(end)+95]);
    % box on
    tl                        = title(compnames{k});     tl.FontSize = 16; 
end
set(gcf,'PaperOrientation','landscape')
set(gcf, 'PaperUnits', 'normalized');
exportgraphics(gcf, ['..' filesep 'results' filesep 'figures' filesep 'main_comparisons.pdf'], 'BackgroundColor', 'none', 'ContentType', 'vector');
savefig(gcf,['..' filesep 'results' filesep 'figures' filesep 'main_comparisons.fig'])
end