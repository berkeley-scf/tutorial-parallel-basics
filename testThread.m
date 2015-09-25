function out = testThread(n, seed, nThreads)
feature('numThreads', nThreads);
rng(seed);

mat = normrnd(0, 1, n, n);

for i = 1:100
  sigma = mat'*mat;
  L = chol(sigma);
end

out = L(1,1);

end
