function y = cf_rosenbrock(X)
[~, fun_dim] = size(X);
y = 100.0 * sum(((X(:, 1 : (fun_dim - 1)) .^ 2) - X(:, 2 : fun_dim)) .^ 2, 2) + ...
    sum((X(:, 1 : (fun_dim - 1)) - 1) .^ 2, 2);
end
