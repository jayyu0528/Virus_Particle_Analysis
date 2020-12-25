function display_profile_with_analysis_results ...
    (panel_index, L_profile, selected_peak_index, BKG, ...
    FWHM_output, is_display_FWHM, ...
    gaufit2_output, is_display_gaufit2,...
    profile_line_color, profile_index)

%% Basics (no analysis results)

h = subplot(4,3,panel_index);cla;hold on;
% Display profile
plot(L_profile,'color',profile_line_color);
% Display currently selected peak
plot(selected_peak_index,L_profile(selected_peak_index),'color', profile_line_color,'marker','o')

%% FWHM Outputs
if is_display_FWHM
    
    % Plotting Parameters
    max_min_LineWidth = 5;
    max_min_line_color = [1 1 1] * 0.5;
    FWHM_centerline_color = [0 0 1];
    
    % Calculations
    profile_selected_max = L_profile(selected_peak_index);
    HM_line_height = 0.1 * (profile_selected_max - BKG);
    
    % half max line (HM line)
    plot([FWHM_output.left_loc FWHM_output.right_loc], ones(1,2) * FWHM_output.HM,'color','k');
    text(FWHM_output.center_loc, FWHM_output.HM, num2str(FWHM_output.FWHM),'HorizontalAlignment','center','VerticalAlignment','top')
    plot(ones(1,2)* FWHM_output.left_loc, ...
        [FWHM_output.HM - HM_line_height , FWHM_output.HM + HM_line_height],'k')
    plot(ones(1,2)* FWHM_output.right_loc, ...
        [FWHM_output.HM - HM_line_height , FWHM_output.HM + HM_line_height],'k')
    % FWHM-based centerline
    plot(ones(1,2)* FWHM_output.center_loc, ...
        [0 profile_selected_max],'color',FWHM_centerline_color);
    % max and min lines
    plot([FWHM_output.center_loc - max_min_LineWidth , FWHM_output.center_loc + max_min_LineWidth] , ...
        ones(1,2) * profile_selected_max, 'color', max_min_line_color,'linestyle','--');
    plot([FWHM_output.center_loc - max_min_LineWidth , FWHM_output.center_loc + max_min_LineWidth] , ...
        ones(1,2) * BKG, 'color', max_min_line_color, 'linestyle', '--')
    % counting indexes
    plot(FWHM_output.FWHM_indices,L_profile(FWHM_output.FWHM_indices),'color', profile_line_color,'marker','*');
end

%% gaufit2 Outputs

if is_display_gaufit2
    display_gaufit2(gaufit2_output, 1:0.2:length(L_profile), BKG, panel_index)
end

%% Profile Index
ylim = get(h,'YLim');
text(0,ylim(2),[' ' num2str(profile_index)],'FontSize',16,'HorizontalAlignment','left','VerticalAlignment','top');

