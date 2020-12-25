function [stack, particle_data_2, contrast_low, contrast_high, sample_type] = load_workspace1()

loadName = uigetfile; % requires user to move directory to specified folder
load(loadName,'image_name','particle_data','contrast_low','contrast_high','sample_type');

% if ~strcmp(loadName(1:10),'Workspace_')
%     error('The only accepted input is workspace generated from Virus Particle Analysis I (Diameter Analysis)');
% end

% Version 2 checking system to avoid Windows abbreviation problem
if exist('particle_data','var') == 0
    error('The only accepted input is workspace generated from Virus Particle Analysis I (Diameter Analysis)');
end

% Convert particle_data to particle_data_2
particle_data_2 = make_particle_data_2(particle_data);

% Load stack
info = imfinfo(image_name);
sizeX = info(1).Width;
sizeY = info(1).Height;
sizeZ = size(info,1);

stack = zeros(sizeX,sizeY,sizeZ);

for z = 1:sizeZ
    stack(:,:,z) = imread(image_name, z);
end