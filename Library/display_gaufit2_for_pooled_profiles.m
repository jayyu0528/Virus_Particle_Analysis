function display_gaufit2_for_pooled_profiles(gaufit2_output, x_display, BKG)

% Decided to put all into "display_profile_with_analysis_results"

% Plotting Parameters
gaufit2_color = [1 0 0]*0.8;
gaufit2_centerline_color = [1 0 0];

% Create dummy var for plotting
pre_exponent_term = gaufit2_output.normFactor * 1 / gaufit2_output.sigma / sqrt(2*pi);
y_display = pre_exponent_term * exp(-(x_display- gaufit2_output.mu).^2/(2 * gaufit2_output.sigma^2 )) + BKG;

% Display
plot(x_display,y_display,'color',gaufit2_color,'linewidth',3);
plot(ones(1,2) * gaufit2_output.mu, [0 pre_exponent_term],'color',gaufit2_centerline_color,'LineWidth',1);