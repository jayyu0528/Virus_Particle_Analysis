function img_output = make_contrasted_image( img, contrast_low, contrast_high )


%contrast_low = 100;
%contrast_high = 800;
img_output = imadjust(img ./ 65535, [contrast_low contrast_high] ./ [65535 65535]);


end

