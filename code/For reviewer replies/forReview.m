%% Reviewer #2: Simulation of bias removal effects in iso vs. ortho
clear; clc; close all;
m = 2000000;
n = 180;

scat = 9;
iA = 3;
oA = 5;

yl = 9;
meanIO = (iA+oA)*.5;
iso = iA*sind(1:4:4*n) + scat*randn(m,n);
ortho = oA*sind(1:4:4*n) + scat*randn(m,n);

figure
subplot(121)
plot(.5*mean(iso+ortho,'omitnan'),'k','LineWidth',2)
hold on
plot(mean(iso,'omitnan'),'r')
plot(mean(ortho,'omitnan'),'g')
legend({['all: ' num2str(std([iso(:); ortho(:)]))] ['iso:' num2str(std(iso(:)))] ['ortho:' num2str(std(ortho(:)))]})
title({'Before removal with' ['simulated scatter = ' num2str(scat)]})
ylim([-yl yl])
xticks(0:45:180)
xlabel('Theta')
ylabel('Simulated error')
set(gca,'FontName','Arial','FontSize',14)

subplot(122)
iso = iso-meanIO*sind(1:4:4*n);
ortho = ortho-meanIO*sind(1:4:4*n);
plot(.5*mean(iso+ortho,'omitnan'),'k','LineWidth',2)
hold on
plot(mean(iso,'omitnan'),'r')
plot(mean(ortho,'omitnan'),'g')
legend({['all: ' num2str(std([iso(:); ortho(:)]))] ['iso:' num2str(std(iso(:)))] ['ortho:' num2str(std(ortho(:)))]})
ylim([-yl yl])
title({'After removal with' ['simulated scatter = ' num2str(scat)]})
xticks(0:45:180)
xlabel('Theta')
ylabel('Simulated error')
set(gca,'FontName','Arial','FontSize',14)

%% Reviewer #3: Scatter as a function of cued vs. uncued delta

clear; clc; close all;
baseline    = 9;
x           = -90:5:90;
a           = normpdf(x,-45,20) + normpdf(x,45,20);
a           = a./max(a(:)); 
ntrials     = 500000;
delta1      = datasample(x,ntrials)';
delta2      = datasample(x,ntrials)';
errors      = nan(numel(delta1),1);
for j = 1:numel(delta1)
    % modulatory effect on scatter (interference), only as a function of
    % cued delta
    [v,idx]         = find(x==delta2(j));
    a_component     = a(idx);
    errors(j)       =  (baseline + a_component)*randn(1,1); 
end
stat1   = grpstats(errors',delta1,'std'); % uncued
stat2   = grpstats(errors',delta2,'std'); % cued

figure;
plot(x,baseline.*ones(size(x)),'k--','LineWidth',2.5);hold on;
plot(x,baseline+a,'r--','LineWidth',2.5);
plot(x,stat2,'r','LineWidth',1.5);
plot(x,stat1,'b','LineWidth',1.5);
ylim([8.25 10.75])
xticks(-90:45:90)
xlabel('\Delta (°)');
ylabel('Error Scatter (°)');
legend('Simulated baseline','Simulated Cued modulation','Cued estimate','Uncued estimate');
set(gca,'FontName','Arial','FontSize',16)
set(gcf,'color','w');
title('Simulation of error scatter in post-cue paradimgs');

%% Reviewer #3: Response time moving average

clear; clc; close all;
tbl = readtable(['..' filesep 'results' filesep 'SD_ma_master_table.csv']);
tbl(tbl.rt >=3.5 | tbl.rt<.5 | abs(tbl.error) > 30,:)=[];

tbl.absdelta = abs(tbl.delta);
tbl(tbl.absdelta>90 | isnan(tbl.absdelta),:)=[];

datasets = unique(tbl.codenum);
rt_mvav_dataset = nan(length(datasets),91);
for c = 1:length(datasets)
    obs = unique(tbl(tbl.codenum==c,:).obs);
    rt_mvav = nan(length(obs),91);
    for o = 1:length(obs)
        tmp = tbl(tbl.codenum==c & tbl.obs == obs(o),:);
        rt_mvav(o,groupsummary(tmp,{'absdelta'},'mean','rt').absdelta+1) = zscore(groupsummary(tmp,{'absdelta'},'mean','rt').mean_rt);
        rt_mvav(o,:) = movmean(rt_mvav(o,:),21,'omitmissing');
    end
    rt_mvav_dataset(c,:) = mean(rt_mvav,'omitnan');
end

x = 0:90;
mean_rt = mean(rt_mvav_dataset,'omitnan');
stderr_rt = std(rt_mvav_dataset,'omitnan') / sqrt(length(datasets));

% Create upper and lower bounds
upper = mean_rt + stderr_rt;
lower = mean_rt - stderr_rt;

% Plot the shaded error region
fill([x fliplr(x)], [upper fliplr(lower)], [0.8 0.8 0.8], 'EdgeColor', 'none'); % light gray shade
hold on;

% Plot the mean line
plot(x, mean_rt, 'k', 'LineWidth', 2);

xlabel('Absolute delta (deg)');
ylabel('Z-scored adjustment-time running average');
set(gca,'FontName','Arial','FontSize',14)
title('Response time vs. delta')

