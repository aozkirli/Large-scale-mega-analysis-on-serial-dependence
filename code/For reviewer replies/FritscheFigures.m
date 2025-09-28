tbl = readtable(['..' filesep '..' filesep 'results' filesep 'SD_ma_master_table.csv']);
tbl=tbl(contains(tbl.study,'Fritsche et'),:);
colors = {'k','b'};
err_type = {'errorsd','error_ori_deb'};
for i = 1:3
    exp = tbl(contains(tbl.experiment,num2str(i)),:);
    participants = unique(exp.obs);
    for cleaning = 1:2
        moving_averages_all=nan(length(participants),181);
        for p = 1:length(participants)
            participant = exp(exp.obs==participants(p),:);

            x = participant.delta;
            y = participant.(err_type{cleaning});
            idx = isfinite(x) & isfinite(y);
            x=x(idx);y=y(idx);

            x_padded = [x - 180; x; x + 180];
            y_padded = [y; y; y];

            moving_average = nan(1,181);

            for b = 0:180
                moving_average(b+1) = ...
                    circ_rad2ang(circ_std(circ_ang2rad(y_padded(inrange(x_padded, [1, 30] - floor(30/2) - 1 - 90 + b)))));

            end

            clear x; clear y; clear x_padded; clear y_padded;

            moving_averages_all(p,:) = ...
                moving_average - ...
                mean(moving_average);
        end

        subplot(1,3,i)
        plot([-90 90], [0 0],'Color',[.3 .3 .3]);hold on;
        plot([0 0], [-2 2],'Color',[.3 .3 .3]);hold on;
        sem = std(moving_averages_all)/sqrt(size(moving_averages_all,1));
        % Plot confidence intervals as a shaded area
        f = fill([-90:90 fliplr(-90:90)], [mean(moving_averages_all)+sem fliplr(mean(moving_averages_all)-sem)], colors{cleaning}, 'FaceAlpha', 0.2, 'EdgeColor', 'none', 'FaceColor', colors{cleaning});
        plot(-90:90,mean(moving_averages_all),colors{cleaning},'LineWidth',1.5);
        title(['Experiment ' num2str(i)])
        ylabel('Normalized response SD (deg)')
        xticks(-80:40:80)
        xlim([-90 90])
        xlabel({'Relative orientation of' '1-back trial (deg)'})
        set(gca,'FontSize',16)
        if i ==1
            ylim([-1.5 1])
            yticks(-1:1:1)
        else
            ylim([-1 .75])
            yticks(-1:.5:.5)
        end
    end
end

