% Calculate circular variance = mean of [ (r_i - r_avg)^2 ]
function [circ_variance_nm2, normalized_circ_variance] = ...
    calc_circ_variance( radiiData , pixelSize_in_preExM_nm )

    all_accepted_radii_nm = radiiData.radius_px_diag_adjusted ( ...
        radiiData.radius_px_diag_adjusted > 0) .* pixelSize_in_preExM_nm ;
    circ_variance_nm2 = mean( (all_accepted_radii_nm - mean(all_accepted_radii_nm) ) .^ 2 ) ;
    
    X = mean( ((all_accepted_radii_nm - mean(all_accepted_radii_nm)) ./ mean(all_accepted_radii_nm) ) .^ 2 );
    
    normalized_circ_variance = circ_variance_nm2 ./ (mean(all_accepted_radii_nm).^2);
end


