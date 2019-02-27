%% Continuous localization of images from the camera against the image database
% run 'tbstart' before
% init
close all;
clc;

% param
imgdbPathname = ''; % pathname to the annotated image database mat-file

%% Load image database
load(imgdbPathname);

%% Read image database positions
positions = zeros(length(imgdb), 2);
for i = 1:length(imgdb)
    positions(i,:) = imgdb(i).odom(1:2);
end

%% Plot map of database positions
figure('Units', 'Normalized', 'OuterPosition', [0.1 0.1 0.8 0.8]);
subplot(2,2,[2 4]);
hold on;
plot(positions(:,1), positions(:,2), 'k.');
grid on;
xlabel('x [m]'); ylabel('y [m]');
% inflate the tight plot limits by 10 %
axis tight;
xl = xlim(); 
yl = ylim();
xld = xl(2) - xl(1); 
yld = yl(2) - yl(1);
xlim([xl(1) - xld/10, xl(2) + xld/10]); 
ylim([yl(1) - yld/10, yl(2) + yld/10]);

%% Localization loop
% wait for the first input
getColorImage(tb, 10);
getOdometry(tb, 10);
hCurrent = [];
hClosest = [];

% infinite loop
while(true)
    tic
    % read data from TurtleBot
    imgQuery.img = rgb2gray(getColorImage(tb)); % get image from TurtleBot camera
    curOdom = getOdometry(tb); % get odometry from TurtleBot
    imgQuery.odom = [curOdom.Position(1:2) curOdom.Orientation(1)]; % store only relevant odometry info

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
    hClosest = plot(positions(mostSimilarIdx(1), 1), positions(mostSimilarIdx(1), 2), 'bo');
    
    drawnow;

    % update the current image
    subplot(2,2,1); cla;
    imshow(imgQuery.img);
    title('Current image');
    
    % update the closest match image
    subplot(2,2,3); cla;
    imshow(imgdb(mostSimilarIdx(1)).img);
    title(sprintf('Closest database image idx=%d, corrRatio=%d%%', mostSimilarIdx(1), round(100*corrRatio(1))));
    toc
end
