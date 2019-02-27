function imgdb = imgdbRGB2Gray(imgdb)
%IMGDBRGB2GRAY Convert RGB images to grayscale images
% Input:
%  imgdb - [1 x N struct] image database with RGB images
% Output:
%  imgdb - [1 x N struct] image database with grayscale images

if(length(size(imgdb(1).img)) == 2)
    error('Images are already grayscale.');
    return;
end

for i = 1:length(imgdb)
    imgdb(i).img = rgb2gray(imgdb(i).img);
end

end

