
# Cython code to optimise in C the solution of the model portion of the code

##################### Import Modules and math functions ######################

#Cython and C functions (this is faster than calling external C function math libs)
cimport cython

#from cython.parallel import prange
from libc.stdlib cimport rand, RAND_MAX, malloc, calloc, free
from libc.math cimport exp, log, HUGE_VAL

#Import the GE-typeIII (standardized gumbel) random number generator (call to
#CPython so can not release the gil around this code
from scipy.stats import gumbel_r as GE

####################### Assign the global variables ##########################

#These will be passed into functions automatically without 
#having to call them up explicitely

cdef size_t HH, tot_states, Gen

##############################################################################
####### Define the functions that will assist the simulation module ##########
##############################################################################

############ Random Numbers, Random States, and Random Shocks functions

#Random number generator on interval [0,1]
@cython.cdivision(True)
cdef inline double rand_value() nogil:
    return rand()/<double>RAND_MAX

#This function will generate random integers between 1 and 4 (inclusive) to 
#give initial generation their states
#@cython.cdivision(True)
#cdef unsigned int rand_state(unsigned int min, unsigned int max) nogil:
#    cdef double scaled
    
#    #generate a random number between 0 and 1
#    scaled=rand_value()
    
#    #return a random number between 1 and the state
#    return <unsigned int>(max*scaled + min)

#This function will fill the allocated memory with the shocks from the GE-3 gumbel
#set the seed to 3 (it doesn't matter which)
@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)                          
cdef void FILL_shocks(double* arr, size_t iter):
    cdef Py_ssize_t i
    for i in xrange(iter):
        arr[i]=GE.rvs()


############# Choice Specific Values assisting functions

#Define the inner-array product, releasing the gil of the function
@cython.boundscheck(False)
@cython.wraparound(False)
cdef double dot( double[:] a, double[:] b ) nogil:
    cdef:
        double result=0
        Py_ssize_t i, dim=a.shape[0]

    for i in range(dim):
        result += a[i]*b[i]
    return result

#This function will output the decision based on max value
@cython.boundscheck(False)
@cython.wraparound(False)
cdef Py_ssize_t Compare(double* arr, size_t curr_hh) nogil:
    
    #declare variable types
    cdef:
        Py_ssize_t dec=0, i
        double v_temp, max=(-1)*HUGE_VAL

    #grab the max of the choice specific value for the current household:
    for i in range(1,tot_states+1):
        v_temp = arr[(i-1) + curr_hh*tot_states]
        if v_temp > max: 
            #update the max
            max = v_temp
            #capture current index
            dec = i

    return dec


############### Function and auxiliaries determining the next state

#This function rewrites array with the cumulative sum through recursion
@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef void cum_sum(double *arr, size_t index=4-1) nogil:
    if index<=0: return
    cum_sum(arr, index-1)
    arr[index] += arr[index-1]

#This function will determine the index of the transition function 
#based on the cumulative probabilities 
@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef unsigned int find_interval(double x, double *arr) nogil:
    cdef Py_ssize_t i
    
    for i in range(tot_states):
        if x<arr[i]:
            return i

#This function will generate the next state based on the transition
#function probabilites (a discrete value)
@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cdef unsigned int Next_State(double[:] tran) nogil:
    cdef:
        double x
        double *array
        unsigned int index
        Py_ssize_t i
    
    array=<double*> calloc(tot_states, sizeof(double))
    
    with gil:
        if not array: raise MemoryError()

    try:
        #generate a random number to help determine the next state
        x = rand_value()
        
        #copy the transition function values into the array to prevent rewrite
        for i in range(tot_states):
            array[i]=tran[i]
        
        #rewrite the array into the cumulative sum of the elements
        cum_sum(array)
        
        #the next state is the return value of the function
        #(the array index) + 1 to create the next state
        index = find_interval(x, array) + 1
    
        return index

    finally:
        free(array)  


################### Functions generating frequencies 

#This function will calculate the frequency of decisions for each generation
@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
cdef void Frequencies(unsigned int* arr, double[:,:] freq, Py_ssize_t curr_gen) nogil:
    cdef:
        unsigned int choice
        unsigned int* counter
        Py_ssize_t i, j

    #allocate and fill the counter array with 0s
    counter=<unsigned int*> calloc(tot_states, sizeof(unsigned int))

    with gil:
        if not counter: raise MemoryError()

    try:
        #with parallel(num_threads=thread_count):
        for i in xrange(HH):#, schedule='dynamic'):
            choice = arr[i + curr_gen*HH]
            for j in range(1,tot_states+1):
                if choice==j:
                    counter[j-1]+=1

        for i in range(tot_states):
            freq[i,curr_gen] = counter[i]/<double>HH
    finally:
        free(counter)

