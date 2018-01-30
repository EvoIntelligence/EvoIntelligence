function demo_for_CLPSO(func_name, func_dim, func_opt_bounds, func_init_opt_bounds, algo_fe_max, algo_pop_size)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Demo for CLPSO.
%
% -------------------
% ||     DEMO      ||
% -------------------
%   >> demo_for_CLPSO('cf_sphere', 10, [-100 * ones(1, 10); +100 * ones(1, 10)], [-100 * ones(1, 10); +50 * ones(1, 10)], 30000, 10);
%   >> demo_for_CLPSO('cf_sphere', 30, [-100 * ones(1, 30); +100 * ones(1, 30)], [-100 * ones(1, 30); +50 * ones(1, 30)], 200000, 40);
%   >> demo_for_CLPSO('cf_rosenbrock', 10, [-2.048 * ones(1, 10); +2.048 * ones(1, 10)], [-2.048 * ones(1, 10); +2.048 * ones(1, 10)], 30000, 10);
%   >> demo_for_CLPSO('cf_rosenbrock', 30, [-2.048 * ones(1, 30); +2.048 * ones(1, 30)], [-2.048 * ones(1, 30); +2.048 * ones(1, 30)], 200000, 40);
%   >> demo_for_CLPSO('cf_griewank', 10, [-600 * ones(1, 10); +600 * ones(1, 10)], [-600 * ones(1, 10); +200 * ones(1, 10)], 30000, 10);
%   >> demo_for_CLPSO('cf_griewank', 30, [-600 * ones(1, 30); +600 * ones(1, 30)], [-600 * ones(1, 30); +200 * ones(1, 30)], 200000, 40);
%   >> demo_for_CLPSO('cf_rastrigin', 10, [-5.12 * ones(1, 10); +5.12 * ones(1, 10)], [-5.12 * ones(1, 10); +2.0 * ones(1, 10)], 30000, 10);
%   >> demo_for_CLPSO('cf_rastrigin', 30, [-5.12 * ones(1, 30); +5.12 * ones(1, 30)], [-5.12 * ones(1, 30); +2.0 * ones(1, 30)], 200000, 40);
%
%   >> demo_for_CLPSO('cf_schwefel12', 10000, [-10 * ones(1, 10000); +10 * ones(1, 10000)], [-10 * ones(1, 10000); +10 * ones(1, 10000)], 500, 100);
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% %% Clear the Working Environment
% clear;
% clc;

%% Set Basic Properties for the Continuous Optimization Function
%     func_name = 'cf_sphere'; % function name
func_opt_obj = 'min';    % optimization objective (min vs. max)
%     func_dim = 10;           % function dimension
%     func_opt_bounds = [-100 * ones(1, func_dim); ... % optimization lower bounds
%                        +100 * ones(1, func_dim)];    % optimization upper bounds
%     func_init_opt_bounds = [-100 * ones(1, func_dim); ... % initial optimization lower bounds
%                              +50 * ones(1, func_dim)];    % initial optimization upper bounds
func_opt_x = zeros(1, func_dim); % optimal value (x*)
func_opt_y = 0;                  % optimal function value (y*)

cf_params = struct('func_name', func_name, ...
    'func_opt_obj', func_opt_obj, ...
    'func_dim', func_dim, ...
    'func_opt_bounds', func_opt_bounds, ...
    'func_init_opt_bounds', func_init_opt_bounds, ...
    'func_opt_x', func_opt_x, ...
    'func_opt_y', func_opt_y);

%% Set Basic Parameters for All Trials
trial_num = 30; % total number of trials
trial_is_logging = true; % flag to print the log during optimization
% For *reproducibility*, set the random seed to initialize the population for each trial.
%   It means that when plotting the convergence curve figure, at least the same
%   starting point could be obtained for different algorithms.
% set a base for all random seeds to initialize the population on different trials
trial_init_seed_base = 20180201;
% trial_init_seed_base = today; % a recommended way (*just a matter of taste*)
% set random seeds to initialize the population for different trials
trial_init_seeds = trial_init_seed_base + (2 * (1 : trial_num));

trial_params = struct('trial_num', trial_num, ...
    'trial_is_logging', trial_is_logging, ...
    'trial_init_seed_base', trial_init_seed_base, ...
    'trial_init_seeds', trial_init_seeds);

%% Set Basic Parameters for the Optimization Algorithm Selected
algo_name = 'CLPSO';  % algorithm name
%     algo_fe_max = 30000;  % maximum of function evaluations (i.e., fe)
%     algo_pop_size = 10;   % population size
algo_iter_max = ceil(algo_fe_max / algo_pop_size); % maximum of iterations
algo_weight_bounds = [0.9, 0.4]; % inertia weight linearly decreased during optimization
algo_weights = linspace(algo_weight_bounds(1), algo_weight_bounds(2), algo_iter_max);
algo_refreshing_gap = 7;         % *m*
algo_learning_rate = 1.49445;    % *c*
algo_init_seed = [];  % random seed to initialize the population for a given trial

algo_params = struct('algo_name', algo_name, ...
    'algo_fe_max', algo_fe_max, ...
    'algo_pop_size', algo_pop_size, ...
    'algo_iter_max', algo_iter_max, ...
    'algo_weight_bounds', algo_weight_bounds, ...
    'algo_weights', algo_weights, ...
    'algo_refreshing_gap', algo_refreshing_gap, ...
    'algo_learning_rate', algo_learning_rate, ...
    'algo_init_seed', algo_init_seed);

%% Run the Optimization Algorithm Based on the Above Configurations
opt_res = run_algo(cf_params, trial_params, algo_params); iscell(opt_res);

%% Save the Optimization Results Persistently into a File in Form of *mat*
if exist(algo_params.algo_name) ~= 7 % when dir (*7*) does not exist
    mkdir(algo_params.algo_name);
end
save_filename = sprintf('./%s/%s-%d-%s-%d.mat', algo_params.algo_name, ...
    cf_params.func_name, cf_params.func_dim, ...
    algo_params.algo_name, algo_params.algo_pop_size);
save(save_filename, 'cf_params', 'trial_params', 'algo_params', 'opt_res');
end
