The tests in this chebops directory should test most aspects of the 
differential equations functionality in Chebfun. Under the hood, these
problems all typically use linops to solve the linearised problem, so there
is no need for too miuch duplication (i.e., solving with both chebops and 
linops).