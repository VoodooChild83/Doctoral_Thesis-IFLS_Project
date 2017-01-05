
# Cython code to optimise in C the solution of the model portion of the code

##################### Import Modules and math functions ######################

#Global Cython Compiler Directives:

#!python
#cython: boundscheck=False
#cython: wraparound=False
#cython: nonecheck=False
#cython: cdivision=True

#Modules
from libc.stdlib cimport  rand, RAND_MAX, calloc, free, abort
from libc.math cimport exp, log, HUGE_VAL

#Define euler's constant
cdef double eg = 0.5772156649015328606065

############################# Define Globals #################################

cdef Py_ssize_t tot_states, tot_decisions, iteration

########################### Define functions to use ##########################

#This function will generate random integers between 1 and 4 (inclusive) to 
#give initial generation their states

cdef inline double rand_val() nogil:
    #generate a random number between 0 and 1
    return rand()/<double>RAND_MAX

#The infimum norm for test of convergence, releasing the gil of the function

cdef double infnorm( double *arr ) nogil:
    cdef:
        double temp, norm=(-1)*HUGE_VAL
        Py_ssize_t j
        
        #manually allocate the memory of the array to avoid calls to the cpython api
        double* diff = <double*>calloc(tot_states, sizeof(double))
    
    if not diff: abort()
        
    try:  
        #calculate the absolute value of the differences between the two vectors
        for j in range(tot_states):
            temp = arr[j + tot_states] - arr[j]
            #manual absolute value to prevent using abs function (a cpython api call)
            if temp<0:
                temp=(-1)*temp
            diff[j]=temp
        for j in range(tot_states):
            if diff[j]>norm: norm=diff[j]
        return norm
        
    finally:
        free(diff)

#Define the inner-array product, releasing the gil of the function

cdef double dot( double[:] a, double *b ) nogil:
    cdef:
        double result=0
        Py_ssize_t i, dim=a.shape[0]
    for i in range(dim):
        result += a[i]*b[i]
    return result

#The model:

cpdef void Modelo(double[:] param, double[:,:,:] wages, double[:,:,:] c_wages, 
                  double[:,:] mover, double[:,:,:] tranny, double[:,:] CCP, double[:] V) nogil: 
             
    #declare and assign globals
    global iteration, tot_states, tot_decisions

    iteration=<size_t>param[2]
    tot_states=tranny.shape[0]
    tot_decisions=V.shape[0]
    
    #declare variables and arrays
    cdef:
        #parameters
        double alpha=param[0]
        double tol=param[1]
        double v_temp=0
        double total=0
        double check=0
        
        #declare loop iterators:
        Py_ssize_t j, k, l
        
        #define array types
        double *V_model
        double *v
        double *sums
        
    V_model=<double*> calloc(tot_states*2, sizeof(double))
    v=<double*> calloc(tot_states*tot_decisions, sizeof(double))
    sums=<double*> calloc(tot_states, sizeof(double)) 

    #check memory was allocated:
    if not (V_model or v or sums): abort()

    #run the model solution
    try:
        #initial guess
        for j in range(tot_states):
            V_model[j]=rand_val()
        
        #run the model loop
        for j in xrange(1,iteration):
    
            for k in xrange(tot_states):            # iterate over the states (the third dimension)

                total=0
            
                for l in xrange(tot_decisions):     # iterate over each decision to fill in the v matrix

                    v_temp=wages[k,0,l] + c_wages[k,0,l] + mover[0,l] + alpha*dot(tranny[k,l,:],V_model)
                   
                    v[l + k*tot_decisions]=v_temp

                    #sum the exponential of the choice specific value
                    total += exp(v_temp)    
                    
                #add the total unsigned shorto the sum array
                sums[k] = total
                
                #update the V_model array with the new values
                V_model[k + tot_states] = eg + log(total)
                
            #check for convergence
            check = infnorm(V_model)
            
            #convergence:
            if check < tol:
                #copy elements from iteration to the output arrays
                for k in xrange(tot_states):
                    V[k] = V_model[k + tot_states]
                    for l in range(tot_decisions):
                        CCP[l,k] = exp(v[l+k*tot_decisions])/sums[k]
                break
            #move the first column in V_model to the zeroeth column for next iteration
            else:
                for k in xrange(tot_states):
                    V_model[k]=V_model[k+tot_states]
                
    finally:
        free(V_model)
        free(v)
        free(sums)
