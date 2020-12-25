function WidthMeasurement = perform_profile_width_analysis_on_particle(fig_handle, particle_data_2, p, stack, contrast_low, contrast_high, lineLength2)

index = particle_data_2.DiameterMeasurements(p).Index;
% lineLength2 = particle_data_2.DiameterMeasurements(p).LineLength;
x_loc = particle_data_2.DiameterMeasurements(p).X_loc;
y_loc = particle_data_2.DiameterMeasurements(p).Y_loc;
z_plane = particle_data_2.DiameterMeasurements(p).Z_plane;

sizeX = size(stack,1);
sizeY = size(stack,2);

% Assign color and layout space for each line profile
single_profile_panel_layout = [2 3;5 6;8 9;11 12];
single_profile_colors = {...
    [0 0 0],[0 0 0];
    [0 0 0],[0 0 0];
    [0 0 0],[0 0 0];
    [0 0 0],[0 0 0]};

while 1
    [~, ~, img_crop] = display_global_and_local_panels(fig_handle, stack, particle_data_2, p, x_loc, y_loc, z_plane, lineLength2, contrast_low, contrast_high);
    
    update_panel_title_II(fig_handle,[1,4],sprintf('Arrow key: move center | C: change contrast\nS: save and exit | Space: continue'),16,[0 0 0])
    
    btn = detect_button_press();
    switch btn
        case 28 % left key
            if check_value_in_range(x_loc - 1 - lineLength2, 1, sizeX)
                x_loc = x_loc - 1;
            end
        case 29 % right key
            if check_value_in_range(x_loc + 1 + lineLength2, 1, sizeX)
                x_loc = x_loc + 1;
            end
        case 30 % up key
            if check_value_in_range(y_loc + 1 + lineLength2, 1, sizeY)
                y_loc = y_loc + 1;
            end
        case 31 % down key
            if check_value_in_range(y_loc - 1 - lineLength2, 1, sizeY)
                y_loc = y_loc - 1;
            end
        case 99 % C key - adjust contrast
            while 1
                [~, ~, img_crop] = display_global_and_local_panels(fig_handle, stack, particle_data_2, p, x_loc, y_loc, z_plane, lineLength2, contrast_low, contrast_high);
                update_panel_title_II(fig_handle,[1,4],sprintf('left right keys: adjust lower boundary \n up down keys: adjust higher boundary \n Space: continue'),12,[0 0 0])
                btn2 = detect_button_press();
                switch btn2
                    case 28 % left key
                        if check_value_in_range(contrast_low - 100, 1, min([65535 contrast_high-1]) )
                            contrast_low = contrast_low - 100;
                        end
                    case 29 % right key
                        if check_value_in_range(contrast_low + 100, 1, min([65535 contrast_high-1]) )
                            contrast_low = contrast_low + 100;
                        end
                    case 30 % up key
                        if check_value_in_range(contrast_high + 300, max([1 contrast_low+1]) ,  65535)
                            contrast_high = contrast_high + 300;
                        end
                    case 31 % down key
                        if  check_value_in_range(contrast_high - 300, max([1 contrast_low+1]) , 65535)
                            contrast_high = contrast_high - 300;
                        end
                    case 32 % space key
                        break;
                end
            end
            
        case 115 % save key -- save workspace and exit
            WidthMeasurement.Status = 'SaveSignal';
            return
        case 32 % space key
            break % continue to next stage
            
    end
end

update_panel_title_II(fig_handle,[1,4],'',12,[0 0 0])


%% Background estimation
% Local BKG
img_linear = reshape(img_crop,1,numel(img_crop));
img_linear_sorted = sort(img_linear);
prc = 20;

BKG_particle = prctile(img_linear_sorted,prc);

%% Single-Edge Profiles
figure(fig_handle);

clf;
[~, ~, ~] = display_global_and_local_panels(fig_handle, stack, particle_data_2, p, x_loc, y_loc, z_plane, lineLength2, contrast_low, contrast_high);

[L_profiles, peak_indices] = perform_line_profile_analysis(img_crop);

