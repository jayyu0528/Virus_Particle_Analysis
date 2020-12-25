function [L_profiles, L_max_indices] = perform_line_profile_analysis_HIV_v1(img_zoom)

% Perform diameter analysis along 0 deg, 45 deg, 90 deg, 135 deg directions, using lineLength_1side
L_profiles_full = cell(4,1);
L_profiles = cell(4,2);

% L_profiles{1} = img_zoom(ceil(end/2) , :);
% L_profiles{2} = diag(img_zoom);
% L_profiles{3} = img_zoom(: , ceil(end/2) );
% L_profiles{4} = diag(flipud(img_zoom));


L_profiles_full{1} = img_zoom(ceil(end/2) , :);
L_profiles_full{2} = diag(img_zoom)';
L_profiles_full{3} = img_zoom(: , ceil(end/2) )';
L_profiles_full{4} = diag(flipud(img_zoom))';

% Current sectioning misses the center pt
for i = 1:4
    L_profiles{i,1} = L_profiles_full{i}(1:ceil(end/2));
    L_profiles{i,2} = L_profiles_full{i}(ceil(end/2)+1:end);
end


L_max_indices = detect_max_indices(L_profiles);

end

