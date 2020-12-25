% Calculate major and minor axis length in preExM nm; if a
% particle does not have enough accepted edges to calculate these, return both as [].

function [major_axis_length_nm, minor_axis_length_nm] = ...
    calc_major_minor_axis_length( radiiData , pixelSize_in_preExM_nm )

axis_has_co_accepted_edges = sum( radiiData.Acceptance_as_radius , 2) == 2;

axis_length = sum( radiiData.radius_px_diag_adjusted , 2);

major_axis_length_px = [];
minor_axis_length_px = [];

if axis_has_co_accepted_edges(1) && axis_has_co_accepted_edges(3)
    major_axis_length_px = max( axis_length([1 3]) );
    minor_axis_length_px = min( axis_length([1 3]) );
end

if axis_has_co_accepted_edges(2) && axis_has_co_accepted_edges(4) 
    if isempty(major_axis_length_px) % the other pair of axes is not compatible
        major_axis_length_px = max( axis_length([2 4]) );
        minor_axis_length_px = min( axis_length([2 4]) );
    else % both pair of axes are compatible (i.e. all 8 edges accepted)
        if max( axis_length([2 4]) ) > major_axis_length_px
            % write over value, if major axis of the current pair is
            % greater than the other one
            major_axis_length_px = max( axis_length([2 4]) );
            minor_axis_length_px = min( axis_length([2 4]) );
        end
    end
end

major_axis_length_nm = major_axis_length_px .* pixelSize_in_preExM_nm;
minor_axis_length_nm = minor_axis_length_px .* pixelSize_in_preExM_nm;

end

