function display_sum_image(fig_handle, sum_image, lineLength2, lineLength_max)

global global_font_size_modifier;

figure(fig_handle);
imagesc(sum_image); colormap gray; axis xy; axis square
if lineLength2 < lineLength_max
title(sprintf(['Left: reduce line profile length\nRight: increase line profile length\nSpace: Continue' ...
    '\n\nSum Image of all accepted particles in this Workspace\nCurrent Line Profile Length = ' num2str(lineLength2)]),'FontSize',16 * global_font_size_modifier);
elseif lineLength2 == lineLength_max
    title(sprintf(['Left: reduce line profile length\n\nSpace: Continue' ...
    '\n\nSum Image of all accepted particles in this Workspace\nCurrent Line Profile Length = ' num2str(lineLength2)]),'FontSize',16 * global_font_size_modifier);
else
    error('LineLength exceeds maximum value, i.e. set length in Diameter Analysis');
end
    
xlabel(sprintf(['Note: It is advisable to leave ~4-5 pixels from the apparent border of the particle,\n' ...
    'as individual particles can be larger, and actual intensity distribution \ncan extend beyond the apparent border at current contrast settings.']),'FontSize',12 * global_font_size_modifier)