#!/usr/bin/python

## @knitr py-linalg

import numpy as np
n = 5000
x = np.random.normal(0, 1, size=(n, n))
x = x.T.dot(x)
U = np.linalg.cholesky(x)

## @knitr python-pp

import numpy
import pp

nCores = 4
job_server = pp.Server(ncpus = nCores, secret = 'mysecretphrase')
# set 'secret' to some passphrase (you need to set it but 
#   what it is should not be crucial)
job_server.get_ncpus()

nSmp = 10000000
m = 40
def taskFun(i, n):
    numpy.random.seed(i)
    return (i, numpy.mean(numpy.random.normal(0, 1, n)))

# create list of tuples to iterate over
inputs = [(i, nSmp) for i in xrange(m)]
# submit and run jobs using list comprehension
jobs = [job_server.submit(taskFun, invalue, modules = ('numpy',)) for invalue in inputs]
# collect results (will have to wait for longer tasks to finish)
results = [job() for job in jobs]
print(results)
job_server.destroy()

## @knitr python-mp

import multiprocessing as mp
import numpy as np

nCores = 4 # to set manually

nSmp = 10000000
m = 40
def taskFun(input):
    np.random.seed(input[0])
    return np.mean(np.random.normal(0, 1, input[1]))

# create list of tuples to iterate over, since
# Pool.map() does not support multiple arguments
inputs = [(i, nSmp) for i in xrange(m)]
inputs[0:2]
pool = mp.Pool(processes = nCores)
results = pool.map(taskFun, inputs)
print(results)


