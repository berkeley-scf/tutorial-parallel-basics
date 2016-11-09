# when using multiple threads this code in some cases hangs in mclapply and foreach because of a conflict between threaded BLAS and forking

ncores <- 4
library(RhpcBLASctl)
omp_set_num_threads(ncores)
# alternatively set OMP_NUM_THREADS=4 in the bash session before starting R

library(doParallel)

ncores <- 4

myfun <- function(i, n) {
    tmp <- matrix(rnorm(n^2), n)
    tmp2 <- t(t(tmp)%*% rnorm(n))
     out <- (tmp%*%tmp)[1,1]
    Hcov = solve(diag(3))
    solve(diag(3))[1,1] 
}


n <- 25

if(TRUE)
    Hcov = solve(diag(3))


mclapply(1:5, myfun, n, mc.cores = ncores)

registerDoParallel(ncores)

output <- foreach(i = 1:10) %dopar% {
    myfun(i,n)
}

# no forking so this should be fine
cl = makeCluster(ncores)

parLapply(cl, 1:5, myfun, n)
