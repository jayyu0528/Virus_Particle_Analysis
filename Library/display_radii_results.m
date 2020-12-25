function display_radii_results(All_radii, ROI_radii_AVG, ROI_radii_STD)

%% Outputs
clc;
ROI_radii_AVG{:};
ROI_radii_STD{:};
All_radii_AVG = cellfun(@mean,All_radii)
All_radii_STD = cellfun(@std,All_radii)

[p_val_STD_comparison,~] = ranksum(ROI_radii_STD{1}, ROI_radii_STD{2})
[p_val_AVG_comparison,~] = ranksum(ROI_radii_AVG{1}, ROI_radii_AVG{2})

% p_val_AVG_comparison should return 1.0000 because 
% both inputs are one(6,1), by design
% However, due to small errors (e.g. 1.0000000000000001421),
% there are differences in the ones, causing p < 1.0000

%% Bar plots
bar_color = [1 1 1].*0.5;
x_shift = 0.1;

% Pool all; compare radii value
h(1) = figure(1); clf;
JY_bar_chart(h(1), [1 2], All_radii_AVG, All_radii_STD, [1 2], bar_color)
for s = 1:2
    plot(ones(1,length(All_radii{s})).*s + x_shift , All_radii{s},'Marker','.','Color',[0 0 0],'LineStyle','none','MarkerSize',2) 
end
% ylim([0 1.2])
title(sprintf('Particle-size-normalized radii'))
set(gca,'XTickLabel',{'PAA','TG'})

% Compare ROI AVGs
h(2) = figure(2); clf;
JY_bar_chart(h(2), [1 2], cellfun(@mean,ROI_radii_AVG), cellfun(@std,ROI_radii_AVG), [1 2], bar_color)
for s = 1:2
    plot(ones(1,length(ROI_radii_AVG{s})).*s + x_shift , ROI_radii_AVG{s},'Marker','.','Color',[0 0 0],'LineStyle','none','MarkerSize',2) 
end
% ylim([0 0.8])
title(sprintf('ROI-wide Average of \nParticle-size-normalized radii'))
set(gca,'XTickLabel',{'PAA','TG'})

% Compare ROI STDs
h(3) = figure(3); clf;
JY_bar_chart(h(3), [1 2], cellfun(@mean,ROI_radii_STD), cellfun(@std,ROI_radii_STD), [1 2], bar_color)
for s = 1:2
    plot(ones(1,length(ROI_radii_STD{s})).*s + x_shift , ROI_radii_STD{s},'Marker','.','Color',[0 0 0],'LineStyle','none','MarkerSize',2) 
end
% ylim([0 0.12])
title(sprintf('ROI-wide Std Dev. of \nParticle-size-normalized radii'))
set(gca,'XTickLabel',{'PAA','TG'})
