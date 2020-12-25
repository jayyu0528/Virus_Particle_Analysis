function stack = load_stack(StackName)

% Load stack
info = imfinfo(StackName);
sizeX = info(1).Width;
sizeY = info(1).Height;
sizeZ = size(info,1);

stack = zeros(sizeX,sizeY,sizeZ);
for z = 1:sizeZ
    stack(:,:,z) = imread(StackName, z);
end