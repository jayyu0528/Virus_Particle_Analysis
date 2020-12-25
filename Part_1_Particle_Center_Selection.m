% Particle Analysis Assistant

% Part 1 - Particle Center Selection (Rough)

% This script prompts user to load an image of post-expansion virions, and
% select individual particles.   Particle center selected in this script is
% rough and will be fine tuned with a downstream script.

% This script needs to be performed on each image separately.

% Output of this script is a Workspace file, to be loaded by the Part 2
% script.

%% Session Parameters

clear;clc;close all;

% Input image file name, sample type, and pixel size
image_name = 'TG_180329_H20Z1A1_cf_640_0.25z_30%laser_Stack_60x(1.5xtube)_two_cmle-3-1.tif';
sample_type = 'TG';

pixel_size_um = 0.1137;

%% Load stack, parameters, data

info = imfinfo(image_name);
sizeX = info(1).Width;
sizeY = info(1).Height;
sizeZ = size(info,1);

stack = zeros(sizeX,sizeY,sizeZ);
for z = 1:sizeZ
    stack(:,:,z) = imread(image_name, z);
end

answer = questdlg('Load saved session?');
switch answer
    case 'Yes'
        loadData = 1;
    case 'No'
        loadData = 0;
    case 'Cancel'
        return
end

if loadData == 0
    % contrast settings
    contrast_low = 100;
    contrast_high = 3500;
    % zoom window length
    zoomLength_1side = 40;
    % analysis axis length
    lineLength_1side = 30;
    % inital frame
    z = 20;
    % initialize data structure
    particle_data = struct('StackName', image_name, 'PixelSize_um', pixel_size_um, ...
        'Measurements', struct('Index', {}, 'Acceptance', {}, 'LineLength', {}, 'Z_plane', {}, ...
        'X_loc', {}, 'Y_loc', {},'Diameter1_um',{}, 'Diameter2_um',{}));
else 
    loadName = uigetfile; % requires user to move directory to specified folder
    load(loadName, 'contrast_low','contrast_high','zoomLength_1side','lineLength_1side','z','particle_data');
end

% figure initializing
fig = figure('units','normalized','outerposition',[0 0 1 1]); clf;

%% Main

