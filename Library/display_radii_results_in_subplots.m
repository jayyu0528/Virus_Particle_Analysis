function display_radii_results_in_subplots(All_radii, ROI_radii_AVG, ROI_radii_STD, subplot_format, subplot_indices, row_label)

%% Outputs
clc;
ROI_radii_AVG{:}
ROI_radii_STD{:}
All_radii_AVG = cellfun(@mean,All_radii)
All_radii_STD = cellfun(@std,All_radii)

[p_All_radii,~] = ranksum(All_radii{1}, All_radii{2})
[p_ROI_radii_AVG,~] = ranksum(ROI_radii_AVG{1}, ROI_radii_AVG{2})
[p_ROI_radii_STD,~] = ranksum(ROI_radii_STD{1}, ROI_radii_STD{2})

%% Bar plots
bar_color = [1 1 1].*0.5;
x_shift = 0.1

num_spec = '%.4f';

% Pool all; compare radii value
h(1) = subplot(subplot_format(1), subplot_format(2), subplot_indices(1)); cla;


JY_bar_chart_subplots(h, [1 2], All_radii_AVG, All_radii_STD, [1 2], bar_color)
for s = 1:2
    plot(ones(1,length(All_radii{s})).*s + x_shift , All_radii{s},'Marker','.','Color',[0 0 0],'LineStyle','none','MarkerSize',2) 
end
ylim([-0.5 3])
title(sprintf('All (pooled from all ROI)\nParticle-size-normalized radii'))
set(gca,'XTickLabel',{'PAA','TG'})

ylabel(row_label,'FontWeight','bold','FontSize',12);

XL = get(gca,'XLim');
YL = get(gca,'YLim');
text(mean(XL),max(YL),['p = ' num2str(p_All_radii,num_spec)],'HorizontalAlignment','center','VerticalAlignment','top','fontsize',12,'fontweight','bold');

% Compare ROI AVGs
h(2) = subplot(subplot_format(1), subplot_format(2), subplot_indices(2)); cla;
JY_bar_chart_subplots(h(2), [1 2], cellfun(@mean,ROI_radii_AVG), cellfun(@std,ROI_radii_AVG), [1 2], bar_color)
for s = 1:2
    plot(ones(1,length(ROI_radii_AVG{s})).*s + x_shift , ROI_radii_AVG{s},'Marker','.','Color',[0 0 0],'LineStyle','none','MarkerSize',2) 
end
 ylim([0 1.2])
title(sprintf('ROI-wide Average of \nParticle-size-normalized radii'))
set(gca,'XTickLabel',{'PAA','TG'})

XL = get(gca,'XLim');
YL = get(gca,'YLim');
text(mean(XL),max(YL),['p = ' num2str(p_ROI_radii_AVG,num_spec)],'HorizontalAlignment','center','VerticalAlignment','top','fontsize',12,'fontweight','bold');


% Compare ROI STDs
h(3) = subplot(subplot_format(1), subplot_format(2), subplot_indices(3)); cla;
JY_bar_chart_subplots(h(3), [1 2], cellfun(@mean,ROI_radii_STD), cellfun(@std,ROI_radii_STD), [1 2], bar_color)
for s = 1:2
    plot(ones(1,length(ROI_radii_STD{s})).*s + x_shift , ROI_radii_STD{s},'Marker','.','Color',[0 0 0],'LineStyle','none','MarkerSize',2) 
end
ylim([0 0.3])
title(sprintf('ROI-wide Std Dev. of \nParticle-size-normalized radii'))
set(gca,'XTickLabel',{'PAA','TG'})

XL = get(gca,'XLim');
YL = get(gca,'YLim');
text(mean(XL),max(YL),['p = ' num2str(p_ROI_radii_STD,num_spec)],'HorizontalAlignment','center','VerticalAlignment','top','fontsize',12,'fontweight','bold');

