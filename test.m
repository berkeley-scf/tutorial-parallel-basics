function out = test(n, seed)
  res = zeros(100);
  for i = 1:100
    rng(seed);
    y = randn(n,1);
    res(i) = mean(y);
    end
  out = res(1);
end
