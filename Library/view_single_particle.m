function view_single_particle(p_data)


%%

figure(123123); clf;
% p_data = particle_data(48);
img = p_data.WidthData.ImgCrop;

p_data.radius_um_postEx_diag_adjusted

contrast_low = 100;
contrast_high = 3000;

line_cut_color = {[1 0 0],[0 1 0],[0 1 1],[1 0 1]};


img_disp = make_contrasted_image(img, contrast_low, contrast_high);
subplot(4,3,[1 4]); cla;
img_handle = imagesc(img_disp); axis square; colormap gray; hold on;

size_img_zoom = size(img,1);
plot([1 size_img_zoom],ones(1,2).*ceil(size_img_zoom/2),'color',line_cut_color{1});
plot([1 size_img_zoom],[1 size_img_zoom],'color',line_cut_color{2});
plot(ones(1,2).*ceil(size_img_zoom/2),[1 size_img_zoom],'color',line_cut_color{3});
plot([1 size_img_zoom],[size_img_zoom 1],'color',line_cut_color{4});

% Display axis index
axis_index_fontsize = 20;
text(1,ceil(size_img_zoom/2),'1','FontSize',axis_index_fontsize,'color',line_cut_color{1},'horizontalalignment','left','verticalalignment','middle');
text(size_img_zoom ,ceil(size_img_zoom/2) ,'2','FontSize',axis_index_fontsize,'color',line_cut_color{1},'horizontalalignment','right','verticalalignment','middle');
text(1, 1,'3','FontSize',axis_index_fontsize,'color',line_cut_color{2},'horizontalalignment','left','verticalalignment','bottom');
text(size_img_zoom, size_img_zoom,'4','FontSize',axis_index_fontsize,'color',line_cut_color{2},'horizontalalignment','right','verticalalignment','top');
text( ceil(size_img_zoom/2), 1,'5','FontSize',axis_index_fontsize,'color',line_cut_color{3},'horizontalalignment','center','verticalalignment','bottom');
text( ceil(size_img_zoom/2), size_img_zoom,'6','FontSize',axis_index_fontsize,'color',line_cut_color{3},'horizontalalignment','center','verticalalignment','top');
text( 1, size_img_zoom,'7','FontSize',axis_index_fontsize,'color',line_cut_color{4},'horizontalalignment','left','verticalalignment','top');
text( size_img_zoom, 1,'8','FontSize',axis_index_fontsize,'color',line_cut_color{4},'horizontalalignment','right','verticalalignment','bottom');

% Local BKG
img_linear = reshape(img,1,numel(img));
img_linear_sorted = sort(img_linear);
prc = 20;

BKG_particle = prctile(img_linear_sorted,prc);

[L_profiles, peak_indices] = perform_line_profile_analysis(img);

single_profile_panel_layout = [2 3;5 6;8 9;11 12];
single_profile_colors = {...
    [0 0 0],[0 0 0];
    [0 0 0],[0 0 0];
    [0 0 0],[0 0 0];
    [0 0 0],[0 0 0]};

% Initial display
for l = 1:8
    [j, i] = ind2sub([2 4], l);
    
    % Save analysis results
    FWHM_outputs(i,j) = perform_FWHM_analysis_v2(L_profiles{i,j}, peak_indices(i,j), BKG_particle, 0.5);
    FWQM_outputs(i,j) = perform_FWHM_analysis_v2(L_profiles{i,j}, peak_indices(i,j), BKG_particle, 0.25);
    gaufit2_outputs(i,j) = perform_gaufit2_analysis(1:length(L_profiles{i,j}), L_profiles{i,j}, BKG_particle, 1, 0, 0);
    % Display
    display_profile_with_analysis_results(single_profile_panel_layout(i,j), L_profiles{i,j}, peak_indices(i,j), BKG_particle, FWQM_outputs(i,j), 1, gaufit2_outputs(i,j), 1, single_profile_colors{i,j},l);
    
end

while 0
    
    img_disp = make_contrasted_image(img, contrast_low, contrast_high);
%     subplot(4,3,[1 4]); cla;
%     imagesc(img_disp); axis square; colormap gray; hold on;
    set(img_handle,'CData',img_disp)

    btn = detect_button_press();
    switch btn
        case 28 % left key
            if check_value_in_range(contrast_low - 10, 1, min([65535 contrast_high-1]) )
                contrast_low = contrast_low - 10;
            end
        case 29 % right key
            if check_value_in_range(contrast_low + 10, 1, min([65535 contrast_high-1]) )
                contrast_low = contrast_low + 10;
            end
        case 30 % up key
            if check_value_in_range(contrast_high + 50, max([1 contrast_low+1]) ,  65535)
                contrast_high = contrast_high + 50;
            end
        case 31 % down key
            if  check_value_in_range(contrast_high - 50, max([1 contrast_low+1]) , 65535)
                contrast_high = contrast_high - 50;
            end
        case 32 % space key
            break;
    end
end

