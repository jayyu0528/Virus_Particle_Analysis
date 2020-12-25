function [Idata, ROI_lin_final_output] = perform_int_analysis_on_ROI(FolderPath, WorkSpace2Name, XY_mask_spacing, z_height)

% FolderPath = '/Users/Jay/Documents/MATLAB/Tetragel_Related/Virus_Particle_Analysis/Samples/180329_H20Z1A1_cf_640_0.25z_30%laser_Stack_60x(1.5xtube)_two_cmle-3-1/';
% WorkSpace2Name = 'Workspace2_20180831-16-14.mat';

% FolderPath = '/Users/Jay/Documents/MATLAB/Tetragel_Related/Virus_Particle_Analysis/Samples/180329_H20CA1_cf_640_0.25z_50%laser_Stack_60x(1.5xtube)_one_cmle-3/';
% WorkSpace2Name = 'Workspace2_20180829-23-10.mat';

% Load Workspace2; load D- and W- data, and image stack
load([FolderPath WorkSpace2Name]);
StackName = [FolderPath particle_data_2.StackName];

Ddata = particle_data_2.DiameterMeasurements;
Wdata = particle_data_2.WidthMeasurements;
Idata = struct([]);
stack = load_stack(StackName);

% Take 3 more pixels (each side) in X-Y during cropping
% in case user wants to include more X-Y area
cropSize_XY = lineLength2 + 3;


% % Default additional pixels outside of diameter on XY_mask
% XY_mask_spacing = 3; % default crop line is 3 px away from radii
% % !! Z-height has to be set per ROI (very diff between Z and C)
% z_height = 10;

p_stack_z_range_mode = '-z_height_to_+z_height';

show_p_stack_and_mask = 1;

if show_p_stack_and_mask
    fig_handle = figure(1);
end

ROI_lin_final_output = [];

% Apply analysis on WidthAnalysis-accepted particles
for p = 1:length(Wdata)
    
    disp(['=== Processing Particle p = ' num2str(p)]);
    
    
    switch p_stack_z_range_mode
        case '-z_height_to_+z_height'
            z_range_to_crop_into_p_stack = ...
                Wdata(p).Z_plane - z_height : Wdata(p).Z_plane + z_height;
        case 'centerline_to_+z_height'
            z_range_to_crop_into_p_stack = ...
                Wdata(p).Z_plane : Wdata(p).Z_plane + z_height;
        case 'centerline_to_z_max'
            z_range_to_crop_into_p_stack = ...
                Wdata(p).Z_plane : size(stack,3);
    end
    
    try
    p_stack = stack( ...
        (Wdata(p).Y_loc - cropSize_XY) : (Wdata(p).Y_loc + cropSize_XY), ...
        (Wdata(p).X_loc - cropSize_XY) : (Wdata(p).X_loc + cropSize_XY), ...
        z_range_to_crop_into_p_stack);
    catch
        disp('***** p_stack out of boundary error; skipping particle *****');
        Idata(p).p_stack_cropping_status = 'Failure';
        continue
    end
    
    % sum up accepted volumn inside p_stack
    % Method: create a 3D mask; apply to p_stack; sum up
    [XY_mask, XYZ_mask] = determine_3D_mask(p, Wdata, Ddata, particle_data_2, cropSize_XY, XY_mask_spacing, size(p_stack), z_height, p_stack_z_range_mode);
    
    % Determine background value to subtract
    BKG = prctile(reshape(p_stack,1,numel(p_stack)),50);

%     masked_p_stack = p_stack(logical(XYZ_mask));
%     int_sum = sum(sum(sum( masked_p_stack )));
    
    % Subtract background value from p_stack, prior to masking and summing
    p_stack_BKG_sub = p_stack - BKG;
    masked_p_stack_BKG_sub = p_stack_BKG_sub(logical(XYZ_mask));
    int_sum_BKG_sub = sum(sum(sum( masked_p_stack_BKG_sub )));
    
    Idata(p).p_stack_cropping_status = 'Success';
    Idata(p).Index = Wdata(p).Index;
    Idata(p).X_loc = Wdata(p).X_loc;
    Idata(p).Y_loc = Wdata(p).Y_loc;
    Idata(p).Z_plane = Wdata(p).Z_plane;
    Idata(p).cropSize_XY = cropSize_XY;
    Idata(p).XY_mask_spacing = XY_mask_spacing;
    Idata(p).z_height = z_height;
    Idata(p).p_stack = p_stack;
    Idata(p).p_stack_z_range_mode = p_stack_z_range_mode;
    Idata(p).XYZ_mask = XYZ_mask;
    Idata(p).BKG = BKG;
    Idata(p).int_sum_BKG_sub = int_sum_BKG_sub;

    ROI_lin_final_output = [ROI_lin_final_output, int_sum_BKG_sub];
    
    if show_p_stack_and_mask
        display_p_stack_and_mask(fig_handle,contrast_low,contrast_high, p_stack, XYZ_mask, BKG, int_sum_BKG_sub);
    end
  
end