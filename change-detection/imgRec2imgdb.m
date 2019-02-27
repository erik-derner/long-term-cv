%% Convert single image recordings, created by imgdbRecord.m, to an image database
% init
clear imgdb

% param
recordingsPath = ''; % path to mat-files with image recordings; include trailing '/'
tstamp = ''; % timestamp of recording
indices = 1:100; % indices of recordings
imgdbPathname = ''; % path and filename where to store the image database mat-file

%% Load images
for i = 1:length(indices)
    load(sprintf('%simgdb_%s_%d.mat', recordingsPath, tstamp, indices(i)));
    imgdb(i) = dbrecord;
end
fprintf('Conversion finished\n');

%% Annotate images
imgdb = imgdbRGB2Gray(imgdb);
imgdb = imgdbAnnotate(imgdb);

%% Save results
save(imgdbPathname, 'imgdb', 'Ts');
