function opt_res = CLPSO(cf_params, algo_params)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Comprehensive Learning Particle Swarm Optimizer (i.e., CLPSO).
%
% -------------------
% || INPUT  ||   <---
% -------------------
%   cf_params    <--- struct, parameters for the continuous function optimized
%   algo_params  <--- struct, parameters for the optimization algorithm selected
%
% -------------------
% || OUTPUT ||   --->
% -------------------
%   opt_res      ---> struct, optimization results
%
% -------------------
% ||   REFERENCE   ||
% -------------------
%   1. Liang J J, Qin A K, Suganthan P N, et al.
%       Comprehensive learning particle swarm optimizer for global optimization of multimodal functions.
%       IEEE Transactions on Evolutionary Computation (IEEE TEVC), 2006, 10(3): 281-295.
%       * http://ieeexplore.ieee.org/abstract/document/1637688/ *
%   2. Source Code Published by the Author(s):
%       http://web.mysites.ntu.edu.sg/epnsugan/PublicSite/Shared%20Documents/Codes/2006-IEEE-TEC-CLPSO.zip
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
%% break *reproducibility* for unexpected randomness
RandStream.setGlobalStream(RandStream('mt19937ar', 'Seed', 'shuffle'));

opt_res = struct('opt_y', [], ...      % optimal function value found by the algorithm
    'opt_x', [], ...      % optimal value found by the algorithm
    'fe_runtime', [], ... % total run time of the function evaluations part (i.e., fe)
    'fe_num', [], ...     % total number of function evaluations
    'runtime', []);       % total run time of the algorithm on each trial

runtime_start = tic; % timing

%% initialize the population (i.e., swarm)
% initialize particles (i.e., positions, solutions, X)
X_lb = repmat(cf_params.func_opt_bounds(1), ...
    algo_params.algo_pop_size, 1); % optimization lower bounds
X_ub = repmat(cf_params.func_opt_bounds(2), ...
    algo_params.algo_pop_size, 1); % optimization upper bounds
init_opt_lb = repmat(cf_params.func_init_opt_bounds(1, :), ...
    algo_params.algo_pop_size, 1); % initial optimization lower bounds
init_opt_ub = repmat(cf_params.func_init_opt_bounds(2, :), ...
    algo_params.algo_pop_size, 1); % initial optimization upper bounds
X = init_opt_lb + (init_opt_ub - init_opt_lb) .* ...
    rand(RandStream('mt19937ar', 'Seed', algo_params.algo_init_seed), ...
    cf_params.func_dim, algo_params.algo_pop_size)';
% initialize velocities (i.e., V)
V_ub = 0.2 * (X_ub - X_lb);
V_lb = -V_ub;
V = V_lb + (V_ub - V_lb) .* rand(algo_params.algo_pop_size, cf_params.func_dim);
% initialize function values (i.e., y)
opt_res.fe_num = 0;
fe_runtime_start = tic; % timing for fe
y = feval(str2func(cf_params.func_name), X);
opt_res.fe_runtime = toc(fe_runtime_start);
opt_res.fe_num = opt_res.fe_num + algo_params.algo_pop_size;
% initialize personally best X and y
X_pb = X;
y_pb = y;
% initialize globally best X and y
[opt_res.opt_y, opt_y_ind] = min(y_pb);
opt_res.opt_x = X_pb(opt_y_ind, :);
% initialize the learn probability and learned exemplar for each particle
learn_prob = 0.05 + 0.45 * ...
    (exp(10 * (((1 : algo_params.algo_pop_size) - 1) / (algo_params.algo_pop_size - 1))) - 1) / (exp(10) - 1);
learn_X_pb = X_pb;
refreshing_gaps = zeros(1, algo_params.algo_pop_size);

%% iteratively update the population
while opt_res.fe_num < algo_params.algo_fe_max % online update
    w = algo_params.algo_weights(fix(opt_res.fe_num / algo_params.algo_pop_size)); % inertia weight
    for pop_ind = 1 : algo_params.algo_pop_size
        % allow the particle to learn from the exemplar until the particle
        % stops improving for a certain number of generations
        if refreshing_gaps(pop_ind) >= algo_params.algo_refreshing_gap
            refreshing_gaps(pop_ind) = 0;
            for fd_ind = 1 : cf_params.func_dim
                if rand < learn_prob(pop_ind)
                    learn_aorb = randperm(algo_params.algo_pop_size, 2); % tournament selection
                    if y_pb(learn_aorb(2)) < y_pb(learn_aorb(1))
                        learn_X_pb(pop_ind, fd_ind) = X_pb(learn_aorb(2), fd_ind);
                    else
                        learn_X_pb(pop_ind, fd_ind) = X_pb(learn_aorb(1), fd_ind);
                    end
                else
                    learn_X_pb(pop_ind, fd_ind) = X_pb(pop_ind, fd_ind);
                end
            end
        end
        % update and limit V
        V(pop_ind, :) = w * V(pop_ind, :) + algo_params.algo_learning_rate * ...
            rand(1, cf_params.func_dim) .* (learn_X_pb(pop_ind, :) - X(pop_ind, :));
        V(pop_ind, :) = min(V_ub(pop_ind, :), max(V_lb(pop_ind, :), V(pop_ind, :)));
        % update X
        X(pop_ind, :) = X(pop_ind, :) + V(pop_ind, :);
        % update personally and globally best X and y
        if all(X(pop_ind, :) >= X_lb(1, :)) && all(X(pop_ind, :) <= X_ub(1, :))
            fe_runtime_start = tic;
            y(pop_ind) = feval(str2func(cf_params.func_name), X(pop_ind, :));
            opt_res.fe_runtime = opt_res.fe_runtime + toc(fe_runtime_start);
            opt_res.fe_num = opt_res.fe_num + 1;
            if y(pop_ind) < y_pb(pop_ind)
                X_pb(pop_ind, :) = X(pop_ind, :);
                y_pb(pop_ind) = y(pop_ind);
                refreshing_gaps(pop_ind) = 0;
                if y_pb(pop_ind) < opt_res.opt_y % update globally best X and y
                    opt_res.opt_y = y_pb(pop_ind);
                    opt_res.opt_x = X_pb(pop_ind, :);
                end
            else
                refreshing_gaps(pop_ind) = refreshing_gaps(pop_ind) + 1;
            end
        end
    end
end

%% timing
opt_res.runtime = toc(runtime_start);
end
