clear;
clc;

%% Test based on Samples
% Test Case 1
% X = zeros(3, 7); % 0     0     0

% Test Case 2
% X = ones(5, 3); % 3     3     3     3     3

% Test Case 3
% X = -ones(7, 3); % 3     3     3     3     3     3     3

% Test Case 4
% X = [0 0 0 0 0; ...
%      1 1 1 1 1; ...
%      -1 -1 -1 -1 -1; ...
%      1 -1 1 -1 1; ...
%      1 2 3 4 5; ...
%      1 -2 3 -4 5; ...
%      5 4 3 2 0]; % 0     5     5     5    55    55    54

% Run
% y = cf_sphere(X);
% disp(y');

%% Test Based on Run Time
% fun_dims = 10 .^ (0 : 6);
% run_times = 3;
% fprintf(sprintf('fun_dim  : run time\n'));
% for fd_ind = 1 : length(fun_dims)
%     X = ones(100, fun_dims(fd_ind));
%     run_time_start = tic;
%     for run_ind = 1 : run_times
%         y = cf_sphere(X);
%     end
%     run_time = toc(run_time_start) / run_times; % avg
%     fprintf(sprintf('%07.2e : %07.4e\n', fun_dims(fd_ind), run_time));
% end