while 1
    figure(fig); clf;
    
    %% Global panel plane selection
    
    while 1
        img = stack(:,:,z);
        img_disp = make_contrasted_image(img, contrast_low, contrast_high);
        
        subplot(2,3,[1 4]); cla;
        imagesc(img_disp); colormap gray; axis xy; axis square
        hold on;
        show_dead_zone_on_left_panel(fig, lineLength_1side, sizeX, sizeY, [1 0 0], 0.5);
        show_dead_zone_on_left_panel(fig, zoomLength_1side, sizeX, sizeY, [1 0 0], 0.3);
        xlabel('Avoid particles whose center is inside the outermost (dark red) border','fontsize',12)
        
        display_analyzed_loc(fig, particle_data);
        
        update_panel_title(fig, 1, {'\uparrow : exit and save session'; ...
            '\leftrightarrow : change z-plane';'\downarrow : continue'}, 20)
        
        btn = detect_button_press();
        switch btn
            case 28 % left key
                if (z-1 >= 1) && (z-1 <= sizeZ)
                    z = z-1;
                end
            case 29 % right key
                if (z+1 >= 1) && (z+1 <= sizeZ)
                    z = z+1;
                end
            case 30 % up key -- save workspace and exit
                currTime = clock;
                timestamp = [num2str(currTime(1)*10000+ currTime(2) * 100 + currTime(3)) '-' num2str(currTime(4),'%.2d') '-' num2str(currTime(5),'%.2d')];
                saveName = ['Workspace_' sample_type '_' timestamp];
                save(saveName,'image_name','sample_type','particle_data','pixel_size_um', 'contrast_low','contrast_high','lineLength_1side','zoomLength_1side','z');
                disp(sprintf(['\n==========================================\n' saveName ' has been saved.\n==========================================\n']));
                close(fig);
                return
            case 31 % down key
                break
        end
    end
    
    
    %% Select center
    
    update_panel_title(fig, 1, {' ';'Select region to zoom in';' '}, 20)
    
    while 1
        % From global view
        [x_input,y_input] = ginput(1);
        x_input1 = round(x_input);
        y_input1 = round(y_input);

        
        if (y_input1 - zoomLength_1side > 0) && (y_input1 - zoomLength_1side <=  sizeY) && ...
                (y_input1 + zoomLength_1side > 0) && (y_input1 + zoomLength_1side <=  sizeY) && ...
                (x_input1 - zoomLength_1side > 0) && (x_input1 - zoomLength_1side <=  sizeX) && ...
                (x_input1 + zoomLength_1side > 0) && (x_input1 + zoomLength_1side <=  sizeX)
            break;
        end
        update_panel_title(fig, 1, {'Zoomed square out of image border; select again';'Select region to zoom in';' '}, 20)
    end
    
    % From zoomed view
    img_zoom = img_disp (y_input1 - zoomLength_1side : y_input1 + zoomLength_1side, ...
        x_input1 - zoomLength_1side : x_input1 + zoomLength_1side);
    
    subplot(2,3,[2 5]); cla;
    imagesc(img_zoom); colormap gray; axis xy; axis square
    hold on;
    
    update_panel_title(fig, 1, {' ';' ';' '}, 20)
    update_panel_title(fig, 2, {' ';'select the center of particle';' '}, 20)
    
    while 1
        [x_input,y_input] = ginput(1);
        x_input2 = round(x_input); % convert to global axis
        y_input2 = round(y_input); % convert to global axis
        
        x_center = x_input1 - zoomLength_1side + x_input2 - 1;
        y_center = y_input1 - zoomLength_1side + y_input2 - 1;
        
        if (y_center - lineLength_1side > 0) && (y_center - lineLength_1side <=  sizeY) && ...
                (y_center + lineLength_1side > 0) && (y_center + lineLength_1side <=  sizeY) && ...
                (x_center - lineLength_1side > 0) && (x_center - lineLength_1side <=  sizeX) && ...
                (x_center + lineLength_1side > 0) && (x_center + lineLength_1side <=  sizeX)
            break;
        end
        update_panel_title(fig, 2, {'Analysis square out of image border; select again';'select the center of particle';' '}, 20)
    end
    
    plot(x_input2,y_input2,'*r');
    
    subplot(2,3,[1 4]); plot(x_center,y_center,'*r');
    
    %% Analyze across Z
    
    manual_mode = 0;
    
    while 1
        img = stack(:,:,z);
        % compute border points
        [L1, L2, L1m1, L1m2, L2m1, L2m2] = perform_diameter_analysis(fig, img, contrast_low, contrast_high, x_center, y_center, lineLength_1side, pixel_size_um, particle_data);
        % update panels
        update_panels(fig, img, contrast_low, contrast_high,lineLength_1side, x_center, y_center, particle_data, L1, L2, L1m1, L1m2, L2m1, L2m2, pixel_size_um);
        
        update_panel_title(fig, 2, {'\uparrow : manual adjustment';'\leftrightarrow : change z-plane';'\downarrow : accept';'R : reject'}, 20)
        
        btn = detect_button_press();
        switch btn
            case 28 % left key
                if (z-1 >= 1) && (z-1 <= sizeZ)
                    z = z-1;
                end
            case 29 % right key
                if (z+1 >= 1) && (z+1 <= sizeZ)
                    z = z+1;
                end
            case 30 % up key - manual mode
                manual_mode = 1;
                break
            case 31 % down key
                acceptance = 'Accepted';
                break
            case 114 % R key         
                acceptance = 'Rejected';
                break
        end
    end
    
    % if manual mode selected
    if manual_mode == 1
        while 1
            update_panel_title(fig, 2, {'Arrow key: border to adjust';'A : accept';'R : reject'}, 20)
            btn = detect_button_press();
            switch btn
                case 28 % left key
                    while 1
                        update_panel_title(fig, 2, {'\leftarrow \rightarrow : adjust';'space : done'}, 20)
                        btn = detect_button_press();
                        switch btn
                            case 28 % left key
                                L1m1 = L1m1 - 1;
                            case 29 % right key
                                L1m1 = L1m1 + 1;
                            case 32
                                break;
                        end
                        % update panels
                        update_panels(fig, img, contrast_low, contrast_high,lineLength_1side, x_center, y_center, particle_data, L1, L2, L1m1, L1m2, L2m1, L2m2, pixel_size_um);
                    end
                case 29 % right key
                    while 1
                        update_panel_title(fig, 2, {'\leftarrow \rightarrow : adjust';'space : done'}, 20)
                        btn = detect_button_press();
                        switch btn
                            case 28 % left key
                                L1m2 = L1m2 - 1;
                            case 29 % right key
                                L1m2 = L1m2 + 1;
                            case 32
                                break;
                        end
                        % update panels
                        update_panels(fig, img, contrast_low, contrast_high,lineLength_1side, x_center, y_center, particle_data, L1, L2, L1m1, L1m2, L2m1, L2m2, pixel_size_um);
                    end
                case 30 % up key 
                    while 1
                        update_panel_title(fig, 2, {'\uparrow \downarrow : adjust';'space : done'}, 20)
                        btn = detect_button_press();
                        switch btn
                            case 30 % up key
                                L2m2 = L2m2 + 1;
                            case 31 % down key
                                L2m2 = L2m2 - 1;
                            case 32
                                break;
                        end
                        % update panels
                        update_panels(fig, img, contrast_low, contrast_high,lineLength_1side, x_center, y_center, particle_data, L1, L2, L1m1, L1m2, L2m1, L2m2, pixel_size_um);
                    end
                case 31 % down key
                    while 1
                        update_panel_title(fig, 2, {'\uparrow \downarrow : adjust';'space : done'}, 20)
                        btn = detect_button_press();
                        switch btn
                            case 30 % up key
                                L2m1 = L2m1 + 1;
                            case 31 % down key
                                L2m1 = L2m1 - 1;
                            case 32
                                break;
                        end
                        % update panels
                        update_panels(fig, img, contrast_low, contrast_high,lineLength_1side, x_center, y_center, particle_data, L1, L2, L1m1, L1m2, L2m1, L2m2, pixel_size_um);
                    end
                case 97 % A key
                    acceptance = 'Accepted';
                    break
                case 114 % R key
                    acceptance = 'Rejected';
                    break
            end
        end
    end
    
    %% Record measurement
    
    [~, L1_dia_um] = calculate_diameter(L1m1, L1m2, pixel_size_um);
    [~, L2_dia_um] = calculate_diameter(L2m1, L2m2, pixel_size_um);
    
    if isempty(particle_data.Measurements)
        index = 1;
    else
        % internal invariant check
        if length(particle_data.Measurements) ~= particle_data.Measurements(end).Index
            error('Data structure error: index mismatch')
        end
        index = particle_data.Measurements(end).Index + 1;
    end
    
    particle_data.Measurements(index).Index = index;
    particle_data.Measurements(index).Acceptance = acceptance;
    particle_data.Measurements(index).LineLength = lineLength_1side;
    particle_data.Measurements(index).Z_plane = z;
    particle_data.Measurements(index).X_loc = x_center;
    particle_data.Measurements(index).Y_loc = y_center;
    particle_data.Measurements(index).Diameter1_um = L1_dia_um;
    particle_data.Measurements(index).Diameter2_um = L2_dia_um;
    
end
