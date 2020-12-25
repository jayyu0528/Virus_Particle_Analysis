function ROI_data = extract_data_from_ROI(if_check_ROI_profiles, completed_workspace2_names)

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% IMPORTANT OUTPUT INFO %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In the output data,
% All sigma values (even single-profiles, which was not diagonal-length-corrected
% in the data structure) are diagonal-length-corrected.
% Pooled x-values are diagonal-length-corrected.
% Pooled y-values are BKG-subtracted.

% All values are in the unit of pixels;
% ExpFactor and PixelSize have not been applied yet
% (To do at cross-folder level)

[workspace2_name, folder_path] = uigetfile();

slash_loc = strfind(folder_path,'/');
disp(sprintf('\nFolder name:'));
disp([folder_path(slash_loc(end-1)+1:slash_loc(end))]);
disp(sprintf('\n'));

answer = inputdlg(...
    {'Sample Type (TG = tetragel; PAA = poly-acrylamide/acrylate)','Expansion Factor','Annotator'},'ROI Parameters',1,...
    {'','',''});

if ~strcmp(answer{1},'TG_9') && ~strcmp(answer{1},'PAA_10') && ~strcmp(answer{1},'TG_6') && ~strcmp(answer{1},'TG_7') && ~strcmp(answer{1},'TG_8') ...
        && ~strcmp(answer{1},'TG_1') && ~strcmp(answer{1},'PAA_2') && ~strcmp(answer{1},'TG_3')
    error('Sample Type can only be TG_1,3,10,6,7,8 or PAA_2,10');
end

%%
load([folder_path workspace2_name],'particle_data_2','lineLength2','p')

if p ~= -1
    error('Loaded Workspace_II has not been completed.  Not all particles have been analyzed.');
end

if sum(strcmp(workspace2_name, completed_workspace2_names))
    error('Loaded Workspace_II has the same filename as a previously selected one.  An error is thrown to avoid duplication.');
end

numParticles = length(particle_data_2.WidthMeasurements);
img_crop_stack = zeros(lineLength2*2+1, lineLength2*2+1, numParticles);

single_p_sigma = [];
single_p_sigma_avg = [];
particle_p_sigma = []; % This is FWHM-centered, as the only form implemented in analysis II code

% 2 types of x_pooled, depending on centering method
x_ROI_pooled_FWHM_centered = [];
x_ROI_pooled_gaufit2_centered = [];
% corresponding y_pooled (some particles do not have FWHM, so list length
% is different)
y_ROI_pooled_BKG_sub_FWHM_centered = [];
y_ROI_pooled_BKG_sub_gaufit2_centered = [];

particle_p_sigma_gaufit2_centered = [];

