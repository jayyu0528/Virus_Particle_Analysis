function display_FWHM(fig_number, L_profile, max_index, BKG, FWHM_output, fig_title)

figure(fig_number); clf; hold on;
plot(L_profile);
plot(max_index, L_profile(max_index),'or');

% HM Line
plot([FWHM_output.left_loc FWHM_output.right_loc],ones(1,2).* FWHM_output.HM);
text(mean([FWHM_output.left_loc FWHM_output.right_loc]),FWHM_output.HM,num2str(FWHM_output.FWHM),'HorizontalAlignment','center','VerticalAlignment','bottom');

% BKG Line
plot([1 length(L_profile)], ones(1,2).*BKG,'color',[1 1 1]*0.5);

% Fig Title
title(fig_title,'FontWeight','bold');