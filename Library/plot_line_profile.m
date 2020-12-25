function plot_line_profile( fig_handle, line_profile, L1_m1_ind , L1_m2_ind, lineLength_1side, pixel_size_um , profile_color)

axes(fig_handle); cla; hold on;
plot(line_profile,'color',profile_color)
plot(L1_m1_ind, line_profile(L1_m1_ind),'or');
plot(L1_m2_ind, line_profile(L1_m2_ind),'or');
dashLength = 500;
connectorHeight = mean([ line_profile(L1_m1_ind) line_profile(L1_m2_ind)]);
plot([L1_m1_ind L1_m1_ind], [line_profile(L1_m1_ind)-dashLength, line_profile(L1_m1_ind)+dashLength],'--k');
plot([L1_m2_ind L1_m2_ind], [line_profile(L1_m2_ind)-dashLength, line_profile(L1_m2_ind)+dashLength],'--k');
plot([L1_m1_ind L1_m2_ind], [connectorHeight, connectorHeight],'-k','linewidth',3);

[dia_pixel, dia_um] = calculate_diameter(L1_m1_ind,L1_m2_ind,pixel_size_um);

text(L1_m1_ind, line_profile(L1_m1_ind), num2str(L1_m1_ind), 'fontsize',20,'HorizontalAlignment','center','VerticalAlignment','bottom');
text(L1_m2_ind, line_profile(L1_m2_ind), num2str(L1_m2_ind), 'fontsize',20,'HorizontalAlignment','center','VerticalAlignment','bottom');
text(mean([L1_m1_ind L1_m2_ind]),mean([line_profile(L1_m1_ind) line_profile(L1_m2_ind)]),[num2str(dia_pixel) ' px'],'fontsize',20,'HorizontalAlignment','center','VerticalAlignment','bottom');
text(mean([L1_m1_ind L1_m2_ind]),mean([line_profile(L1_m1_ind) line_profile(L1_m2_ind)]),[num2str(dia_um,'%.3f') ' um'],'fontsize',20,'HorizontalAlignment','center','VerticalAlignment','top');

xlim([0 lineLength_1side*2 + 2])
% ylim([0 2000])


end

