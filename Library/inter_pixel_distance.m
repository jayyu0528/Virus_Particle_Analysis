function x0 = inter_pixel_distance(y1,y2,y0)

% y1 and y2 are y-values of 2 NEIGHBORING pixels
% x0 is the distance from the left (from Pt1, towards Pt2)
% y0 is the target y-value between y1 and y2, where the
% crossing occurs (x0)

if ( (y0 < y1) && (y0 < y2)) || ( (y0 > y1) && (y0 > y2))
    error('incorrect inter_pixel_distance input')
end

x0 = (y0 - y1) * (1) / (y2 - y1);

if (x0 < 0) || (x0 > 1)
    error('incorrect inter_pixel_distance output')
end
