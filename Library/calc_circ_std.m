% Calculate circular standard deviation = mean of [ (r_i - r_avg)^2 ]
function [circ_std_nm, normalized_circ_std] = ...
    calc_circ_std( radiiData , pixelSize_in_preExM_nm )

all_accepted_radii_nm = radiiData.radius_px_diag_adjusted ( ...
    radiiData.radius_px_diag_adjusted > 0) .* pixelSize_in_preExM_nm ;
%     circ_std_nm = mean( (all_accepted_radii_nm - mean(all_accepted_radii_nm) ) .^ 2 ) ;
circ_std_nm = std (all_accepted_radii_nm) ;

% X = mean( ((all_accepted_radii_nm - mean(all_accepted_radii_nm)) ./ mean(all_accepted_radii_nm) ) .^ 2 );

normalized_circ_std = circ_std_nm ./ (mean(all_accepted_radii_nm));
end

