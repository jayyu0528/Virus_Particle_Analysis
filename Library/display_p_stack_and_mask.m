function display_p_stack_and_mask(fig_handle, contrast_low, contrast_high, p_stack, XYZ_mask, BKG, int_sum_BKG_sub)

MIPS_X = squeeze(max(p_stack,[],1));
MIPS_Y = squeeze(max(p_stack,[],2));
MIPS_Z = squeeze(max(p_stack,[],3));

figure(fig_handle); clf;
subplot(5,5,[4 5 9 10]); hold on;
plot(sort(reshape(p_stack,1,numel(p_stack))));
plot([0 numel(p_stack)],[BKG BKG]);

XY_mask = max(XYZ_mask,[],3) > 0;

mask_inclusive_border = bwboundaries(XY_mask,8,'noholes');
border_min_max = {[min(mask_inclusive_border{:}(:,1)), max(mask_inclusive_border{:}(:,1))] ;
    [min(mask_inclusive_border{:}(:,2)), max(mask_inclusive_border{:}(:,2))]};

occupied_z = squeeze(max(max(XYZ_mask,[],1),[],2));
z_min = find(occupied_z, 1, 'first');
z_max = find(occupied_z, 1, 'last');

% Plotting
lineSpec = 'r--';

% === MIPS_Z ===
subplot(5,5,[11:13, 16:18, 21:23]); colormap gray;
imagesc( make_contrasted_image( MIPS_Z, contrast_low, contrast_high ) );
axis xy; hold on;
%     imagesc(XY_mask)
plot(mask_inclusive_border{1}(:,1),mask_inclusive_border{1}(:,2),lineSpec);

%title(['Sum intensity of masked 3D region = ' num2str(int_sum_BKG_sub)]);

% === MIPS_Y ===
subplot(5,5,[14:5:24, 15:5:25]); colormap gray;
imagesc( make_contrasted_image( MIPS_Y, contrast_low, contrast_high ) );
axis xy; hold on;
plot( [z_max, z_min, z_min, z_max], [border_min_max{2}(1), border_min_max{2}(1), border_min_max{2}(2), border_min_max{2}(2)], lineSpec);

% === MIPS_X ===
subplot(5,5,[1:3, 6:8]); colormap gray;
imagesc( make_contrasted_image( MIPS_X', contrast_low, contrast_high ) );
axis xy; hold on;
plot([border_min_max{1}(1), border_min_max{1}(1), border_min_max{1}(2), border_min_max{1}(2)] , [z_max, z_min, z_min, z_max], lineSpec);

title(['Sum intensity of masked 3D region (BKG subtracted) = ' num2str(int_sum_BKG_sub)]);

btn = detect_button_press();