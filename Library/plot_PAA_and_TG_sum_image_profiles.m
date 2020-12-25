function [PAA_profile, TG_profile] = plot_PAA_and_TG_sum_image_profiles(PAA_image_to_use, TG_image_to_use, x_range_half, figure_num, axis_to_plot)

% Assumes PAA and TG are at same cropped size
imgSize = size(PAA_image_to_use,1);

centerLineInd = ceil(imgSize ./ 2);

x_range = centerLineInd - x_range_half : centerLineInd + x_range_half;

PAA_profile(1,:) = PAA_image_to_use(centerLineInd,x_range);
TG_profile(1,:) = TG_image_to_use(centerLineInd,x_range);

PAA_profile(2,:) = PAA_image_to_use(x_range, centerLineInd);
TG_profile(2,:) = TG_image_to_use(x_range, centerLineInd);

% Normalization
do_normalize = 0

if do_normalize
    PAA_profile = PAA_profile - min(PAA_profile);
    PAA_profile = PAA_profile ./ max(PAA_profile);
    TG_profile = TG_profile - min(TG_profile);
    TG_profile = TG_profile ./ max(TG_profile);
end

axis_to_plot

figure(figure_num); clf;
subplot(1,3,1); hold on;
plot(PAA_profile(axis_to_plot,:),'k');
% plot(PAA_profile(2,:),'b');
title('PAA x-Profile')

subplot(1,3,2); hold on;
plot(TG_profile(axis_to_plot,:),'k');
% plot(TG_profile(2,:),'b');
title('TG x-Profile')

subplot(1,3,3); hold on
plot(PAA_profile(axis_to_plot,:),'b');
plot(TG_profile(axis_to_plot,:),'r');