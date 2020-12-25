function  update_panels( fig_handle, img, contrast_low, contrast_high,lineLength_1side, x_input, y_input, particle_data, L1, L2, L1m1, L1m2, L2m1, L2m2, pixel_size_um)

% Contrast current z image
img_disp = make_contrasted_image(img, contrast_low, contrast_high);
img_particle = img_disp (y_input - lineLength_1side : y_input + lineLength_1side, x_input - lineLength_1side : x_input + lineLength_1side);

figure(fig_handle);
% Make global panel (LEFT)
subplot(2,3,[1 4]); cla;
imagesc(img_disp); colormap gray; axis xy; axis square
hold on;
display_analyzed_loc(fig_handle , particle_data);
plot([x_input - lineLength_1side x_input + lineLength_1side],[y_input ,y_input],'color',[1 0 0]);
plot([x_input , x_input ],[y_input- lineLength_1side, y_input+ lineLength_1side],'color',[0 1 0]);

% Make local panel (MID)
subplot(2,3,[2 5]); cla; hold off
imagesc(img_particle); colormap gray; axis xy; axis square
hold on;
plot([1 lineLength_1side*2+1],[lineLength_1side+1, lineLength_1side+1],'color',[1 0 0]);
plot([lineLength_1side+1, lineLength_1side+1],[1 lineLength_1side*2+1] ,'color',[0 1 0]);
% Update local panel on max location
plot([L1m1 L1m2],[lineLength_1side+1, lineLength_1side+1],'xr','markersize',25)
plot([lineLength_1side+1, lineLength_1side+1],[L2m1 L2m2],'xg','markersize',25)

% Make line profile analysis (RIGHT)
h = subplot(2,3,3);
plot_line_profile( h, L1, L1m1, L1m2, lineLength_1side, pixel_size_um, [1 0 0]);
h = subplot(2,3,6);
plot_line_profile( h, L2, L2m1, L2m2, lineLength_1side, pixel_size_um, [0 1 0]);


end

