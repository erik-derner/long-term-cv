function imgAnnotated = imgAnnotate(imgIn)
%IMGANNOTATE Calculate and save descriptors of an image
% Input:
%  imgIn - RGB image | grayscale image | [1 x 1 struct] imgdb entry
% Output:
%  imgAnnotated - [1 x 1 struct] annotated grayscale image

% convert to structure (if needed)
if(~isstruct(imgIn))
    im = imgIn;
    clear imgIn;
    imgIn.img = im;
end

% convert to grayscale (if needed)
if(length(size(imgIn.img)) == 3)
    imgIn.img = rgb2gray(imgIn.img);
end

% annotate using the image database annotation tool
imgAnnotated = imgdbAnnotate(imgIn);

end