% x_flat = 1:length(L_profiles{1});
% x_diag = x_flat * sqrt(2);

FWHM_outputs = struct('status','','max_index','','FWHM','','HM','','FWHM_indices',[],'FWHM_borders',[],'sub_pixel_dist_left','','sub_pixel_dist_right','','left_loc','','right_loc','','center_loc','');
FWQM_outputs = struct('status','','max_index','','FWHM','','HM','','FWHM_indices',[],'FWHM_borders',[],'sub_pixel_dist_left','','sub_pixel_dist_right','','left_loc','','right_loc','','center_loc','');
gaufit2_outputs = struct('status','','sigma','','mu','','normFactor','');

acceptance_peaks = ones(4,2) * -1;
acceptance_single_p_gau = ones(4,2) * -1;

% Initial display
for l = 1:8
    [j, i] = ind2sub([2 4], l);
    
    % Save analysis results
    FWHM_outputs(i,j) = perform_FWHM_analysis_v2(L_profiles{i,j}, peak_indices(i,j), BKG_particle, 0.5);
    FWQM_outputs(i,j) = perform_FWHM_analysis_v2(L_profiles{i,j}, peak_indices(i,j), BKG_particle, 0.25);
    gaufit2_outputs(i,j) = perform_gaufit2_analysis(1:length(L_profiles{i,j}), L_profiles{i,j}, BKG_particle, 1, 0, 0);
    % Display
    display_profile_with_analysis_results(single_profile_panel_layout(i,j), L_profiles{i,j}, peak_indices(i,j), BKG_particle, FWQM_outputs(i,j), 1, gaufit2_outputs(i,j), 1, single_profile_colors{i,j},l);
    
end


% Interative Portion

update_panel_title_II(fig_handle,[1,4],sprintf('M: Move peak | Up: Back | Left: Reject\nRight: Accept peak only | Down: Accept peak and Gaussian'),16,[0 0 0])


