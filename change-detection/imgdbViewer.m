%% View image database
% Click in the left half of the image to go back, right to go forward
% init
clear imgdb

% param
imgdbPathname = ''; % path and filename of the image database to be viewed

%% Display image
load(imgdbPathname);
N = length(imgdb);
i = 1;
while(true)
    figure(1); clf; 
    imshow(imgdb(i).img);
    title(sprintf('i = %d/%d', i, N));
    [x, ~] = ginput(1);
    if(x > size(imgdb(i).img, 2) / 2)
        i = min(i + 1, N);
    else
        i = max(i - 1, 1);
    end
end
