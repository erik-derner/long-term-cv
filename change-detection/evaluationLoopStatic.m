%% Localization on an evaluation sequence vs an image database, using a static database (no change detection)
% init
clear all;
close all;
clc;

% param
imgdbPathname = ''; % pathname to the annotated image database mat-file that will serve as image database
queryDataPathname = ''; % pathname to the annotated image database mat-file that will serve as a sequence of query images

%% Load mat-files
load(queryDataPathname);
querydb = imgdb;
load(imgdbPathname);

%% Read image database positions
imgdbPositions = zeros(length(imgdb), 2);
for i = 1:length(imgdb)
    imgdbPositions(i,:) = imgdb(i).odom(1:2);
end

querydbPositions = zeros(length(querydb), 2);
for i = 1:length(querydb)
    querydbPositions(i,:) = querydb(i).odom(1:2);
end

%% Plot map of database positions
figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
subplot(2,2,[2 4]);
hold on;
plot(imgdbPositions(:,1), imgdbPositions(:,2), 'k.');
grid on;
xlabel('x [m]'); ylabel('y [m]');
axis equal;

%% Localization loop
hCurrent = [];
hClosest = [];
errs = zeros(length(querydb), 1);
corrRatios = zeros(length(querydb), 1);

for i = 1:length(querydb)
    tic
    
    imgQuery = querydb(i);
    
    % match query image against the database
    [corr, mostSimilarIdx, corrRatio] = imgdbQuery(imgQuery, imgdb);

    % update the map plot
    subplot(2,2,[2 4]);
    
    % delete old positions
    delete(hCurrent);
    delete(hClosest);
    
    % plot the current position
    hCurrent = plot(imgQuery.odom(1), imgQuery.odom(2), 'r+');
    
    % circle the closest match
    hClosest = plot(imgdbPositions(mostSimilarIdx(1), 1), imgdbPositions(mostSimilarIdx(1), 2), 'bo');
    
    errs(i) = norm(imgQuery.odom(1:2) - imgdbPositions(mostSimilarIdx(1), 1:2));
    corrRatios(i) = corrRatio(1);
    
    drawnow;

    % update the current image
    subplot(2,2,1); cla;
    imshow(imgQuery.img);
    title('Current image');
    
    % update the closest match image
    subplot(2,2,3); cla;
    imshow(imgdb(mostSimilarIdx(1)).img);
    title(sprintf('Best imgdb idx=%d, corrRatio=%d%% err=%.2f', mostSimilarIdx(1), round(100*corrRatio(1)), errs(i)));
    toc
    %waitforbuttonpress;
end
