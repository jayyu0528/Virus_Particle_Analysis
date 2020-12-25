function [L1, L2, L1m1, L1m2, L2m1, L2m2] = perform_diameter_analysis( fig_handle, img,  contrast_low, contrast_high, x_input, y_input, lineLength_1side, pixel_size_um, particle_data)

% Perform diameter analysis along x and y direction, using lineLength_1side

L1 = img(y_input , x_input - lineLength_1side : x_input + lineLength_1side);
L2 = img(  y_input - lineLength_1side : y_input + lineLength_1side , x_input );
[L1m1,L1m2] = analyze_line_profile(L1, lineLength_1side);
[L2m1,L2m2] = analyze_line_profile(L2, lineLength_1side);

end

