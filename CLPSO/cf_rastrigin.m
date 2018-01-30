function y = cf_rastrigin(X)
y = sum(X .^ 2 - 10.0 * cos(2.0 * pi * X) + 10, 2);
end
