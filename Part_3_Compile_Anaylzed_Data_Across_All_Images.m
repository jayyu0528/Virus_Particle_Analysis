% Particle Analysis Assistant

% Part 3 - Compile Workspace2 from all image files into a single file,
% perform statistics on radii measurements and shape

% Output is Group_Data

%% Set Parameters
clear; clc; close all;

global pixelSize
pixelSize = 0.1137;

% Only particles with >= the following number of accepted radii will be
% included for analyses and statistics
global particle_radii_count_thres;
particle_radii_count_thres = 3;

%% Data structure
ROI_data = struct(...
    'Annotator',[],...
    'SampleType',[],...
    'ExpFactor',[],...
    'FolderPath',[],...
    'Workspace2Name',[],...
    'ImgCropStack',[],...
    'SumImage',[],...
    'ProfileData',[],...
    'WidthData',[],...
    'RadiiData',[]);

%% Iterate through folders to populate ROI data
r = 1;
default_vals = {'','',''};
while 1
    ROI_data(r) = extract_data_from_ROI_v5(1, {ROI_data.Workspace2Name}, default_vals );
    default_vals = {ROI_data(r).SampleType, num2str(ROI_data(r).ExpFactor), ROI_data(r).Annotator};
    
    % Ask user whether to continue to next folder
    answer = questdlg('Data from the current folder has been collected. Add more data?',...
        'Continue?','Yes','No','Yes');
    switch answer
        case 'Yes'
            r = r + 1;
        case 'No'
            break;
    end
end


%% Create particle radii data

clearvars -except ROI_data particle_radii_count_thres pixelSize

particle_data = struct([]);
p_index = 0;

for r = 1:length(ROI_data)
    for p = 1:length(ROI_data(r).RadiiData)
        
        % Only include a particle's all normalized radii,
        % if the particle meets the minimal # of radii condition
        if nnz(ROI_data(r).RadiiData(p).Acceptance_as_radius) < particle_radii_count_thres
            continue
        end
        
        p_index = p_index + 1;
        
        particle_data(p_index).sample_type = ROI_data(r).SampleType;
        particle_data(p_index).exp_factor = ROI_data(r).ExpFactor;
        particle_data(p_index).folder_path = ROI_data(r).FolderPath;
        particle_data(p_index).workspace2_name = ROI_data(r).Workspace2Name;
        particle_data(p_index).ROI_data_index = r;
        particle_data(p_index).Radii_data_index = p;
        
        % Add Width data to particle_data
        % Width data includes cropped image of particle
        wkspace = [particle_data(p_index).folder_path particle_data(p_index).workspace2_name];
        
        load(wkspace,'particle_data_2');
        in_gel_index = particle_data(p_index).Radii_data_index;
        width_data = particle_data_2.WidthMeasurements(in_gel_index);
        
        particle_data(p_index).WidthData = width_data;
        particle_data(p_index).acceptance_as_radius = ROI_data(r).RadiiData(p).Acceptance_as_radius;
        particle_data(p_index).radius_um_postEx_diag_adjusted = ROI_data(r).RadiiData(p).radius_um_diag_adjusted;
        particle_data(p_index).accepted_radii_um_preEx_vector = ...
            ROI_data(r).RadiiData(p).radius_um_diag_adjusted( ...
            logical( ...
            particle_data(p_index).acceptance_as_radius ...
            ) ...
            ) ./ particle_data(p_index).exp_factor;% pool
        particle_data(p_index).avg_of_accepted_radii_um_preEx = ...
            mean( particle_data(p_index).accepted_radii_um_preEx_vector );% pool
        particle_data(p_index).normalized_radii_vector = ...
            particle_data(p_index).accepted_radii_um_preEx_vector ./ ...
            particle_data(p_index).avg_of_accepted_radii_um_preEx ;% pool
        particle_data(p_index).avg_of_normalized_radii = ...
            mean(particle_data(p_index).normalized_radii_vector); % pool
        particle_data(p_index).std_of_normalized_radii = ...
            std(particle_data(p_index).normalized_radii_vector); % pool
        
        % 2019/09/19 added (particle-wide standard deviation of un-normalized radii)
        particle_data(p_index).std_of_radii = ...
            std(particle_data(p_index).accepted_radii_um_preEx_vector);
        
        % 2020/08/21 added (radii width)
        single_profile_sigma = reshape([width_data.gaufit2_outputs.sigma],4,2);
        single_profile_sigma(2,:) = single_profile_sigma(2,:) .* sqrt(2);
        single_profile_sigma(4,:) = single_profile_sigma(4,:) .* sqrt(2);
        single_profile_sigma_um_post_Ex_diag_adjusted = single_profile_sigma .* particle_data_2.PixelSize_um;
        particle_data(p_index).accepted_single_profile_sigma_um_preEx_vector = ...
            single_profile_sigma_um_post_Ex_diag_adjusted( ...
            logical( ...
            particle_data(p_index).acceptance_as_radius ...
            ) ...
            ) ./ particle_data(p_index).exp_factor;% pool
        
        particle_data(p_index).avg_of_accepted_single_profile_sigma_um_preEx_vector = ...
            mean(particle_data(p_index).accepted_single_profile_sigma_um_preEx_vector);
        
    end
    