%
for p = 1:numParticles
    width_data = particle_data_2.WidthMeasurements(p);
    img_crop_stack(:,:,p) = width_data.ImgCrop;
    
    ind_accepted_p = find(width_data.Acceptance_single_p_gau);
    
    if isempty(ind_accepted_p)
        continue % go to the next particle if all profiles rejected
    end
    
    %% gaufit2 outputs collection
    
    % Correct diagonal-length of single-profiles
    single_profile_sigma = reshape([width_data.gaufit2_outputs.sigma],4,2);
    single_profile_sigma(2,:) = single_profile_sigma(2,:) .* sqrt(2);
    single_profile_sigma(4,:) = single_profile_sigma(4,:) .* sqrt(2);
    
    single_p_to_include = single_profile_sigma(ind_accepted_p);
    
    single_p_sigma = [single_p_sigma ; single_p_to_include];
    single_p_sigma_avg = [single_p_sigma_avg ; mean(single_p_to_include)];
    
    if width_data.Acceptance_p_avg_gau
        particle_p_sigma = [particle_p_sigma ; width_data.Particle_avg_gaufit2_output.sigma];
    end
    
    %%    % stacks of profiles
    
    % Collect accepted profiles from particle
    peaks_accepted = find(width_data.Acceptance_peaks')';
    
    x_particle_pooled_gaufit2_centered = []; % will be centered by gaufit2 mu
    y_particle_pooled_BKG_sub_gaufit2_centered = []; % will be BKG-subbed
    
    %     %
    %     x_pooled = [];
    %     y_pooled = [];
    %     %
    
    for l = peaks_accepted
        [j, i] = ind2sub([2 4], l); % same indexing as original script
        
        x_profile = ( 1 : length(width_data.L_profiles{i,j}) );
        
        % ===== Note =====
        % Unlike in original script,
        % Profiles are BKG-subtracted, and then compiled into pooled variable
        % ================
        y_profile_BKG_sub = width_data.L_profiles{i,j} - width_data.BKG_particle;
        
        if strcmp(width_data.FWHM_outputs(i,j).status,'Success')
            x_profile_FWHM_centered = x_profile - width_data.FWHM_outputs(i,j).center_loc;
            % For diagonal profiles, scale x
            if ismember(i,[2 4])
                x_profile_FWHM_centered = x_profile_FWHM_centered .* sqrt(2);
            end
            
            % Collect for particle-profile fitting
            % === Already done in original analysis II ===
            
            % Collect for ROI-profile fitting
            x_ROI_pooled_FWHM_centered = [x_ROI_pooled_FWHM_centered x_profile_FWHM_centered];
            y_ROI_pooled_BKG_sub_FWHM_centered = [y_ROI_pooled_BKG_sub_FWHM_centered y_profile_BKG_sub];
            
        end
        
        if strcmp(width_data.gaufit2_outputs(i,j).status,'Success')
            x_profile_gaufit2_centered = x_profile - width_data.gaufit2_outputs(i,j).mu;
            % For diagonal profiles, scale x
            if ismember(i,[2 4])
                x_profile_gaufit2_centered = x_profile_gaufit2_centered .* sqrt(2);
            end
            
            % Collect for particle-profile fitting
            x_particle_pooled_gaufit2_centered = [x_particle_pooled_gaufit2_centered x_profile_gaufit2_centered];
            y_particle_pooled_BKG_sub_gaufit2_centered = [y_particle_pooled_BKG_sub_gaufit2_centered y_profile_BKG_sub];
            
            % Collect for ROI-profile fitting
            x_ROI_pooled_gaufit2_centered = [x_ROI_pooled_gaufit2_centered x_profile_gaufit2_centered];
            y_ROI_pooled_BKG_sub_gaufit2_centered = [y_ROI_pooled_BKG_sub_gaufit2_centered y_profile_BKG_sub];
        end
        
    end
    
    % Perform analysis
    p_avg_gaufit2_output_gaufit2_centered = ...
        perform_gaufit2_analysis(...
        x_particle_pooled_gaufit2_centered, ...
        y_particle_pooled_BKG_sub_gaufit2_centered, ...
        0, 0, 0, 0);
    
    if strcmp(p_avg_gaufit2_output_gaufit2_centered.status,'Success')
        particle_p_sigma_gaufit2_centered = [particle_p_sigma_gaufit2_centered ; p_avg_gaufit2_output_gaufit2_centered.sigma];
    end
    
end

%% Run ROI-wide-averaged profile's gaufit2

% Perform analysis
gaufit2_output_ROI_profile_FWHM_centered = perform_gaufit2_analysis(x_ROI_pooled_FWHM_centered, y_ROI_pooled_BKG_sub_FWHM_centered, 0, 0, 0, 0);
gaufit2_output_ROI_profile_gaufit2_centered = perform_gaufit2_analysis(x_ROI_pooled_gaufit2_centered, y_ROI_pooled_BKG_sub_gaufit2_centered, 0, 0, 0, 0);

if if_check_ROI_profiles
    fig1 = figure('units','normalized','outerposition',[0.3 0 0.4 0.9]);
    display_gaufit2_on_pooled_profiles(fig1, x_ROI_pooled_FWHM_centered, y_ROI_pooled_BKG_sub_FWHM_centered, gaufit2_output_ROI_profile_FWHM_centered, [2,1] ,1, 'All accepted line profiles in ROI, center-aligned by FWHM', 0);
    display_gaufit2_on_pooled_profiles(fig1, x_ROI_pooled_gaufit2_centered, y_ROI_pooled_BKG_sub_gaufit2_centered, gaufit2_output_ROI_profile_gaufit2_centered, [2,1],2, 'All accepted line profiles in ROI, center-aligned by gaufit2', 1);
    close(fig1);
end

%% Saving
ROI_profile_data = struct(...
    'Profiles_centered_by_FWHM',[ x_ROI_pooled_FWHM_centered ; y_ROI_pooled_BKG_sub_FWHM_centered ],...
    'Profiles_centered_by_gaufit2',[ x_ROI_pooled_gaufit2_centered ; y_ROI_pooled_BKG_sub_gaufit2_centered], ...
    'gaufit2_output_FWHM_aligned_profiles',gaufit2_output_ROI_profile_FWHM_centered, ...
    'gaufit2_output_gaufit2_aligned_profiles',gaufit2_output_ROI_profile_gaufit2_centered );

ROI_width_data = struct(...
    'Single_Profile_sigma',single_p_sigma, ...
    'Single_Profile_sigma_p_avg',single_p_sigma_avg, ...
    'Particle_Profile_sigma_FWHM_centered',particle_p_sigma, ...
    'Particle_Profile_sigma_gaufit2_centered',particle_p_sigma_gaufit2_centered, ...
    'Single_Profile_sigma_r_avg',mean(single_p_sigma),...
    'Single_Profile_sigma_p_avg_r_avg',mean(single_p_sigma_avg),...
    'Particle_Profile_sigma_FWHM_centered_r_avg',mean(particle_p_sigma),...
    'Particle_Profile_sigma_gaufit2_centered_r_avg',mean(particle_p_sigma_gaufit2_centered),...
    'ROI_Profile_sigma_FWHM_centered',gaufit2_output_ROI_profile_FWHM_centered.sigma,...
    'ROI_Profile_sigma_gaufit2_centered',gaufit2_output_ROI_profile_gaufit2_centered.sigma);

ROI_data = struct(...
    'Annotator',answer{3},...
    'SampleType',answer{1},...
    'ExpFactor',str2double(answer{2}),...
    'FolderPath',folder_path,...
    'Workspace2Name',workspace2_name,...
    'ImgCropStack',img_crop_stack,...
    'SumImage',sum(img_crop_stack,3),...
    'ProfileData',ROI_profile_data,...
    'WidthData',ROI_width_data);