%% Record image database
% run 'tbstart' first
% param
Ts = 1; % sampling period (in seconds)
Tend = 10000; % maximal recording duration (in seconds)
showImg = true; % display captured images while recording
imgPath = 'img/'; % directory to store images

%% Preprocessing
if(~isdir(imgPath))
	mkdir(imgPath);
end
if(imgPath(end) ~= '/' && imgPath(end) ~= '\' )
    imgPath = [imgPath '/'];
end

%% Image capturing loop
tstamp = datestr(now, 'yyyy-mm-dd_HH-MM-SS');
N = Tend / Ts; % number of samples
timeAfter = zeros(N, 1);
if(showImg)
    figure(1);
end
% wait for the first input
getColorImage(tb, 10);
getOdometry(tb, 10);
fprintf('Recording started\n');
tic
for i = 1:N
    dbrecord.img = getColorImage(tb); % get RGB image from TurtleBot camera
    curOdom = getOdometry(tb); % get odometry from TurtleBot
    dbrecord.odom = [curOdom.Position(1:2) curOdom.Orientation(1)]; % store only relevant odometry info
    timeAfter = toc; % record time after communication
    if(showImg)
        clf; imshow(dbrecord.img);
        title(sprintf('i = %d', i));
    end
    fprintf('#%d (%.2f/%.2f s) | x=%.2f y=%.2f phi=%.2f | t=%.2f\n', i, i*Ts, Tend, dbrecord.odom(1:3), timeAfter);
    % save record
    save(sprintf('%simgdb_%s_%d.mat', imgPath, tstamp, i), 'dbrecord', 'i', 'tstamp', 'timeAfter', 'Ts');
    while(toc < Ts), end % wait for clock
    tic
end
fprintf('Recording finished\n');
