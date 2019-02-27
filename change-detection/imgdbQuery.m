function [corr, mostSimilarIdx, corrRatio] = imgdbQuery(imgQuery, imgdb)
%IMGDBQUERY Match a query image against the image database
% Input:
%  imgQuery - RGB image | grayscale image | [1 x 1 struct] imgdb entry |
%             [1 x 1 struct] annotated imgdb entry
%  imgdb - [1 x N struct] database of annotated images
% Output:
%  corr - [N x 1 cell] pairs of corresponding features, where corr{i} 
%         contains an M x 2 array of index pairs; the first column
%         indexes the features in the query image and the second column
%         indexes the features in the database image imgdb(i)
%  mostSimilarIdx - [N x 1] indices of most likely matches in the imgdb, 
%                   sorted by number of correspondences
%  corrRatio - [N x 1] ratio of correspondences, where corrRatio(i) is
%              the number of correspondences between the query image and
%              the database image with index mostSimilarIdx(i) divided by
%              the number of keypoints in that database image

% Validate inputs
if(length(size(imgdb(1).img)) == 3)
    error('imgdb - RGB image database is not supported, convert the image database to grayscale first.');
    return;
elseif(~isfield(imgdb(1), 'descriptors'))
    error('imgdb - no descriptors found, annotate the image database first.');
    return;    
end

% Annotate the query image
imgQueryAnnotated = imgAnnotate(imgQuery);

% Find correspondences between the query image and all database images
% and calculate the correspondence ratio
corr = cell(length(imgdb), 1);
corrRatioSerial = zeros(length(imgdb), 1);
for i = 1:length(imgdb)
    corr{i} = matchFeatures(imgQueryAnnotated.descriptors, imgdb(i).descriptors);
    corrRatioSerial(i) = size(corr{i}, 1) / length(imgdb(i).points);
end

[corrRatio, mostSimilarIdx] = sort(corrRatioSerial, 'descend');

end