end

%% Create particle shape data

global pixelSize_nm
pixelSize_nm = pixelSize * 1000;


% Calculate all stats for all particles first, and then group by gel later
particle_shape_data = struct([]); % total n = 682 (all particles with edge >= 3)

particle_index = 0;

minimum_num_of_accepted_radii_to_accept_particle = 6;

for r = 1:length(ROI_data)
    
    pixelSize_in_preExM_nm = pixelSize_nm ./ ROI_data(r).ExpFactor;
    
    for rp = 1:length(ROI_data(r).RadiiData)
        
        if ~ROI_data(r).RadiiData(rp).particle_has_sufficient_radii
            continue
        end
        
        particle_index = particle_index + 1;
        
        p_shape_data.ROI_index = r;
        p_shape_data.gel_type = ROI_data(r).SampleType;
        p_shape_data.in_ROI_particle_index = rp;
        p_shape_data.exp_factor = ROI_data(r).ExpFactor;
        p_shape_data.pixelSize_in_preExM_nm = pixelSize_in_preExM_nm;
        p_shape_data.mean_radii_nm = ROI_data(r).RadiiData(rp).particle_size .* 1000 ./ ROI_data(r).ExpFactor; % ROI_data(r).RadiiData(rp).particle_size is in postExM um
        p_shape_data.num_accepted_edges = sum( ROI_data(r).RadiiData(rp).Acceptance_as_radius(:) );
        
        if p_shape_data.num_accepted_edges >= minimum_num_of_accepted_radii_to_accept_particle
        
        % === Eccentricity ===
        % This analysis requires 4x acceptance of 2 pairs of perpendicular
        % axes, where both co-linear edges are accepted (in order to get
        % major and minor axes)
        [p_shape_data.major_axis_length_nm, p_shape_data.minor_axis_length_nm] = ...
            calc_major_minor_axis_length( ROI_data(r).RadiiData(rp) , pixelSize_in_preExM_nm ) ;
        
        p_shape_data.eccentricity = p_shape_data.minor_axis_length_nm ./ ...
            p_shape_data.major_axis_length_nm;
        
        % === Sphericity ===
        p_shape_data.sphericity = calc_sphericity( ROI_data(r).RadiiData(rp) );
        
        % === Circular Variance / STD ===
        % The raw value is hugely affected by particle size due to ^2
        % dependence ; can be normalized by dividing the residual by mean
        % particle radius
        
        [p_shape_data.circ_std_nm , p_shape_data.normalized_circ_std] = ...
            calc_circ_std( ROI_data(r).RadiiData(rp) , ...
            pixelSize_in_preExM_nm );
        
        else
            p_shape_data.major_axis_length_nm = [];
            p_shape_data.minor_axis_length_nm = [];
            p_shape_data.eccentricity = [];
            p_shape_data.sphericity = [];
            p_shape_data.circ_std_nm = [];
            p_shape_data.normalized_circ_std = [];
        end
            
        p_shape_data
        
        particle_shape_data = [particle_shape_data , p_shape_data];
    end
end


%% Saving grouped, pooled data

currTime = clock;
timestamp = [num2str(currTime(1)*10000+ currTime(2) * 100 + currTime(3)) '-' num2str(currTime(4),'%.2d') '-' num2str(currTime(5),'%.2d')];
saveName = ['Grouped_Data_' timestamp];
save(saveName,'ROI_data','pixelSize','particle_data','particle_shape_data','particle_radii_count_thres');
disp(sprintf(['\n==========================================\n' saveName ' has been saved.\n==========================================\n']));

