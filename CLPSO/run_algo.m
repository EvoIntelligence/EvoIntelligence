function opt_res = run_algo(cf_params, trial_params, algo_params)
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
% Main Program for Running a Population-based Optimization/Evolutionary Algorithm.
%
% -------------------
% || INPUT  ||   <---
% -------------------
%   cf_params    <--- struct, parameters for the continuous function optimized
%   trial_params <--- struct, parameters for all trials
%   algo_params  <--- struct, parameters for the optimization algorithm selected
%
% -------------------
% || OUTPUT ||   --->
% -------------------
%   opt_res      ---> struct, optimization results
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% %
%%
opt_res = cell(1, trial_params.trial_num);

opt_ys = zeros(1, trial_params.trial_num);
runtimes = zeros(1, trial_params.trial_num);
fe_runtimes = zeros(1, trial_params.trial_num);
fe_num = zeros(1, trial_params.trial_num);

%%
fprintf(sprintf('Function Name: %s - Number of Trials: %d - Algorithm Name: %s\n', ...
    cf_params.func_name, trial_params.trial_num, algo_params.algo_name));
fprintf(sprintf('Function Dimension: %d + Population Size: %d\n', ...
    cf_params.func_dim, algo_params.algo_pop_size));
logging_info = ['trial %2d: opt_y = %+7.4e || runtime = %7.2e || fe_runtime = %7.2e || fe_num = %d <- '...
    'opt_x [%+7.2e ... %+7.2e]\n'];

%%
for trail_ind = 1 : trial_params.trial_num
    algo_params.algo_init_seed = trial_params.trial_init_seeds(trail_ind);
    
    opt_res{trail_ind} = feval(str2func(algo_params.algo_name), cf_params, algo_params);
    
    opt_ys(trail_ind) = opt_res{trail_ind}.opt_y;
    runtimes(trail_ind) = opt_res{trail_ind}.runtime;
    fe_runtimes(trail_ind) = opt_res{trail_ind}.fe_runtime;
    fe_num(trail_ind) = opt_res{trail_ind}.fe_num;
    
    if trial_params.trial_is_logging
        fprintf(logging_info, trail_ind, ...
            opt_res{trail_ind}.opt_y, opt_res{trail_ind}.runtime, ...
            opt_res{trail_ind}.fe_runtime, opt_res{trail_ind}.fe_num, ...
            opt_res{trail_ind}.opt_x(1), opt_res{trail_ind}.opt_x(end));
    end
end

%%
fprintf('******* Summary *******:\n');
fe_ratio = fe_runtimes / runtimes * 100;
fprintf(sprintf('Function Name: %s + Number of Trials: %d + Algorithm Name: %s\n', ...
    cf_params.func_name, trial_params.trial_num, algo_params.algo_name));
fprintf(sprintf('Function Dimension: %d + Population Size: %d\n', ...
    cf_params.func_dim, algo_params.algo_pop_size));
fprintf('   opt_y      --- Mean & Std: %7.2e  &  %7.2e\n', mean(opt_ys), std(opt_ys));
fprintf('   runtime    --- Mean & Std: %7.2e  &  %7.2e\n', mean(runtimes), std(runtimes));
fprintf('   fe_runtime --- Mean & Std: %7.2e  &  %7.2e\n', mean(fe_runtimes), std(fe_runtimes));
fprintf('   fe_ratio   --- Mean & Std: %7.2f%%  &  %7.2f%%\n', mean(fe_ratio), std(fe_ratio));
fprintf('   fe_num     --- Mean & Std: %7.2e  &  %7.2e\n', mean(fe_num), std(fe_num));
end
