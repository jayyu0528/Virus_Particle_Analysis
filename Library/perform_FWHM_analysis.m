function [L_FWHM_indices, L_FWHM, half_max_value, sub_pixel_dist_left, sub_pixel_dist_right] = perform_FWHM_analysis(L_profiles, L_max_indices, BKG)

% Currently requires input to be
% 1. not at the ends of the profile
% 2. a local maximum

% If input requirement is not met, return NaNs


L_FWHM_indices = cell(size(L_profiles));
L_FWHM_full_pixel= zeros(size(L_profiles));
L_FWHM = zeros(size(L_profiles));
half_max_value = zeros(size(L_profiles));
sub_pixel_dist_left = zeros(size(L_profiles));
sub_pixel_dist_right = zeros(size(L_profiles));

for i = 1:4
    for j = 1:2
        
        % Check input requirements
        if (L_max_indices(i,j) == 1) || (L_max_indices(i,j) == length(L_profiles{i,j}))
            error('123');
        end
        
        half_max_value(i,j) = mean([L_profiles{i,j}(L_max_indices(i,j)), BKG]);
        % seg1 includes max_index, seg2 does not (starts at max_index+1)
        seg1 = L_profiles{i,j}(1:L_max_indices(i,j));
        seg2 = L_profiles{i,j}(L_max_indices(i,j)+1:end);
        % Defined as FIRST location where value drops below 1/2 max
        L_FWHM_indices{i,j}(1) = find(seg1 < half_max_value(i,j), 1, 'last');
        L_FWHM_indices{i,j}(2) = find(seg2 < half_max_value(i,j), 1, 'first') + L_max_indices(i,j);
        % CANCELED: Defined as the number of pixels with values above 1/2 max
        % CURRENT: Defined as the number of pixels with values above 1/2
        % max, with sub-pixel precision via linear intrapolation of border
        % points
        L_FWHM_full_pixel(i,j) = L_FWHM_indices{i,j}(2) - L_FWHM_indices{i,j}(1) - 1;
        
        sub_pixel_dist_left(i,j) = 1 - inter_pixel_distance( ...
            L_profiles{i,j}(L_FWHM_indices{i,j}(1)), ...
            L_profiles{i,j}(L_FWHM_indices{i,j}(1)+1), ...
            half_max_value(i,j));
        
        sub_pixel_dist_right(i,j) = inter_pixel_distance( ...
            L_profiles{i,j}(L_FWHM_indices{i,j}(2)-1), ...
            L_profiles{i,j}(L_FWHM_indices{i,j}(2)), ...
            half_max_value(i,j));
        
        L_FWHM(i,j) = L_FWHM_full_pixel(i,j) + sub_pixel_dist_left(i,j) + sub_pixel_dist_right(i,j);
    end
end