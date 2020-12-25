% Calculate sphericity = r_min / r_max, out of all accepted edges
function sphericity = calc_sphericity( radiiData )
    all_accepted_radii_px = radiiData.radius_px_diag_adjusted ( ...
        radiiData.radius_px_diag_adjusted > 0);
    sphericity = min(all_accepted_radii_px) ./ max(all_accepted_radii_px);
end

