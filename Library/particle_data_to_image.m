function img = particle_data_to_image(p_data)


%%



p_data = particle_data(7);
wkspace = [p_data.folder_path p_data.workspace2_name];
wkspace = [wkspace(1:28) 'Tetragel_Related/' wkspace(29:end)];
load(wkspace)

index = p_data.Radii_data_index;

width_data = particle_data_2.WidthMeasurements(index);
img = width_data.ImgCrop;



figure(1);clf;
imagesc(img);axis square; colormap gray