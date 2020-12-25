function [sigma, mu, A] = gaufit_by_gau_equation (x0, y0, BKG_threshold)

% Gaussian Fit 1 - minimizing log residuals

% subtract_bkg = 0
% flatten_negative_to_zero = 0
% baseline = bkg_full_z;
% 
% if subtract_bkg
%     y0 = L_profiles{i,j} - baseline;
%     if flatten_negative_to_zero
%         y0(y0 < 0) = 0;
%     end
% else
%     y0 = L_profiles{i,j};
% end

[sigma, mu, A]=mygaussfit(x0,y0, BKG_threshold); % internal subtraction of 20% of max
