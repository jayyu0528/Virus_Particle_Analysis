function display_gaufit2_on_pooled_profiles(fig_handle, x_pooled, y_pooled, pooled_profile_gaufit2_output, subplot_dim, panel_index, title_txt, if_wait_for_key)

BKG_particle = 0; % All the y_pooled_over_ROI should have been BKG-subtracted

% % Perform analysis
% ROI_profile_gaufit2_output = perform_gaufit2_analysis(x_pooled_over_ROI, y_pooled_over_ROI, BKG_particle, 0, 0, 0);

% Display
figure(fig_handle); 
subplot(subplot_dim(1),subplot_dim(2),panel_index);
cla;hold on;
plot(x_pooled,y_pooled,'*b')
x_display = linspace(min(x_pooled), max(x_pooled), 500);
display_gaufit2_for_pooled_profiles(pooled_profile_gaufit2_output, x_display, BKG_particle)
title(title_txt);
if strcmp(pooled_profile_gaufit2_output.status,'Failure')
    title(sprintf('Gaussian Fit algorithm failure: Matrix is singlular.\nReturn to fix single-profile peaks or acceptances, or reject this measurement.'),'FontSize',14 * global_font_size_modifier);
end


% Interative (Just any-key confirm)

if if_wait_for_key
    xlabel('Press any key to continue','FontSize',20)
    btn = detect_button_press();
end

% update_panel_title_II(fig_handle,[1,4],sprintf('Up: Back | R: Reject | Space: Accept'),20,[0 0 0])
% while 1
%     btn = detect_button_press();
%     switch strcmp(ROI_profile_gaufit2_output.status,'Failure')
%         case 0
%             if ismember(btn, [30 114 32])
%                 break;
%             end
%         case 1 % in case gaufit2 fails, cannot hit accept
%             if ismember(btn, [30 114])
%                 break;
%             end
%     end
% end
%
% switch btn
%     case 30 % up key - go back to single profile analysis
%         acceptance_p_avg_gau = -1;
%     case 114 % R key - reject particle-averaged peak
%         acceptance_p_avg_gau = 0;
%     case 32 % space key - accept particle-averaged peak
%         acceptance_p_avg_gau = 1;
% end