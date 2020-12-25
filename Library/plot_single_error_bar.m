function plot_single_error_bar(x_center, mean_value, error_value, tip_width)

ebar_color = [0 0 0];

% vertical line
plot( [x_center, x_center], ...
    [mean_value, mean_value + error_value],'color',ebar_color);

% horizontal tip
plot( [x_center - tip_width, x_center + tip_width], ...
    [mean_value + error_value, mean_value + error_value],'color',ebar_color);