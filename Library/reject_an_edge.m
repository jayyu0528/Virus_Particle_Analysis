function p_data = reject_an_edge(p_data,row,col)

if p_data.acceptance_as_radius(row,col) == 0
    error('Edge already shown as rejected.')
else 
    p_data.acceptance_as_radius(row,col) = 0;
    p_data.radius_um_postEx_diag_adjusted(row,col) = 0;
    p_data.accepted_radii_um_preEx_vector = ...
        p_data.radius_um_postEx_diag_adjusted (p_data.radius_um_postEx_diag_adjusted ~= 0) ./ p_data.exp_factor
    p_data.avg_of_accepted_radii_um_preEx = mean( p_data.accepted_radii_um_preEx_vector);
    p_data.normalized_radii_vector = ...
        p_data.accepted_radii_um_preEx_vector ./ ...
        p_data.avg_of_accepted_radii_um_preEx ;
    p_data.avg_of_normalized_radii = ...
        mean(p_data.normalized_radii_vector);
    p_data.std_of_normalized_radii = ...
        std(p_data.normalized_radii_vector);
    p_data.std_of_radii = ...
        std(p_data.accepted_radii_um_preEx_vector);
    
end