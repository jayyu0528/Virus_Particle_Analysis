function [acceptance_p_avg_gau, p_avg_gaufit2_output] = perform_particle_average_profile_analysis(fig_handle, acceptance_peaks, L_profiles, FWHM_outputs, BKG_particle)

global global_font_size_modifier;

avg_panel_index = [5 6 8 9];

% Collect accepted profiles from particle
peaks_accepted = find(acceptance_peaks')';

if isempty(peaks_accepted)
    acceptance_p_avg_gau = 0;
    p_avg_gaufit2_output.status = 'No input, due to no accepted single line profile.';
    p_avg_gaufit2_output.sigma = NaN;
    p_avg_gaufit2_output.mu = NaN;
    p_avg_gaufit2_output.normFactor = NaN;
    return
end

x_pooled = [];
y_pooled = [];

% ========== 2018/09/02 Review Note ==========
% At this time point, analysis has been performed on most workSpace1
% However, 2 design flaws noticed
% (1) Particle-wide profiles were aligned by FWHM center, not gaufit2, of
% the accepted profiles -- Affects results, since the center of multi-peaks
% are not well captured by FWHM center
% (2) There were no checking mechanism for lack of FWHM center (when FWHM
% failed); and whenever a lack occurs, NaNs are inserted into the x_pooled
% variable, causing gaufit_2 singularity (seems to be 100% causation rate)

for l = peaks_accepted
    [j, i] = ind2sub([2 4], l);
    
    x_profile_centered_at_zero = ( 1 : length(L_profiles{i,j}) ) - FWHM_outputs(i,j).center_loc;
    
    % For diagonal profiles, scale x
    if ismember(i,[2 4])
        x_profile_centered_at_zero = x_profile_centered_at_zero .* sqrt(2);
    end
    
    x_pooled = [x_pooled x_profile_centered_at_zero];
    y_pooled = [y_pooled , L_profiles{i,j}];
end

% Perform analysis
p_avg_gaufit2_output = perform_gaufit2_analysis(x_pooled, y_pooled, BKG_particle, 1, 0, 0);

% Display
figure(fig_handle); subplot(4,3,avg_panel_index); hold on;
plot(x_pooled,y_pooled,'*k')
x_display = -15 : 0.1 : 15;
display_gaufit2(p_avg_gaufit2_output, x_display, BKG_particle, avg_panel_index)
if strcmp(p_avg_gaufit2_output.status,'Failure')
    title(sprintf('Gaussian Fit algorithm failure: Matrix is singlular.\nReturn to fix single-profile peaks or acceptances, or reject this measurement.'),'FontSize',14 * global_font_size_modifier);
end

% Interative
update_panel_title_II(fig_handle,[1,4],sprintf('Up: Back | R: Reject | Space: Accept'),20,[0 0 0])
while 1
    btn = detect_button_press();
    switch strcmp(p_avg_gaufit2_output.status,'Failure')
        case 0
            if ismember(btn, [30 114 32])
                break;
            end
        case 1 % in case gaufit2 fails, cannot hit accept
            if ismember(btn, [30 114])
                break;
            end
    end
end

switch btn
    case 30 % up key - go back to single profile analysis
        acceptance_p_avg_gau = -1;
    case 114 % R key - reject particle-averaged peak
        acceptance_p_avg_gau = 0;
    case 32 % space key - accept particle-averaged peak
        acceptance_p_avg_gau = 1;
end