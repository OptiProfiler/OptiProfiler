function [x, fval] = lincoa_test(fun, x0, xl, xu, aub, bub, aeq, beq, cub, ceq, max_eval)

    problem = struct();
    problem.objective = fun;
    problem.x0 = x0;
    problem.lb = xl;
    problem.ub = xu;
    problem.options.maxfun = max_eval;
    problem.solver = 'lincoa';

    [x, fval] = pdfo(problem);

end