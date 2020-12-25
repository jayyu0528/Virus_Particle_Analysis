function re_render_single_profile_results(fig_handle, sinlge_profile_panel_layout, L_profiles, peak_indices, BKG_particle, FWQM_outputs, gaufit2_outputs, single_profile_colors, acceptance_peaks, acceptance_single_p_gau)

for l = 1:8
    [j, i] = ind2sub([2 4], l);
    display_profile_with_analysis_results(sinlge_profile_panel_layout(i,j), L_profiles{i,j}, peak_indices(i,j), BKG_particle, FWQM_outputs(i,j), 1, gaufit2_outputs(i,j), 1, single_profile_colors{i,j}, l);
    
    if (acceptance_peaks(i,j) == 0) && (acceptance_single_p_gau(i,j) == 0)
        update_panel_title_II(fig_handle,sinlge_profile_panel_layout(i,j),sprintf('Rejected'),12,[0 0 1])
    elseif (acceptance_peaks(i,j) == 1) && (acceptance_single_p_gau(i,j) == 0)
        update_panel_title_II(fig_handle,sinlge_profile_panel_layout(i,j),sprintf('Peak Accepted; Gaussian Rejected'),12,[0 0.5 0])
    elseif (acceptance_peaks(i,j) == 1) && (acceptance_single_p_gau(i,j) == 1)
    	update_panel_title_II(fig_handle,sinlge_profile_panel_layout(i,j),sprintf('Accepted'),12,[1 0 0])
    end
    
end