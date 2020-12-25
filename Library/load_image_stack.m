function [stack, sizeX, sizeY, sizeZ] = load_image_stack(fname)

% Load stack
info = imfinfo(fname);
sizeX = info(1).Width;
sizeY = info(1).Height;
sizeZ = size(info,1);

stack = zeros(sizeX,sizeY,sizeZ);

for z = 1:sizeZ
    stack(:,:,z) = imread(fname, z);
end