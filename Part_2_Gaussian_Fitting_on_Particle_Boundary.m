% Particle Analysis Assistant

% Part 2 - Particle Center Selection (Fine) + Gaussian fitting on particle
% boundary

% This script prompts user to load the output from the Part 1 file, to
% refine center selection, and to accept or reject Gaussian fitting on
% virion boundary in 8 directions.

% Output of this script is a Workspace2 file, to be loaded by the Part 3
% script.

%% User - Manually set font size modifier here
global global_font_size_modifier;
global_font_size_modifier = 1.0;

%% Load particle_data
clearvars -except global_font_size_modifier; clc; close all;

answer = questdlg('Select Session Type to load','Session Type','I','II','II');

switch answer
    case 'I'
        [stack, particle_data_2, contrast_low, contrast_high, sample_type] = load_workspace1();
        accepted_particle_indices = find(strcmp({particle_data_2.DiameterMeasurements.Acceptance},'Accepted'));
        p_to_start = 1;
        lineLength2 = decide_lineLength2(particle_data_2, stack, accepted_particle_indices);
    case 'II'
        [stack, particle_data_2, contrast_low, contrast_high, accepted_particle_indices, p_to_start, lineLength2] = load_workspace2();
        % Check if all particles have been analyzed
        if p_to_start == -1
            disp('All accepted particles in the loaded Workspace2 have been analyzed.');
            return;
        end
    case 'Cancel'
        return
end

%% Main
fig1 = figure('units','normalized','outerposition',[0 0 1 1]); clf;

for p = p_to_start:length(accepted_particle_indices)
    try
    WidthMeasurement = perform_profile_width_analysis_on_particle(fig1, particle_data_2, accepted_particle_indices(p), stack, contrast_low, contrast_high, lineLength2);
    catch curr_exception
        % if error
        disp(curr_exception);
        answer = questdlg('An error has caused the code to crash. Save completed particle data up to this point?','Emergency saving option','No','Yes','Yes');
        if strcmp(answer,'Yes')
            save_data_and_close_figure('Workspace2_',fig1,particle_data_2,contrast_low,contrast_high, accepted_particle_indices, p, lineLength2, curr_exception);
        else
            close(fig1);
        end
        disp(sprintf(['\n\n\n==========================================\nPlease perform the following:\n1. Report error message to Jay (error message is contained in the saved file)\n2. See if you can reliably reproduce the error by performing the same action \n==========================================\n']));
        return
    end
    
    % if no error
    switch WidthMeasurement.Status
        case 'Completed'
            particle_data_2.WidthMeasurements(p) = WidthMeasurement;
        case 'SaveSignal'
            save_data_and_close_figure(['Workspace2_' sample_type '_'],fig1,particle_data_2,contrast_low,contrast_high, accepted_particle_indices, p, lineLength2, sample_type);
            return
        otherwise
            error('Unrecognized status');
    end
    
end

save_data_and_close_figure(['Workspace2_' sample_type '_'],fig1,particle_data_2,contrast_low,contrast_high, accepted_particle_indices, -1, lineLength2, sample_type);
disp(sprintf(['\n==========================================\nAll accepted particles have been analyzed.\nNumber of analyzed particles = ' num2str(length(accepted_particle_indices)) '\n==========================================\n']));
return