l = 1;
while 1
    [j, i] = ind2sub([2 4], l);
    
    update_panel_title_II(fig_handle,single_profile_panel_layout(i,j),sprintf('=== Current Profile ==='),12, [0 0 0])
    
    btn = detect_button_press();
    switch btn
        case 109 % M key - move peak location
            update_panel_title_II(fig_handle,single_profile_panel_layout(i,j),sprintf('< >: move peak'),12, [0 0 0])
            while 1
                btn2 = detect_button_press();
                switch btn2
                    case 28 % left key
                        if check_value_in_range(peak_indices(i,j) - 1, 1, length(L_profiles{i,j}))
                            peak_indices(i,j) = peak_indices(i,j) - 1;
                        end
                    case 29 % right key
                        if check_value_in_range(peak_indices(i,j) + 1, 1, length(L_profiles{i,j}))
                            peak_indices(i,j) = peak_indices(i,j) + 1;
                        end
                    case 32 % space key
                        break;
                end
                display_profile_with_analysis_results(single_profile_panel_layout(i,j), L_profiles{i,j}, peak_indices(i,j), BKG_particle, FWQM_outputs(i,j), 0, gaufit2_outputs(i,j), 0, single_profile_colors{i,j}, l);
            end
            
            % Update analysis results with new peak location
            FWHM_outputs(i,j) = perform_FWHM_analysis_v2(L_profiles{i,j}, peak_indices(i,j), BKG_particle, 0.5);
            FWQM_outputs(i,j) = perform_FWHM_analysis_v2(L_profiles{i,j}, peak_indices(i,j), BKG_particle, 0.25);
            % Display
            display_profile_with_analysis_results(single_profile_panel_layout(i,j), L_profiles{i,j}, peak_indices(i,j), BKG_particle, FWQM_outputs(i,j), 1, gaufit2_outputs(i,j), 1, single_profile_colors{i,j}, l);
            
        case 30 % up key
            
        case 28 % left key - reject peak and all associated analyses
            acceptance_peaks(i,j) = 0;
            acceptance_single_p_gau(i,j) = 0;
            update_panel_title_II(fig_handle,single_profile_panel_layout(i,j),sprintf('Rejected'),12,[0 0 1])
        case 29 % right key - accept peak only; reject single-p gaufit
            acceptance_peaks(i,j) = 1;
            acceptance_single_p_gau(i,j) = 0;
            update_panel_title_II(fig_handle,single_profile_panel_layout(i,j),sprintf('Peak Accepted; Gaussian Rejected'),12,[0 0.5 0])
        case 31 % down key - accept both peak and single-p gaufit
            acceptance_peaks(i,j) = 1;
            acceptance_single_p_gau(i,j) = 1;
            update_panel_title_II(fig_handle,single_profile_panel_layout(i,j),sprintf('Accepted'),12,[1 0 0])
    end
    
    % update_panel_title_II(fig_handle,sinlge_profile_panel_layout(i,j),'',12,[0 0 0])
    
    if ismember(btn,[28 29 31])
        l = l + 1;
    elseif (btn == 30) && (l > 1)
        l = l - 1;
        update_panel_title_II(fig_handle,single_profile_panel_layout(i,j),'',12,[1 0 0])
    end
    
    % Termination condition
    if l > 8
        update_panel_title_II(fig_handle,[1,4],sprintf('B: Back | Space: Confirm'),20,[0 0 0])
        while 1
            btn = detect_button_press();
            if ismember(btn, [32 98])
                break;
            end
        end
        
        switch btn
            case 32 % space key - proceed to particle avg
                
                % Reset figure
                [~, ~, ~] = display_global_and_local_panels(fig_handle, stack, particle_data_2, p, x_loc, y_loc, z_plane, lineLength2, contrast_low, contrast_high);
                
                % Particle-Average Profile
                [acceptance_p_avg_gau, p_avg_gaufit2_output] = ...
                    perform_particle_average_profile_analysis(fig_handle, acceptance_peaks, L_profiles, FWHM_outputs, BKG_particle);
                if acceptance_p_avg_gau >= 0 % case of accept or reject; not "back"
                    break;
                else % case of "back" - back to single line profile #8
                    l = l - 1;
                    re_render_single_profile_results(fig_handle, single_profile_panel_layout, L_profiles, peak_indices, BKG_particle, FWQM_outputs, gaufit2_outputs, single_profile_colors,acceptance_peaks, acceptance_single_p_gau);
                    update_panel_title_II(fig_handle,[1,4],sprintf('M: Move peak | Up: Back | Left: Reject\nRight: Accept peak only | Down: Accept peak and Gaussian'),16,[0 0 0])
                end
            case 98 % B key - back to single line profile #8
                l = l - 1;
                update_panel_title_II(fig_handle,[1,4],sprintf('M: Move peak | Up: Back | Left: Reject\nRight: Accept peak only | Down: Accept peak and Gaussian'),16,[0 0 0])
        end
    end
end


%% Save results to mother structure

% Basics
WidthMeasurement.Index = index;
WidthMeasurement.ImgCrop = img_crop;
WidthMeasurement.LineLength2 = lineLength2;
WidthMeasurement.X_loc = x_loc;
WidthMeasurement.Y_loc = y_loc;
WidthMeasurement.Z_plane = z_plane;
WidthMeasurement.BKG_particle = BKG_particle;
WidthMeasurement.L_profiles = L_profiles;
% Analysis outputs
WidthMeasurement.FWHM_outputs = FWHM_outputs;
WidthMeasurement.FWQM_outputs = FWQM_outputs;
WidthMeasurement.gaufit2_outputs = gaufit2_outputs;
WidthMeasurement.Particle_avg_gaufit2_output = p_avg_gaufit2_output;
% Manual acceptance records
WidthMeasurement.Acceptance_peaks = acceptance_peaks;
WidthMeasurement.Acceptance_single_p_gau = acceptance_single_p_gau;
WidthMeasurement.Acceptance_p_avg_gau = acceptance_p_avg_gau;

WidthMeasurement.Status = 'Completed';