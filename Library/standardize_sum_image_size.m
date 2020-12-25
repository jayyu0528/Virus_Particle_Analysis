function sum_image_respaced_padded = standardize_sum_image_size(pixelSize_in_preExM_um,  standard_image_pixelSize, standard_image_size, sum_image)

% Collect Sum Images
% Steps:
% 1. scale the image such that each pixel represents a pre-exm size of
%    pooled_image_pixelSize
% 2. Pad image to make its dimension into standardized pooled_image_size
% 3. Add to sum_image_pooled; iterate
scaling_ratio = (pixelSize_in_preExM_um ./ standard_image_pixelSize);
size_to_rescale_to = find_closest_even_integer( size(sum_image,1) .* scaling_ratio );

sum_image_respaced = imresize(sum_image , ones(1,2).*size_to_rescale_to);
padding_size = standard_image_size - size_to_rescale_to;
if padding_size < 0
    error('Rescaled image is larger than the dimension of the pooled container.')
elseif mod(padding_size,2) ~= 0
    error('Padding size is not divisible by 2, which should not happen since both "pooled_image_size" and "size_to_rescale_to" should be even.');
end
sum_image_respaced_padded = padarray(sum_image_respaced, ones(1,2).* padding_size/2 , 'both');
