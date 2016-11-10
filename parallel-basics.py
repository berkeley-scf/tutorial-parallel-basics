#!/usr/bin/python

## @knitr py-linalg

import numpy as np
n = 5000
x = np.random.normal(0, 1, size=(n, n))
x = x.T.dot(x)
U = np.linalg.cholesky(x)

## @knitr ipython-parallel

import numpy as np
np.random.seed(0)
n = 500
p = 50
X = np.random.normal(0, 1, size = (n, p))
Y = X[: , 0] + pow(abs(X[:,1] * X[:,2]), 0.5) + X[:,1] - X[:,2] + np.random.normal(0, 1, n)

def looFit(index, Ylocal, Xlocal):
    rf = rfr(n_estimators=100)
    fitted = rf.fit(np.delete(Xlocal, index, axis = 0), np.delete(Ylocal, index))
    pred = rf.predict(np.array([Xlocal[index, :]]))
    return(pred[0])

from ipyparallel import Client
c = Client()
c.ids

dview = c[:]
dview.block = True
dview.apply(lambda : "Hello, World")

lview = c.load_balanced_view()
lview.block = True

dview.execute('from sklearn.ensemble import RandomForestRegressor as rfr')
dview.execute('import numpy as np')
mydict = dict(X = X, Y = Y, looFit = looFit)
dview.push(mydict)

nSub = 50  # for illustration only do a subset

# need a wrapper function because map() only operates on one argument
def wrapper(i):
    return(looFit(i, Y, X))

import time
time.time()
pred = lview.map(wrapper, range(nSub))
time.time()

print(pred[0:10])

# import pylab
# import matplotlib.pyplot as plt
# plt.plot(Y, pred, '.')
# pylab.show()




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


