%% Plot trajectory
% param
imgdbPathname = ''; % path and filename of the image database to be viewed
load(imgdbPathname);
N = length(imgdb);
indices = 1:N;

%% Collect locations
locations = zeros(N, 2);
distances = zeros(N-1, 1);
for i = 1:length(indices)
    locations(i,:) = imgdb(indices(i)).odom(1:2);
    if i > 1
        distances(i-1) = norm(locations(i,:) - locations(i-1,:));
    end
end

%% Plot
set(0,'DefaultAxesFontName','times');
set(0,'DefaultTextFontName','times');
set(0,'DefaultAxesFontSize',16);
set(0,'DefaultTextFontSize',16);

figure(9); clf;
plot(locations(:,1), locations(:,2), 'k.', 'MarkerSize', 10);
grid on; axis equal;
xlim([-1 9.5]);
%ylim([-3 0.5]);
xlabel('$x$ [m]', 'Interpreter', 'latex');
ylabel('$y$ [m]', 'Interpreter', 'latex');

sum(distances)