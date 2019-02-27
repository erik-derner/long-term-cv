%% Create a TurtleBot structure with correctly mapped topics
% Before running this script, run on the TurtleBot laptop:
% > roscore
% > roslaunch turtlebot_bringup minimal.launch
% > roslaunch openni_launch openni.launch (or other for your sensor)

% param
tb_ip = 'localhost'; % turtlebot IP address on the local network

%% assign turtlebot
tb = turtlebot(tb_ip);

%% remap topics
origActiveState = tb.ColorImage.Active;
tb.ColorImage.Active = 0;
tb.ColorImage.TopicName = '/camera/rgb/image_rect_color/compressed';
tb.ColorImage.Active = origActiveState;

