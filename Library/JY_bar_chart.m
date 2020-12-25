function JY_bar_chart(fig_handle, x_positions, data_avg, data_std, data_range, bar_color)

figure(fig_handle);

% Bars
bar_handle = bar( x_positions , data_avg(:) , 'barwidth', 0.5 , 'facecolor', bar_color);
hold on;
x_center = get(bar_handle(1),'XData');
% x_offset = zeros(1,length(channels_to_show));
%
% for c = 1:length(channels_to_show)
%     set(bar_handle(c),'FaceColor',bar_color{c})
%     x_offset(c) = get(bar_handle(c),'XOffset');
% end


% Error Bars
ebar_tip_width = 0.06;

for s = 1:length(x_center)
    
    plot_single_error_bar(x_center(s), data_avg(data_range(s)), data_std(data_range(s)), ebar_tip_width);
    
end
