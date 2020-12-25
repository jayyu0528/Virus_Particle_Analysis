function ROI_data = extract_data_from_ROI()

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%% IMPORTANT OUTPUT INFO %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% In the output data,
% All sigma values (even single-profiles, which was not diagonal-length-corrected
% in the data structure) are diagonal-length-corrected.
% Pooled x-values are diagonal-length-corrected.
% Pooled y-values are BKG-subtracted.

[workspace2_name, folder_path] = uigetfile();

answer = inputdlg(...
    {'Sample Type (TG = tetragel; PAA = poly-acrylamide/acrylate)','Expansion Factor'},'ROI Parameters',1,...
    {'',''});

if ~strcmp(answer{1},'TG') && ~strcmp(answer{1},'PAA')
    error('Sample Type can only be "TG" or "PAA"');
end

%%
load([folder_path workspace2_name],'particle_data_2','lineLength2')

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
            %             %
            %             x_pooled = [x_pooled x_profile_FWHM_centered];
            %             y_pooled = [y_pooled y_profile_BKG_sub];
            %             %
            
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
    
    %     %
    %     p_avg_gaufit2_output_FWHM_centered = ...
    %         perform_gaufit2_analysis(...
    %         x_pooled, ...
    %         y_pooled, ...
    %         0, 0, 0, 0);
    %     if strcmp(p_avg_gaufit2_output_gaufit2_centered.status,'Success')
    %         particle_p_sigma_FWHM_centered = [particle_p_sigma_FWHM_centered ; p_avg_gaufit2_output_FWHM_centered.sigma];
    %     end
    %     %
    
    %     if p == 18
    %
    %         figure(3);clf;
    %
    %
    %         subplot(2,1,1); hold on;
    %         plot(x_pooled, y_pooled,'ob');
    %         gaufit2_output = p_avg_gaufit2_output_FWHM_centered;
    %         x_display = -20:0.1:20;
    %         pre_exponent_term = gaufit2_output.normFactor * 1 / gaufit2_output.sigma / sqrt(2*pi);
    %         y_display = pre_exponent_term * exp(-(x_display- gaufit2_output.mu).^2/(2 * gaufit2_output.sigma^2 )) + width_data.BKG_particle;
    %         plot(x_display,y_display,'color',[0 0 1]);
    %         title('Centered by FWHM','FontWeight','bold')
    %         %plot(ones(1,2) * gaufit2_output.mu, [0 pre_exponent_term],'color',gaufit2_centerline_color);
    %
    %         subplot(2,1,2); hold on;
    %         plot(x_particle_pooled_gaufit2_centered,y_particle_pooled_BKG_sub_gaufit2_centered,'or');
    %         gaufit2_output = p_avg_gaufit2_output_gaufit2_centered;
    %         x_display = -20:0.1:20;
    %         pre_exponent_term = gaufit2_output.normFactor * 1 / gaufit2_output.sigma / sqrt(2*pi);
    %         y_display = pre_exponent_term * exp(-(x_display- gaufit2_output.mu).^2/(2 * gaufit2_output.sigma^2 )) + width_data.BKG_particle;
    %         plot(x_display,y_display,'color',[1 0 0]);
    %         title('Centered by gaufit2','FontWeight','bold')
    %         %plot(ones(1,2) * gaufit2_output.mu, [0 pre_exponent_term],'color',gaufit2_centerline_color);
    %
    %     end
    
end

%% Check ROI-wide-averaged profile's gaufit2
fig1 = figure('units','normalized','outerposition',[0.3 0 0.4 0.9]);
gaufit2_output_ROI_profile_FWHM_centered = perform_gaufit2_on_ROI_profiles(fig1, x_ROI_pooled_FWHM_centered, y_ROI_pooled_BKG_sub_FWHM_centered, [2,1] ,1, 'All accepted line profiles in ROI, center-aligned by FWHM', 0);
gaufit2_output_ROI_profile_gaufit2_centered = perform_gaufit2_on_ROI_profiles(fig1, x_ROI_pooled_gaufit2_centered, y_ROI_pooled_BKG_sub_gaufit2_centered, [2,1],2, 'All accepted line profiles in ROI, center-aligned by gaufit2', 1);
close(fig1);

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
    'SampleType',answer{1},...
    'ExpFactor',str2double(answer{2}),...
    'FolderPath',folder_path,...
    'Workspace2Name',workspace2_name,...
    'ImgCropStack',img_crop_stack,...
    'SumImage',sum(img_crop_stack,3),...
    'ProfileData',ROI_profile_data,...
    'WidthData',ROI_width_data);