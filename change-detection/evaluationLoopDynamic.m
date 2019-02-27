%% Localization on an evaluation sequence vs an image database, updating the image database with the detected changes
% init
clear all;
close all;
clc;

rng(1);

% param
imgdbPathname = ''; % pathname to the annotated image database mat-file that will serve as image database
queryDataPathname = ''; % pathname to the annotated image database mat-file that will serve as a sequence of query images
saveName = ''; % pathname where to save the updated image database mat-file
thr = 0.5; % change detection threshold

%% Load mat-files
load(queryDataPathname);
%querydb = imgdb;
querydb = imgdbAnnotate(imgdb);
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
queryPointsPaper = zeros(length(querydb), 2);
dbCorrespondencesPaper = zeros(length(querydb), 2);
dbPointsPaper = imgdbPositions;

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
    
	% load imgdb and query data
    queryPointsPaper(i,:) = imgQuery.odom(1:2);
    dbCorrespondencesPaper(i,:) = imgdbPositions(mostSimilarIdx(1), 1:2);

	imgdbImage = imgdb(mostSimilarIdx(1)).img;
	queryImage = imgQuery.img;

	imgdbPoints = imgdb(mostSimilarIdx(1)).points;
	queryPoints = imgQuery.points;

	imgdbDescriptors = imgdb(mostSimilarIdx(1)).descriptors;
	queryDescriptors = imgQuery.descriptors;

	imgdbLocations = imgdbPoints.Location;
	queryLocations = queryPoints.Location;

	% match features
	[indexPairs, matchMetric] = matchFeatures(imgdbDescriptors, queryDescriptors);

	imgdbMatchLocations = imgdbPoints(indexPairs(:,1)).Location;
	queryMatchLocations = queryPoints(indexPairs(:,2)).Location;

	% transform interest points, detect changes and update image database
	if(size(imgdbMatchLocations, 1) > 10 && size(queryMatchLocations, 1) > 10)

		[tform, imgdbInliers, queryInliers] = estimateGeometricTransform(imgdbMatchLocations, queryMatchLocations, 'projective');

		clear imgdbLocationsTformed
		[imgdbLocationsTformed(:,1), imgdbLocationsTformed(:,2)] = transformPointsForward(tform, imgdbLocations(:,1), imgdbLocations(:,2));

		imgdbSURFPointsTformed = imgdbPoints;
		imgdbLocationsTformed(imgdbLocationsTformed <= 0) = 1e10;
		imgdbSURFPointsTformed.Location = imgdbLocationsTformed;

		% calculate SURF descriptors for transformed features
		[imgdbDescriptorsTformed, imgdbValidSURFPointsTformed] = extractFeatures(queryImage, imgdbSURFPointsTformed);

		% determine which descriptors (interest points) are missing in the transformed image
		existingPointsPoints = [];
		for j = 1:length(imgdbSURFPointsTformed)
			comp = (abs(imgdbLocationsTformed(j,:) - imgdbValidSURFPointsTformed.Location) < 1e-4);
			pointFound = any(comp(:,1) & comp(:,2));
			if(pointFound)
				existingPoints = [existingPoints j];
			end
		end

		% calculate descriptor distances
		dists = sqrt(sum((imgdbDescriptors(existingPoints,:) - imgdbDescriptorsTformed) .^ 2, 2));

		imgdbValidLocations = imgdbLocations(existingPoints,:);
		imgdbValidLocationsTformed = imgdbLocationsTformed(existingPoints,:);

		% update image database
		imgdb(mostSimilarIdx(1)).points = imgdb(mostSimilarIdx(1)).points(existingPoints);
		imgdb(mostSimilarIdx(1)).descriptors = imgdb(mostSimilarIdx(1)).descriptors(existingPoints,:);

		imgdb(mostSimilarIdx(1)).points = imgdb(mostSimilarIdx(1)).points(dists <= thr);
		imgdb(mostSimilarIdx(1)).descriptors = imgdb(mostSimilarIdx(1)).descriptors(dists <= thr,:);

	end

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
end

% Print results and save them to a mat-file
fprintf('mean(errs) = %f, mean(corrRatios) = %f\n', mean(errs), mean(corrRatios));
fprintf('Finished!\n');
save(saveName, 'errs', 'corrRatios', 'queryPointsPaper', 'dbCorrespondencesPaper', 'dbPointsPaper');
