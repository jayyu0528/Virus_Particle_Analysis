function [FWHM_output] = perform_FWHM_analysis_v2(L_profile, max_index, BKG, ratio_threshold)

% Requirements on the input max_index
% 1. not at the ends of the profile
% 2. a local maximum

FWHM_output.status = 'N/A';
FWHM_output.max_index = max_index;
FWHM_output.FWHM = NaN;
FWHM_output.HM = NaN;
FWHM_output.FWHM_indices = [];
FWHM_output.FWHM_borders = [];
FWHM_output.sub_pixel_dist_left = NaN;
FWHM_output.sub_pixel_dist_right = NaN;
FWHM_output.left_loc = NaN;
FWHM_output.right_loc = NaN;
FWHM_output.center_loc = NaN;

% Check input requirements; terminate here if not met
if (max_index == 1) || (max_index == length(L_profile))
        
    FWHM_output.status = 'Peak at end of profile';
    return
elseif (L_profile(max_index+1) > L_profile(max_index) && ...
        L_profile(max_index) > L_profile(max_index-1)) || ...
        (L_profile(max_index+1) < L_profile(max_index) && ...
        L_profile(max_index) < L_profile(max_index-1))
    FWHM_output.status = 'Peak is not local maximum';
    return
end

half_max_value = (L_profile(max_index) - BKG) * ratio_threshold + BKG;
% seg1 includes max_index, seg2 does not (starts at max_index+1)
seg1 = L_profile(1:max_index);
seg2 = L_profile(max_index+1:end);
% Defined as FIRST location where value drops below 1/2 max
if isempty(find(seg1 < half_max_value, 1, 'last')) || isempty(find(seg2 < half_max_value, 1, 'first'))
    FWHM_output.status = 'All values to left / right of peak are above threshold';
    return
end
FWHM_borders(1) = find(seg1 < half_max_value, 1, 'last');
FWHM_borders(2) = find(seg2 < half_max_value, 1, 'first') + max_index;


% CANCELED: Defined as the number of pixels with values above 1/2 max
% CURRENT: Defined as the number of pixels with values above 1/2
% max, with sub-pixel precision via linear intrapolation of border
% points
L_FWHM_full_pixel = FWHM_borders(2) - FWHM_borders(1) - 1;

sub_pixel_dist_left = 1 - inter_pixel_distance( ...
    L_profile(FWHM_borders(1)), ...
    L_profile(FWHM_borders(1)+1), ...
    half_max_value);

sub_pixel_dist_right = inter_pixel_distance( ...
    L_profile(FWHM_borders(2)-1), ...
    L_profile(FWHM_borders(2)), ...
    half_max_value);

L_FWHM = L_FWHM_full_pixel + sub_pixel_dist_left + sub_pixel_dist_right;

FWHM_indices = [FWHM_borders(1)+1 :FWHM_borders(2)-1];

% Format output
FWHM_output.status = 'Success';
FWHM_output.max_index = max_index;
FWHM_output.FWHM = L_FWHM;
FWHM_output.HM = half_max_value;
FWHM_output.FWHM_indices = FWHM_indices;
FWHM_output.FWHM_borders = FWHM_borders;
FWHM_output.sub_pixel_dist_left = sub_pixel_dist_left;
FWHM_output.sub_pixel_dist_right = sub_pixel_dist_right;
FWHM_output.left_loc = FWHM_borders(1) + 1 - sub_pixel_dist_left;
FWHM_output.right_loc = FWHM_borders(2) - 1 + sub_pixel_dist_right;
FWHM_output.center_loc = mean([FWHM_output.left_loc FWHM_output.right_loc]);

