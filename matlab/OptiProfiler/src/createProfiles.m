function createProfiles(solvers, labels, problem_names, feature_name)
    %CREATEPROFILES plots performance profiles and data profiles.

    % TODO: the current script version does not support options, only supports "simple" features.

    % Set number of pools to be the same as the number of cores.

    profile_options = struct(ProfileOptionKey.N_JOBS.value, 1);
    % profile_options = struct(ProfileOptionKey.N_JOBS.value, feature('numcores'));

    % Build feature.
    % TODO: now we first use "simple" default feature.
    feature = Feature(feature_name);

    % Solve all the problems.
    max_eval_factor = 500;
    [fun_values, maxcv_values, fun_inits, maxcv_inits, n_evals, problem_names, problem_dimensions] = solveAll(problem_names, solvers, feature, max_eval_factor, profile_options);

    % Compute the merit values.
    merit_values = computeMeritValues(fun_values, maxcv_values);
    merit_inits = computeMeritValues(fun_inits, maxcv_inits);

    % Determine the least merit value for each problem.
    merit_min = min(min(min(merit_values, [], 4, 'omitnan'), [], 3, 'omitnan'), [], 2, 'omitnan');
    if ismember(feature_name, {FeatureName.NOISY.value, FeatureName.TOUGH.value, FeatureName.TRUNCATED.value})
        feature_plain = Feature(FeatureName.PLAIN.value);
        [fun_values_plain, maxcv_values_plain] = solveAll(problem_names, solvers, feature_plain, max_eval_factor, profile_options);
        merit_values_plain = computeMeritValues(fun_values_plain, maxcv_values_plain);
        merit_min_plain = min(min(min(merit_values_plain, [], 4, 'omitnan'), [], 3, 'omitnan'), [], 2, 'omitnan');
        merit_min = min(merit_min, merit_min_plain, 'omitnan');
    end

    [n_problems, n_solvers, n_runs, max_eval] = size(merit_values);
    tolerances = 10.^(-1:-1:-10);
    for i_profile = 1:10
        tolerance = tolerances(i_profile);

        work = NaN(n_problems, n_solvers, n_runs);
        for i_problem = 1:n_problems
            if isfinite(merit_min(i_problem))
                threshold = max(tolerance * merit_inits(i_problem) + (1 - tolerance) * merit_min(i_problem), merit_min(i_problem));
            else
                threshold = -Inf;
            end
            for i_solver = 1:n_solvers
                for i_run = 1:n_runs
                    if min(merit_values(i_problem, i_solver, i_run, :), [], 'omitnan') <= threshold
                        work(i_problem, i_solver, i_run) = find(merit_values(i_problem, i_solver, i_run, :) <= threshold, 1, 'first');
                    end
                end
            end
        end

        % Calculate the x-axes of the performance and data profiles.
        denominator_perf = @(i_problem, i_run) min(work(i_problem, :, i_run), [], 'omitnan');
        [x_perf, perf_ratio_max, sort_perf] = x_profile(work, denominator_perf, 2^(1e-6));
        denominator_data = @(i_problem, i_run) problem_dimensions(i_problem) + 1;
        [x_data, data_ratio_max, sort_data] = x_profile(work, denominator_data, 1e-6);
        y_perf = y_profile(sort_perf, n_problems, n_runs);
        y_data = y_profile(sort_data, n_problems, n_runs);

        % Plot the performance profiles.
        tolerance_label = ['$\tau = 10^{', int2str(log10(tolerance)), '}$'];
        [fig, ax] = drawProfile(x_perf, y_perf, perf_ratio_max, labels, 'Performance ratio', ['Performance profiles (', tolerance_label, ')']);
        set(ax, 'TickLabelInterpreter', 'latex');
        
        % Plot the data profiles.
        [fig, ax] = drawProfile(x_data, y_data, data_ratio_max, labels, 'Number of simplex gradient', ['Data profiles (', tolerance_label, ')']);
        set(ax, 'TickLabelInterpreter', 'latex');

    end


end


function merit_values = computeMeritValues(fun_values, maxcv_values)
    is_nearly_feasible = maxcv_values <= 1e-12;
    is_very_infeasible = maxcv_values >= 1e-6;
    is_undecided = ~is_nearly_feasible & ~is_very_infeasible;
    merit_values = NaN(size(fun_values));
    merit_values(is_nearly_feasible) = fun_values(is_nearly_feasible);
    merit_values(is_very_infeasible) = Inf;
    merit_values(is_undecided) = fun_values(is_undecided) + 1e8 * maxcv_values(is_undecided);
end