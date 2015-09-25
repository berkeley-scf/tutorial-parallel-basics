## @knitr matlab-parfor

nslots = 4; # to set manually
mypool = parpool(nslots) 
% parpool open local nslots # alternative

n = 3000;
nIts = 500;
c = zeros(n, nIts);
parfor i = 1:nIts
     c(:,i) = eig(rand(n)); 
end

delete(mypool)

% delete(gcp) works if you forget to name your pool by assigning the output of parpool to a variable


## @knitr matlab-batch

feature('numThreads', 1); 
ncores = 4;
pool = parpool(ncores); 
% assume you have test.m with a function, test, taking two inputs 
% (n and seed) and returning 1 output
n = 10000000;
job = cell(1,6); 
job{1} = parfeval(pool, @test, 1, n, 1);  
job{2} = parfeval(pool, @test, 1, n, 2);  
job{3} = parfeval(pool, @test, 1, n, 3);  
job{4} = parfeval(pool, @test, 1, n, 4);  
job{5} = parfeval(pool, @test, 1, n, 5);  
job{6} = parfeval(pool, @test, 1, n, 6);  

% wait for outputs, in order
output = cell(1, 6);
for idx = 1:6
  output{idx} = fetchOutputs(job{idx});
end 

% alternative way to loop over jobs:
for idx = 1:6
  jobs(idx) = parfeval(pool, @test, 1, n, idx); 
end 

% wait for outputs as they finish
output = cell(1, 6);
for idx = 1:6
  [completedIdx, value] = fetchNext(jobs);
  output{completedIdx} = value;
end 

delete(pool);

## @knitr matlab-batch-thread 

ncores = 8;
n = 5000;
nJobs = 4;
pool = parpool(nJobs);
% pass number of threads as number of slots divided by number of jobs
% testThread function should then do: 
% feature('numThreads', nThreads);
% where nThreads is the name of the relevant argument to testThread
jobt1 = parfeval(pool, @testThread, 1, n, 1, nCores/nJobs);
jobt2 = parfeval(pool, @testThread, 1, n, 2, nCores/nJobs);
jobt3 = parfeval(pool, @testThread, 1, n, 3, nCores/nJobs);
jobt4 = parfeval(pool, @testThread, 1, n, 4, nCores/nJobs);

output1 = fetchOutputs(jobt1);
output2 = fetchOutputs(jobt2);
output3 = fetchOutputs(jobt3);
output4 = fetchOutputs(jobt4);

delete(pool);
