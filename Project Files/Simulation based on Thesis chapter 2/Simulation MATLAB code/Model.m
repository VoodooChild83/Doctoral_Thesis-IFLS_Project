% Program for simulation of the parental decision on moving and education
% model.

% This model is an infinitely-lived dynastic model of the two decisions
% made by agents in their two periods of life over the OLG. 

clear; clc; close all;

% Model Parameters
alpha=0.95; % This is the case of two-way altruism (actually something that
           % I have not built into the model and so this parameter will
           % change into full altruism over time --> i.e. it will increase
           % to 0.9 or 0.95 solowly to study the change on outcomes. 
tol=1e-8;  % Tolerance of the convergence
MaxIter=1000; % The maximum amount of time to iterate to the fixed point of
              % the problem. 
MovCost=-1;  % Normalized cost to move to the other market
EducCost=-0.5; % Cost to educate the child
              
% Wages for different markets
% sub-index notation: w_ij --> j=skill (either h=1 for low skill, no
% education; or h=2 for high skill, educated; c=child for child wage) 
% i=market location

    % **Market 1**
    w_11=1; w_12=2.091; w_c1=0; %0.536;
    
    % **Market 2**
    w_21=0.950; w_22=1.956; w_c2=0; %0.358;
    
    % All wage values are taken from the data and normalized w.r.t. the
    % unskilled wage offered in market 1.
    
 % Create arrays for matrix math
 
 % Adult activites
 adult_wages=[[w_11;w_11;w_21;w_21]...
              [w_21;w_21;w_11;w_11]...
              [w_12;w_12;w_22;w_22]...
              [w_22;w_22;w_12;w_12]];
wages=reshape(adult_wages,4,1,4);
 
 % Child activities
 child_act=[[w_c1;EducCost;w_c1;EducCost]...
            [w_c2;EducCost;w_c1;EducCost]...
            [w_c1;EducCost;w_c2;EducCost]...
            [w_c2;EducCost;w_c1;EducCost]];

c_wages=reshape(child_act,4,1,4);

%Mover Array
move=[0;0;MovCost;MovCost];
 
%% Transition states
model=1;

if model==1
    tran_st=[[1,0,0,0;0,0,1,0;0,1,0,0;0,0,0,1]...
             [0,1,0,0;0,0,0,1;1,0,0,0;0,0,1,0]...
             [1,0,0,0;0,0,1,0;0,1,0,0;0,0,0,1]...
             [0,1,0,0;0,0,0,1;1,0,0,0;0,0,1,0]];

elseif model==2
    tran_st=[[1,0,0,0;0.1416,0,0.8584,0;0,1,0,0;0,0.1545,0,0.8455]...
             [0,1,0,0;0,0.1518,0,0.8482;1,0,0,0;0.1171,0,0.8829,0]...
             [1,0,0,0;0.0871,0,0.9129,0;0,1,0,0;0,0.0205,0,0.9795]...
             [0,1,0,0;0,0.0396,0,0.9604;1,0,0,0;0.0262,0,0.9738,0]];

else
    tran_st=[[1,0,0,0;0.3799,0,0.6201,0;0,1,0,0;0,0.3496,0,0.6504]...
             [0,1,0,0;0,0.5125,0,0.4875;1,0,0,0;0.3964,0,0.6036,0]...
             [1,0,0,0;0.2635,0,0.7365,0;0,1,0,0;0,0.1365,0,0.8635]...
             [0,1,0,0;0,0.2078,0,0.7922;1,0,0,0;0.1429,0,0.8571,0]];
end   

tranny=reshape(tran_st,4,4,4);

%% Solving the value functions of the model with linear utility and GE-III expected values

% Preallocate the Value function matrix (since there are 4 value functions
% this means the matrix is dim(4xMaxIter)

V=zeros(4,MaxIter);
tally=zeros(4,MaxIter);
v=zeros(4,4,MaxIter);

%Initial Guess
V(:,1)=rand(4,1);

tic
for i=2:MaxIter
    
    for j=1:size(V,1)
        
        v(:,j,i-1) = wages(:,:,j)+c_wages(:,:,j)+move+alpha*(tranny(:,:,j)*V(:,i-1));
        
        tally(j,i-1)=sum(exp(v(:,j,i-1)));
        
        V(j,i)=eulergamma+log(tally(j,i-1));
        
    end
    
    % Check for conversion
    norm_check=abs(V(:,i)-V(:,i-1)); % absolute difference between this and prev value
    norm_check(~isfinite(norm_check))=NaN; % disregard non-finite values
    norm_check=max(norm_check); % max absolute finite differences
    
    if norm_check < tol  %indicate magnitude of the error
        
        % Print the outcome of the convergence
        fprintf('error %1.2e < tol=%1.2e convergence achieved!\n',norm_check,tol);
        
        % Remove excess columns from value function array
        V(:,i+1:end)=[]; % delete unused columns
        tally(:,i:end)=[];
        v(:,:,i:end)=[];
        
        CCP=exp(v(:,:,end))./repmat(tally(:,end)',4,1);
        

        break;
     
    else
        fprintf('error %1.2e\n',norm_check);
    end
    
end
toc   