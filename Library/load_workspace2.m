function [stack, particle_data_2, contrast_low, contrast_high, accepted_particle_indices, p, lineLength2] = load_workspace2()

loadName = uigetfile; % requires user to move directory to specified folder

if ~strcmp(loadName(1:11),'Workspace2_')
    error('The only accepted input is workspace generated from Virus Particle Analysis II (Width Analysis)');
end
    
load(loadName,'particle_data_2','contrast_low','contrast_high', 'accepted_particle_indices','p','lineLength2');

fname = particle_data_2.StackName;

% Load stack
info = imfinfo(fname);
sizeX = info(1).Width;
sizeY = info(1).Height;
sizeZ = size(info,1);

stack = zeros(sizeX,sizeY,sizeZ);

for z = 1:sizeZ
    stack(:,:,z) = imread(fname, z);
end