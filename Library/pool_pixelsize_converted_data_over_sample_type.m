function [sample_type_data] = ...
    pool_pixelsize_converted_data_over_sample_type(ROI_data, sample_type, sigma_lists, if_check_sample_type_profiles)

%% Notes from 20200407 (nothing changed, but describing SumImage behavior
% SumImage currently is computed from a stack of particle images.
% That stack includes all particles accepted for the Width Analysis (8
% side), so it already only contains accepted particles from Stage 1.

% Sample_type can be input as "TG", to capture all sample types 
% whose string contains "TG", e.g. "TG_1", "TG_7"

global pixelSize

pooled_image_size = 800;
pooled_image_pixelSize = 0.001; %in pre-ExM um

st_indices = find(contains({ROI_data.SampleType},sample_type));
st_ROI_data = ROI_data(st_indices);

%% Collecting Pre-processed Sample Type Data
pooled_lists = cell(1,length(sigma_lists));

x_pooled_profiles_FWHM_centered = [];
y_pooled_profiles_FWHM_centered = [];
x_pooled_profiles_gaufit2_centered = [];
y_pooled_profiles_gaufit2_centered = [];

sum_image_pooled = zeros(pooled_image_size,pooled_image_size);
sum_image_binary_pooled = zeros(pooled_image_size,pooled_image_size);


for r = 1:length(st_indices)
    % Conversion factor to um, for each ROI 
    pixelSize_in_preExM_um = pixelSize ./ st_ROI_data(r).ExpFactor;
    % Collect sigma lists
    for d = 1:length(pooled_lists)
        pooled_lists{d} = [pooled_lists{d} ; st_ROI_data(r).WidthData.(sigma_lists{d}) .* pixelSize_in_preExM_um ];
    end
    % Collect profiles
    
    x_pooled_profiles_FWHM_centered = [x_pooled_profiles_FWHM_centered, ...
        st_ROI_data(r).ProfileData.Profiles_centered_by_FWHM(1,:) .* pixelSize_in_preExM_um];
    y_pooled_profiles_FWHM_centered = [y_pooled_profiles_FWHM_centered, ...
        st_ROI_data(r).ProfileData.Profiles_centered_by_FWHM(2,:)];
    x_pooled_profiles_gaufit2_centered = [x_pooled_profiles_gaufit2_centered, ...
        st_ROI_data(r).ProfileData.Profiles_centered_by_gaufit2(1,:) .* pixelSize_in_preExM_um];
    y_pooled_profiles_gaufit2_centered = [y_pooled_profiles_gaufit2_centered, ...
        st_ROI_data(r).ProfileData.Profiles_centered_by_gaufit2(2,:)];
    
    sum_image_respaced_padded = standardize_sum_image_size(pixelSize_in_preExM_um, pooled_image_pixelSize, pooled_image_size, st_ROI_data(r).SumImage);
    sum_image_pooled = sum_image_pooled + sum_image_respaced_padded;
    
    numParticles = size(st_ROI_data(r).ImgCropStack,3);
    sum_image_binary_pooled = sum_image_binary_pooled + ( sum_image_respaced_padded > 0) .* numParticles;
end

%% Run sample-type-wide-averaged profile's gaufit2

% Perform analysis
gaufit2_output_st_profile_FWHM_centered = perform_gaufit2_analysis(x_pooled_profiles_FWHM_centered, y_pooled_profiles_FWHM_centered, 0, 0, 0, 0);
gaufit2_output_st_profile_gaufit2_centered = perform_gaufit2_analysis(x_pooled_profiles_gaufit2_centered, y_pooled_profiles_gaufit2_centered, 0, 0, 0, 0);

if if_check_sample_type_profiles
    fig1 = figure('units','normalized','outerposition',[0.3 0 0.4 0.9]);
    display_gaufit2_on_pooled_profiles(fig1, x_pooled_profiles_FWHM_centered, y_pooled_profiles_FWHM_centered, gaufit2_output_st_profile_FWHM_centered, [2,1] ,1, ['All accepted line profiles in sample type ' sample_type ', center-aligned by FWHM'], 0);
    display_gaufit2_on_pooled_profiles(fig1, x_pooled_profiles_gaufit2_centered, y_pooled_profiles_gaufit2_centered, gaufit2_output_st_profile_gaufit2_centered, [2,1],2, ['All accepted line profiles in sample type ' sample_type ', center-aligned by gaufit2'], 1);
    close(fig1);
end

%% Data Structure
sample_type_data = struct(...
    'SampleType',sample_type,...
    'Units_of_all_values',[],...
    'Single_Profile_sigma',[],...
    'Single_Profile_sigma_p_avg',[],...
    'Particle_Profile_sigma_FWHM_centered',[],...
    'Particle_Profile_sigma_gaufit2_centered',[],...
    'Single_Profile_sigma_r_avg',[],...
    'Single_Profile_sigma_p_avg_r_avg',[],...
    'Particle_Profile_sigma_FWHM_centered_r_avg',[],...
    'Particle_Profile_sigma_gaufit2_centered_r_avg',[],...
    'ROI_Profile_sigma_FWHM_centered',[],...
    'ROI_Profile_sigma_gaufit2_centered',[],...
    'SampleType_Profile_sigma_FWHM_centered',gaufit2_output_st_profile_FWHM_centered.sigma,...
    'SampleType_Profile_sigma_gaufit2_centered',gaufit2_output_st_profile_gaufit2_centered.sigma,...
    'SumImage',sum_image_pooled,...
    'SumMaskImage', sum_image_binary_pooled);

for d = 1:length(pooled_lists)
    sample_type_data.(sigma_lists{d}) = pooled_lists{d};
end
    