#This function will calculate the empirical CCPs for whichever chosen generation
@cython.boundscheck(False)
@cython.wraparound(False)
@cython.cdivision(True)
cdef void CCP(unsigned int* dec_arr, unsigned int* state_arr, 
               size_t gen, double[:,:] freq) nogil:
    
    #declare variable types
    cdef:
        unsigned int choice, state
        unsigned int* counter
        double* sums
        Py_ssize_t i, j, k
    
    #allocate the counter arrays with 0s
    counter=<unsigned int*> calloc(tot_states**2, sizeof(unsigned int))
    sums=<double*> calloc(tot_states, sizeof(double))
    
    with gil:
        if not (counter or sums): raise MemoryError()

    try:
        #count the penultimate generation's states and decisions
        for i in xrange(HH):#, schedule='dynamic', num_threads=40):
            state = state_arr[i + gen*HH]
            choice = dec_arr[i + gen*HH]
            for j in range(1,tot_states+1):
                if state==j: 
                    sums[j-1] +=1
                    for k in range(1,tot_states+1):
                        if choice==k:
                            counter[(k-1) + (j-1)*tot_states] +=1
	
        #fill in the CCP matrix with the estimates
        for i in range(tot_states):
            for j in range(tot_states):
                freq[j,i] = counter[j + i*tot_states]/sums[i]
    finally:
        free(counter)
        free(sums)

############ Function defining the simulation of the model ################
@cython.boundscheck(False)
@cython.wraparound(False)
@cython.nonecheck(False)
cpdef void Sim_Model(double[:] V, double alpha, double[:,:,:] wages, 
                     double[:,:,:] child, double[:,:] move, 
                     double[:,:,:] tranny, 
                     int[:] demos, double[:,:] dec_freq, 
                     double[:,:] states_freq, double[:,:] CCPs, double[:] init_states):
    
    #declare and assign the globals
    global HH, tot_states, Gen
    
    HH=demos[0]
    tot_states=V.shape[0]
    Gen=demos[1]
    
    #declare the types for variables and arrays
    cdef:
        Py_ssize_t decision=0, state=0
        
        #define array types
        unsigned int* decisions
        unsigned int* states
        double* v_sim
        double* shocks
        
        #define iterators
        cdef Py_ssize_t i, j, k
    
    #allocate arrays
    decisions = <unsigned int*> calloc(HH*(Gen-1), sizeof(unsigned int))
    states = <unsigned int*> calloc(HH*Gen, sizeof(unsigned int))
    v_sim = <double*> calloc(HH*tot_states, sizeof(double))
    shocks = <double*> malloc(HH*tot_states*(Gen-1) * sizeof(double))
        
    #check that memory was allocated:
    if not (decisions or states or v_sim or shocks): raise MemoryError()
    
    #Fill in the shocks with the shock function
    FILL_shocks(shocks,HH*tot_states*(Gen-1))
    
    #simulate the model
    try:
        #release the gil
        with nogil:
        
            #for initial generation, replace with random states generated from given distribution
            for j in xrange(HH):#, num_threads=8):
                states[j]=Next_State(init_states) #rand_state(1,tot_states)
        
            #fill in the frequency of states of the first generation (gen 0)
            Frequencies(states, states_freq, 0)
        
            #outerloop are the generations (make sure that we skip the last generation - they
            #make no decisions - so start iterator at 1 and not 0)
            for i in xrange(1,Gen):
            
                #inner loop the households (should be parallelizable)
                for j in xrange(HH):#, num_threads=8):
            
                    #grab the household's state from the matrix
                    state=states[j+(i-1)*HH]
                
                    for k in range(tot_states):
                    
                        #calculate choice specific value functions
                        v_sim[k+j*tot_states] = wages[state-1,0,k] + child[state-1,0,k] + move[0,k] + alpha*dot(tranny[state-1,k,:],V) + shocks[k+(j+(i-1)*HH)*tot_states]
                    
                    #compare values, return the decision (index+1)
                    decision=Compare(v_sim,j)
                    decisions[j+(i-1)*HH]=<unsigned int>decision
                
                    #the next generations state (make sure we don't attempt to write (Gen+1):
                    states[j+i*HH]=Next_State(tranny[state-1,decision-1,:])

                #calculate the frequencies of decisions taken and of the next states
                Frequencies(decisions, dec_freq, (i-1))
                Frequencies(states, states_freq, i)

            #fill the CCP array (last generation to make decisions - array block Gen-2)
            CCP(decisions, states, 0, CCPs) #(Gen-2)

    finally:
        free(decisions)
        free(v_sim)
        free(states)
        free(shocks)
