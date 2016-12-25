# The current version of the move model: the namespace with the model as an imported
# Cython optimized function module.

##################### Import Modules and math functions ######################

import numpy as np
import time

#Import the C-optimized modules that run the actual model and simulation
# from Solution import Modelo
# from Simulation import Sim_Model

######################### Define Parameters ##################################

#Parameters and parameter vector to pass into function
alpha=0.95      #altruism parameter
tol=1e-8        #tolerance of convergence 
iteration=10000  #upper bound of iterations
tot_states=4    #number of states
tot_decisions=4 #number of decisions

MoveCost=-1     #normalized cost of moving to new region
EducCost_R1=0  #opportunity cost of education in region 1
EducCost_R2=-1.5  #opportunity cost of education in region 2

param_lst=[alpha,tol,iteration]

parameters=np.array(param_lst, dtype='d')

####################### Wages of Children and Adults #########################

############## Adults
#Market Adult Wages (as an array, ndim=3)
#rows:      regions
#columns:   skill levels

wage_R1_ls=1
wage_R1_hs=2.091
wage_R2_ls=0.950
wage_R2_hs=1.956

#Strucutre a wage array for quick access 
wage_lst=[[wage_R1_ls]*2+[wage_R2_ls]*2,
          [wage_R2_ls]*2+[wage_R1_ls]*2,
          [wage_R1_hs]*2+[wage_R2_hs]*2,
          [wage_R2_hs]*2+[wage_R1_hs]*2]

adult_wages=np.array(wage_lst, dtype='d').reshape((tot_states,1,tot_decisions))

############## Children
#Child activity (as arrays, ndim=3)
children=input("Do children have wages (y/n): ")

if children=='y': c_wage_R1=0.536; c_wage_R2=0.358    
elif children=='n': c_wage_R1=0; c_wage_R2=0
else: quit()

#Permute the wages to get quick access
child_lst=[[c_wage_R1,EducCost_R1,c_wage_R2,EducCost_R2],
           [c_wage_R2,EducCost_R2,c_wage_R1,EducCost_R1]]*2

child_wages=np.array(child_lst, dtype='d').reshape((tot_states,1,tot_decisions))

############## Moving Cost
#Mover vector (ndim=1)
move_lst=[[0]*2+[MoveCost]*2]

move=np.array(move_lst, dtype='d')

############### Transition Functions for Skill Formations ####################

#Transition function: Define the transition function 
#1) deterministic 
#2) End-of-6th-grade drop out
#3) End-of-9th-grade drop out

#Prompt for the model:
model=input('''
Model skill aquisition:
deterministic (1)
uncertain skill - 6th grade dropout (2)
uncertain skill - 9th grade dropout (3)
Please enter the corresponding model number (anything else to quit): ''')

try:
    model=int(model)
    if model<1 or model>3:
        print("Error: input is out of indicated bounds. Exiting...\n"); quit()
except:
    quit()

if model==1:
    tran_st=[[1,0,0,0],[0,0,1,0],[0,1,0,0],[0,0,0,1],
             [0,1,0,0],[0,0,0,1],[1,0,0,0],[0,0,1,0],
             [1,0,0,0],[0,0,1,0],[0,1,0,0],[0,0,0,1],
             [0,1,0,0],[0,0,0,1],[1,0,0,0],[0,0,1,0]]

elif model==2:
    tran_st=[[1,0,0,0],[0.1416,0,0.8584,0],[0,1,0,0],[0,0.1545,0,0.8455],
             [0,1,0,0],[0,0.1518,0,0.8482],[1,0,0,0],[0.1171,0,0.8829,0],
             [1,0,0,0],[0.0871,0,0.9129,0],[0,1,0,0],[0,0.0205,0,0.9795],
             [0,1,0,0],[0,0.0396,0,0.9604],[1,0,0,0],[0.0262,0,0.9738,0]]

else:
    tran_st=[[1,0,0,0],[0.3799,0,0.6201,0],[0,1,0,0],[0,0.3496,0,0.6504],
             [0,1,0,0],[0,0.5125,0,0.4875],[1,0,0,0],[0.3964,0,0.6036,0],
             [1,0,0,0],[0.2635,0,0.7365,0],[0,1,0,0],[0,0.1365,0,0.8635],
             [0,1,0,0],[0,0.2078,0,0.7922],[1,0,0,0],[0.1429,0,0.8571,0]]

#place into an array and make into 3 dimensional array
tran_func=np.array(tran_st, dtype='d').reshape((tot_states,tot_decisions,tot_states))

########################## Solve the Model ###################################

#define the output arrays to send into function and fill in later
CCP=np.zeros((tot_decisions,tot_states), dtype='d')
V=np.zeros((tot_states), dtype='d')

#Call the model and time it
t1=time.time()
Modelo(parameters,adult_wages,child_wages,move,tran_func,CCP,V)
t2=time.time() - t1

print("\nSolving the model took",t2,"seconds to complete \n")
print("The model yields the following CCPs:")
print(CCP)

#save the values from the model
np.savetxt("Output/CCP.txt",CCP)
np.savetxt("Output/Cont_Values.txt",V)

######################### Simulate the model ################################

sim=input("Simulate the model (y/n): ")

if sim=='y':
    #Define the vector of integers that will enter into the model:
    #1) number of households
    num_HH=5000
    #2) number of generations
    gens=25
    #3) initial distribution
    init_states=np.array([0.25,0.25,0.25,0.25], dtype='d')

    #pack into an array to send into function
    people=np.array([num_HH,gens], dtype='i')

    #Declare and allocate the output matrices
    dec_freq_out=np.zeros((tot_decisions,(gens-1)), dtype='d')
    states_freq_out=np.zeros((tot_states,gens), dtype='d')
    CCP_est=np.zeros((tot_decisions,tot_states), dtype='d')

    #Call the model and time it
    t1=time.time()
    Sim_Model(V,alpha,adult_wages,child_wages,move,
              tran_func,people,dec_freq_out,states_freq_out,CCP_est,init_states)
    t2=time.time() - t1

    print("\nSimulating the model took",t2,"seconds to complete \n")
    print("The simulation yields the following estimated CCPs for generation {}:".format(0))
    print(CCP_est,"\n")

    #save output matrices
    np.savetxt("Output/Decision_Frequencies.txt",dec_freq_out)
    np.savetxt("Output/States_Frequencies.txt", states_freq_out)
    np.savetxt("Output/Simulation_CCP.txt", CCP_est)


# In[ ]:



