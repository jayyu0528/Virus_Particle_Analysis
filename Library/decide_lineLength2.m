function lineLength2 = decide_lineLength2(particle_data_2, stack, accepted_particle_indices)

lineLength_max = particle_data_2.DiameterMeasurements(1).LineLength;
lineLength2 = lineLength_max;

fig_handle = figure;clf;

% Adjust lineLength2 to reduce gaufit error
while 1    
    sum_image = make_sum_image_of_accepted_particles(particle_data_2, stack, accepted_particle_indices, lineLength2);
    display_sum_image(fig_handle, sum_image, lineLength2, lineLength_max);
    
    btn = detect_button_press();
    switch btn
        case 28 % left key
            lineLength2 = lineLength2 - 1;
        case 29 % right key
            if lineLength2 < lineLength_max
                lineLength2 = lineLength2 + 1;
            end
        case 32 % space key
            close(fig_handle);
            return
    end
end