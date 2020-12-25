function [XY_mask, XYZ_mask] = determine_3D_mask(p, Wdata, Ddata, particle_data_2, cropSize_XY, mask_spacing, p_stack_dims, z_height, p_stack_z_range_mode)

% Search for the particle diameter in Ddata
% (whose index is different from Wdata, due
% to rejections at the Wdata stage, etc.)
Dindex = find([Ddata.Index] == Wdata(p).Index);
if length(Dindex) ~= 1
    error('Error in searching for index in Ddata.')
end

max_diameter_in_px = ...
    max([Ddata(Dindex).Diameter1_um  Ddata(Dindex).Diameter2_um]) ...
    ./ particle_data_2.PixelSize_um;


XY_crop_radius_px = ceil(max_diameter_in_px ./ 2) + mask_spacing;

dist_to_cropped_XY_center = zeros(p_stack_dims(1,2));
cropped_XY_center_index = (cropSize_XY+1);

for y = 1:size(dist_to_cropped_XY_center,1)
    for x = 1:size(dist_to_cropped_XY_center,2)
        dist_to_cropped_XY_center(x,y) = sqrt((y - cropped_XY_center_index ).^2 + (x - cropped_XY_center_index ).^2);
    end
end

XY_mask = dist_to_cropped_XY_center < XY_crop_radius_px;

XYZ_mask = zeros(p_stack_dims);

switch p_stack_z_range_mode
    case '-z_height_to_+z_height'
        z_range_to_in_p_stack_to_sum = ...
            (z_height+1):(z_height.*2+1); % centerline index to max-z index
    case 'centerline_to_+z_height'
        z_range_to_in_p_stack_to_sum = ...
            1 : (z_height+1);
    case 'centerline_to_z_max'
        z_range_to_in_p_stack_to_sum = ...
            1 : p_stack_dims(3);
end

for z = z_range_to_in_p_stack_to_sum
    XYZ_mask(:,:,z) = XY_mask;
end