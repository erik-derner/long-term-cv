function imgdb = imgdbAnnotate(imgdb, numStrongest)
%IMGDBANNOTATE Calculate and save descriptors of database images
% Input:
%  imgdb - [1 x N struct] image database with grayscale images
%  numStrongest - (optional) [1 x 1] number of strongest features to be
%                 used (default = 300)
% Output:
%  imgdb - [1 x N struct] annotated image database

% Check if image is grayscale
if(length(size(imgdb(1).img)) == 3)
    error('RGB images are not supported, convert the images to grayscale first.');
end

% Default number of strongest features
if(nargin < 2)
    numStrongest = 300;
end

% Annotate all images in imgdb
for i = 1:length(imgdb)
    detectedPoints = detectSURFFeatures(imgdb(i).img);
    detectedPoints = selectStrongest(detectedPoints, numStrongest);
    [imgdb(i).descriptors, imgdb(i).points] = extractFeatures(imgdb(i).img, detectedPoints);
    fprintf('Annotated image %d/%d\n', i, length(imgdb))
end
fprintf('Annotation done\n');

end

