clear
clc

load('hokusamples2.mat')

% noise
sigma = 0.02;

% set RANSAC options
options.epsilon = 1e-6;
options.P_inlier = 1;
options.sigma = 0.02;
options.est_fun = @estimate_circle;
options.man_fun = @error_circle;
options.mode = 'MSAC';
options.Ps = [];
options.notify_iters = [];
options.min_iters = 100;
options.max_iters = 4100;
options.fix_seed = false;
options.reestimate = true;
options.stabilize = false;
options.verbose = false;
options.T_noise_squared = 0.01;

% here we set theradius of the circle that we want to detect
radii = 0.8/2-0.01;
options.parameters.radius = radii;

for i=1:length(hokuyoSamples)

X = [hokuyoSamples(i).x_pts;hokuyoSamples(i).y_pts];
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% RANSAC
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% run RANSAC
fail = true;
while fail
    fail = false;
    try
        [results, options] = RANSAC(X, options);
    catch
        fail = true;
    end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Results Visualization 1er match
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
figure;
hold on
plot(X(1,:), X(2, :), '.r');
plot(X(1,results.CS), X(2, results.CS), 'sg');
xlabel('x');
ylabel('y');
axis equal tight
grid on

phi = linspace(-pi,pi,128);

x_c = results.Theta(1) + radii*cos(phi);
y_c = results.Theta(2) + radii*sin(phi);
plot([x_c x_c(1)], [y_c y_c(1)], 'g', 'LineWidth', 2)

mx = mean(X(1,results.CS));
my = mean(X(2,results.CS));
plot(mx, my, '*m');

dist_origin_center = sqrt((results.Theta(1))^2+(results.Theta(2))^2);
dist_origin_mean = sqrt((mx)^2+(my)^2);

if dist_origin_center > dist_origin_mean
    bask = 1;
else
    bask = 0;
end

title(['nb inliers: ' num2str(sum(results.CS)) ' basket: ' num2str(bask)])
end
