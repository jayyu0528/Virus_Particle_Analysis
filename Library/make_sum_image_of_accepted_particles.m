function sum_image = make_sum_image_of_accepted_particles(particle_data_2, stack, accepted_particle_indices, lineLength2)

img_crop_all_accepted = ones(lineLength2*2+1,lineLength2*2+1,length(accepted_particle_indices))*-1;

for p = 1:length(accepted_particle_indices)
    data = particle_data_2.DiameterMeasurements(accepted_particle_indices(p));
    x_loc = data.X_loc;
    y_loc = data.Y_loc;
    z_plane = data.Z_plane;
    
    img = stack(:,:,z_plane);
    
    % non-contrasted (for analysis)
    img_crop_all_accepted(:,:,accepted_particle_indices(p)) = ...
        img (y_loc - lineLength2 : y_loc + lineLength2, ...
        x_loc - lineLength2 : x_loc + lineLength2);
    
end

sum_image = sum(img_crop_all_accepted,3);
