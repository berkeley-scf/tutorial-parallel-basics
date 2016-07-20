## @knitr R-linalg

# install.packages('RhpcBLASctl') # not installed by default on BCE
library(RhpcBLASctl)
x <- matrix(rnorm(5000^2), 5000)

blas_set_num_threads(4)
system.time({
   x <- crossprod(x)
   U <- chol(x)
})

#   user  system elapsed 
# 14.104   5.403   6.752 

blas_set_num_threads(1)
system.time({
   x <- crossprod(x)
   U <- chol(x)
})

#   user  system elapsed 
# 12.393   0.055  12.344 

## @knitr foreach

library(doParallel)  # uses parallel package, a core R package
# library(multicore); library(doMC) # alternative to parallel/doParallel
# library(Rmpi); library(doMPI) # to use Rmpi as the back-end


taskFun <- function(){
	mn <- mean(rnorm(10000000))
	return(mn)
}
nCores <- 4  # to set manually
registerDoParallel(nCores) 
# registerDoMC(nCores) # alternative to registerDoParallel
# cl <- startMPIcluster(nCores); registerDoMPI(cl) # when using Rmpi as the back-end

out <- foreach(i = 1:30, .combine = c) %dopar% {
	cat('Starting ', i, 'th job.\n', sep = '')
	outSub <- taskFun()
	cat('Finishing ', i, 'th job.\n', sep = '')
	outSub # this will become part of the out object
}
print(out)

## @knitr parallel_lsApply

library(parallel)
nCores <- 4  # to set manually 
cl <- makeCluster(nCores) 

nSims <- 60
input <- seq_len(nSims) # same as 1:nSims but more robust
taskFun <- function(i){
	mn <- mean(rnorm(1000000))
	return(mn)
}
# clusterExport(cl, c('x', 'y')) # if the processes need objects (x and y, here) from the master's workspace
system.time(
	res <- parSapply(cl, input, taskFun)
)
system.time(
	res2 <- sapply(input, taskFun)
)
res <- parLapply(cl, input, taskFun)


## @knitr mclapply

system.time(
	res <- mclapply(input, taskFun, mc.cores = nCores) 
)


## @knitr RNG-apply

library(parallel)
library(rlecuyer)
nSims <- 250
taskFun <- function(i){
	val <- runif(1)
	return(val)
}

nCores <- 4
RNGkind()
cl <- makeCluster(nCores)
iseed <- 0
clusterSetRNGStream(cl = cl, iseed = iseed)
RNGkind() # clusterSetRNGStream sets RNGkind as L'Ecuyer-CMRG
# but it doesn't show up here on the master
res <- parSapply(cl, 1:nSims, taskFun)
# now redo with same master seed to see results are the same
clusterSetRNGStream(cl = cl, iseed = iseed)
res2 <- parSapply(cl, 1:nSims, taskFun)
identical(res,res2)
stopCluster(cl)

## @knitr RNGstream

RNGkind("L'Ecuyer-CMRG") 
seed <- 0
set.seed(seed)
## now start M workers 
s <- .Random.seed 
for (i in 1:M) { 
	s <- nextRNGStream(s) 
	# send s to worker i as .Random.seed 
} 

## @knitr RNG-mclapply

library(parallel)
library(rlecuyer)
RNGkind("L'Ecuyer-CMRG")
res <- mclapply(seq_len(nSims), taskFun, mc.cores = nCores, 
    mc.set.seed = TRUE) 
# this also seems to reset the seed when it is run
res2 <- mclapply(seq_len(nSims), taskFun, mc.cores = nCores, 
    mc.set.seed = TRUE) 
identical(res,res2)



## @knitr RNG-doRNG

library(doRNG)
library(doParallel)
registerDoParallel(nCores)
registerDoRNG(seed = 0) 
result <- foreach(i = 1:20) %dopar% { 
	out <- mean(rnorm(1000)) 
}
registerDoRNG(seed = 0) 
result2 <- foreach(i = 1:20) %dopar% { 
	out <- mean(rnorm(1000)) 
}
identical(result,result2)




## @knitr pvec

library(parallel)
nCores <- 8
cl <- makeCluster(nCores) 
library(fields)
ds <- runif(6000000, .1, 10)
ds_exp <- pvec(ds, exp, mc.cores = nCores)
# here's a more computationally intensive function
system.time(
	corVals <- pvec(ds, Matern, .1, 2, mc.cores = nCores)
)
system.time(
	corVals <- Matern(ds, .1, 2)
)

## @knitr mcparallel

library(parallel)
n <- 10000000
system.time({
	p <- mcparallel(mean(rnorm(n)))
	q <- mcparallel(mean(rgamma(n, shape = 1)))
	res <- mccollect(list(p,q))
})
system.time({
	p <- mean(rnorm(n))
	q <- mean(rgamma(n, shape = 1))
})
