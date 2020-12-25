function [L1_m1_ind, L1_m2_ind] = analyze_line_profile( line_profile, lineLength_1side )

if (length(line_profile) ~= lineLength_1side*2+1)
    error('line_profile length inconsistency');
end

seg1 = 1:lineLength_1side;
seg2 = lineLength_1side+2 : lineLength_1side*2+1;
L1_m1_ind = seg1 ( find(line_profile(seg1) == max(line_profile(seg1)), 1) );
L1_m2_ind = seg2 ( find(line_profile(seg2) == max(line_profile(seg2)), 1) );

end

