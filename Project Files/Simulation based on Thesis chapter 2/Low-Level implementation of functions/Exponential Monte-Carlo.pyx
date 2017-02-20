
#!python
#cython: boundscheck=False, wraparound=False, nonecheck=False, cdivision=True

#Import modules: 

from libc.stdlib cimport rand, RAND_MAX, malloc, calloc, realloc, free, abort
from libc.math cimport log

#Use the CythonGSL package to get the low-level routines
from cython_gsl cimport *

######################### Define the Data Structure ############################

cdef struct Parameters:
    #Pointer for Y data array
    double* Y
    #size of the array
    int* Size

################ Support Functions for Monte-Carlo Function ##################

#Create a function that allocates the memory and verifies integrity
cdef int alloc_struct(Parameters* data, int* N, unsigned int flag, int Mem_Int) nogil:
    
    #fill in the size of the array
    data.Size = N
    
    #allocate the data array initially
    if flag==0:
        data.Y = <double*> calloc(N[0], sizeof(double))
    #reallocate the data array according to the size of N
    else:
        data.Y = <double*> realloc(data.Y, N[0] * sizeof(double))
    
    #If the elements of the struct are not properly allocated, destory it and return null
    if N[0]!=0 and data.Y==NULL:
        
        #return the memory to system
        destroy_struct(data)
        
        #update the memory integrity variable to False
        Mem_Int = False
        
        return Mem_Int
    
    else: return Mem_Int

#Create the destructor of the struct to return memory to system
cdef void destroy_struct(Parameters* data) nogil:
    free(data.Y)
    free(data)

#This function fills in the Y observed variable with discreet 0/1
cdef void Y_fill(Parameters* data, gsl_rng* r, double lam) nogil:
    
    cdef:
        Py_ssize_t i
        double y
        
    for i in range(data.Size[0]):
        
        data.Y[i] = gsl_ran_exponential(r, lam)

#Definition of the function to be maximized: LLF of the Exponential
cdef double LLF(double lam, void* data) nogil:
    
    cdef:
        #the sample structure (considered the parameter here)
        Parameters* sample = <Parameters*> data
        
        #the loop iterator
        Py_ssize_t i 
        int n = sample.Size[0]
        
        #the total of the LLF
        double Sum = n*log(lam)
     
    for i in range(n):
        
        Sum -= lam*sample.Y[i]
    
    return (-(Sum/n))

########################## Monte-Carlo Function ##############################

cpdef void Monte_Carlo(int[::1] Samples, double[:,::1] lam_hat, double lam_true, int Sims) nogil:
     
    #Define variables and pointers
    cdef:
        #Data Structure
        Parameters* Data
            
        #iterators
        Py_ssize_t i, j
        int status, GSL_CONTINUE, max_Iter = 10000, Iter
        
        #Variables
        int N = Samples.shape[0], Mem_Int = True
        double a, b, tol = 1e-6, start_val
        
        #define the GSL RNG variables
        const gsl_rng_type* T 
        gsl_rng* r 
        
        #GSL Minimization Objects
        const gsl_min_fminimizer_type* U
        gsl_min_fminimizer* s
        gsl_function F
        
    #allocate the struct dynamically
    Data = <Parameters*> malloc(sizeof(Parameters))
    
    #Allocate the minimization routine
    U = gsl_min_fminimizer_brent
    s = gsl_min_fminimizer_alloc(U)
    
    #Instantiate the RNG
    gsl_rng_env_setup()
    
    T = gsl_rng_default
    r = gsl_rng_alloc(T)
    
    #Verify memory integrity of allocated objects
    if Data==NULL or s==NULL or r==NULL: abort()
    
    #Set the GSL function
    F.function = &LLF
    F.params = <void*> Data
    
    try:
        for i in range(N): 

            #allocate the elements of the struct (if i>0, reallocate)
            Mem_Int = alloc_struct(Data, &Samples[i], i, Mem_Int)

            #verify memory integrity of the allocated Struct
            if Mem_Int==False: abort() 
                
            for j in range(Sims):

                #Randomly set the seed
                gsl_rng_set(r, rand())

                #fill in the array in the struct
                Y_fill(Data, r, lam_true)

                #set the parameters in GSL F Function
                a = tol; b = 1000

                #set the starting value (random number)
                start_val = rand()/<double>RAND_MAX

                #set the minimizer
                gsl_min_fminimizer_set(s, &F, start_val, a, b)

                #initialize conditions
                GSL_CONTINUE = -2
                status = -2
                Iter = 0

                #maximize the function
                while (status == GSL_CONTINUE and Iter < max_Iter):

                    Iter += 1
                    status = gsl_min_fminimizer_iterate(s)

                    start_val = gsl_min_fminimizer_x_minimum(s)
                    a = gsl_min_fminimizer_x_lower(s)
                    b = gsl_min_fminimizer_x_upper(s)

                    status = gsl_min_test_interval(a, b, tol, 0.0)

                    if (status == GSL_SUCCESS):
                        lam_hat[i,j] = start_val

    finally:
        destroy_struct(Data)
        gsl_rng_free(r)
        gsl_min_fminimizer_free(s)
