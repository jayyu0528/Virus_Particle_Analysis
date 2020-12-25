% Apply polygon estimation on particle, and calculate polygon area, polygon
% perimeter;  check if polygon is convex (i.e. no denting inward);
% calculate convex perimeter
function [polygon_area_nm2, ... 
        polygon_perimeter_nm, ...
        convex_perimeter_nm] = ...
        run_polygon_estimation_and_analysis( radiiData , particle_img , pixelSize_in_preExM_nm)

    plotting_results = 0;
    
    treat_vertice_of_unaccepted_edges_as = 'empty';
    % this is dangerous; polygon shape is strongly affected by the
    % whether the accepted edges are packed together on 1 side, or broadly
    % distributed
    
    LineLength2 = (size(particle_img,1)-1)/2;
    
    img_center_index = (size(particle_img,1)+1)/2;
    img_full_length = size(particle_img,1);
    
    % polygon_point_set is ordered by 
    % (1) -x axis, when image is shown by axis xy
    % (2...) following (1) clockwise
    
    diag_factor = sqrt(2);
    
    switch treat_vertice_of_unaccepted_edges_as
        case 'empty'
            disp('Warning: Treating vertices of unaccepted edges as empty');
            
            polygon_point_set(1,1:2) = [ img_center_index , -radiiData.radius_px_diag_adjusted(1,1) + 1 + LineLength2];
            polygon_point_set(2,1:2) = ones(1,2) .* (-radiiData.radius_px_diag_adjusted(2,1) ./ diag_factor + 1 + LineLength2);
            polygon_point_set(3,1:2) = [ -radiiData.radius_px_diag_adjusted(3,1) + 1 + LineLength2 , img_center_index ];
            polygon_point_set(4,1:2) = [(-radiiData.radius_px_diag_adjusted(4,2) ./ diag_factor + 1 + LineLength2), (radiiData.radius_px_diag_adjusted(4,2) ./ diag_factor + 1 + LineLength2)];
            polygon_point_set(5,1:2) = [ img_center_index , radiiData.radius_px_diag_adjusted(1,2) + 1 + LineLength2];
            polygon_point_set(6,1:2) = ones(1,2) .* (radiiData.radius_px_diag_adjusted(2,2) ./ diag_factor + 1 + LineLength2);
            polygon_point_set(7,1:2) = [ radiiData.radius_px_diag_adjusted(3,2) + 1 + LineLength2 , img_center_index ];
            polygon_point_set(8,1:2) = [(radiiData.radius_px_diag_adjusted(4,1) ./ diag_factor + 1 + LineLength2), (-radiiData.radius_px_diag_adjusted(4,1) ./ diag_factor + 1 + LineLength2)];
            
            linear_acceptance = [...
                radiiData.Acceptance_as_radius(1,1),...
                radiiData.Acceptance_as_radius(2,1), ...
                radiiData.Acceptance_as_radius(3,1), ...
                radiiData.Acceptance_as_radius(4,2), ...
                radiiData.Acceptance_as_radius(1,2), ...
                radiiData.Acceptance_as_radius(2,2), ...
                radiiData.Acceptance_as_radius(3,2), ...
                radiiData.Acceptance_as_radius(4,1)];
            
            % Remove non-zero members
            polygon_point_set( linear_acceptance(:)==0 , :) = [];
    end
    
    polyg_shape = polyshape(polygon_point_set(:,2), polygon_point_set(:,1));
    
    convhull_index = convhull(polygon_point_set(:,2), polygon_point_set(:,1));
    
    convhull_point_set = polygon_point_set(convhull_index,:);
    
    convhull_shape = polyshape(convhull_point_set(:,2), convhull_point_set(:,1));
    
    
    polygon_area_nm2 = polyarea(polygon_point_set(:,2), polygon_point_set(:,1) ) .* (pixelSize_in_preExM_nm .^ 2);
    polygon_perimeter_nm = perimeter(polyg_shape) .* pixelSize_in_preExM_nm;
    convex_perimeter_nm = perimeter(convhull_shape) .* pixelSize_in_preExM_nm;
    
    if plotting_results
        figure(1);clf
        imagesc(particle_img); colormap gray; axis square; axis xy; hold on;
        lin_img = particle_img(:);
        set(gca,'CLim',[prctile(lin_img,70) prctile(lin_img,95)]);
        plot([ img_center_index img_center_index], [1 img_full_length],'Color',[1 1 1])
        plot([1 img_full_length],[ img_center_index img_center_index], 'Color',[1 1 1])
        plot([ 1 img_full_length], [1 img_full_length],'Color',[1 1 1])
        plot([ 1 img_full_length], [img_full_length 1],'Color',[1 1 1])
        figure(1);
        plot(polygon_point_set(:,2), polygon_point_set(:,1),'Marker','o','MarkerSize',16,'MarkerEdgeColor',[1 0 0]);
        plot(polyg_shape);
        plot(convhull_shape);
        pause(0.1);
    end
    
    
end