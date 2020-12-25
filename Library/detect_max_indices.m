function max_indices = detect_max_indices(line_profiles)

max_indices = zeros(size(line_profiles));
for i = 1:size(line_profiles,1)
    for j = 1:size(line_profiles,2)
        max_indices(i,j) = find(line_profiles{i,j} == max(line_profiles{i,j}), 1);
    end
end