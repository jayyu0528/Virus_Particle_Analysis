function [img, img_zoom, img_crop] = display_global_and_local_panels(fig_handle, stack, particle_data, particle_index, x_loc, y_loc, z_plane, lineLength2, contrast_low, contrast_high)
global global_font_size_modifier;

figure(fig_handle); clf;

line_cut_color = {[1 0 0],[0 1 0],[0 1 1],[1 0 1]};

% Global view
img = stack(:,:,z_plane);
img_disp = make_contrasted_image(img, contrast_low, contrast_high);

subplot(4,3,[1 4]); cla;
imagesc(img_disp); colormap gray; axis xy; axis square
hold on;

display_analyzed_loc_II(fig_handle, particle_data);

% Local view
% contrasted
img_zoom = img_disp (y_loc - lineLength2 : y_loc + lineLength2, ...
    x_loc - lineLength2 : x_loc + lineLength2);
% non-contrasted (for analysis)
img_crop = img (y_loc - lineLength2 : y_loc + lineLength2, ...
    x_loc - lineLength2 : x_loc + lineLength2);

subplot(4,3,[7 10]); cla;
imagesc(img_zoom); colormap gray; axis xy; axis square
title(['Particle Index #' num2str(particle_index)],'fontsize',16 * global_font_size_modifier);
hold on;

size_img_zoom = size(img_zoom,1);
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