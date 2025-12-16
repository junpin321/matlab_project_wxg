%-------------HIGH FIDELITY EVALUATION OF POPULATION--------------
function [popObj, popCons, popCV ] = evaluate_pop(opt, pop)
%% Population size
% Objection Function Value Array
sz=size(pop,1);
popObj = zeros(sz,opt.M);

% Constraint Condition Array
if opt.C>0
    popCons = zeros(sz,opt.C);
else
    popCons = zeros(sz, 1);
end

%% Total Pumping Rate - Optimization objective
% Output Constraint condition by running Modflow2005
for i=1:sz    
    popCons(i,:) = gwmodel(pop(i,:)); 
end

%%  Judging constraint conditions
[~,n]=size(popCons);
g = zeros(sz,n);
for i=1:sz
    
    % Drawdown1 -- SWRB, HHB, MB
    if popCons(i,1)>2.0
        g(i,1)=1;
    end
    % Drawdown2 -- KB
    if popCons(i,2)>1.0
        g(i,2)=1;
    end    
    
    % Groundwater Head -- KB
    if popCons(i,3)<0.0
        g(i,3)=1;
    end      
    
    % Model Cell Dryout Indicator  
    if popCons(i,4)==1
        g(i,4)=1;
    end      
    
    % Total Pumping Rate Constraint I 
    % Maguires Borefield // Crescent Head  Borefields -520
    if popCons(i,5)>260.0
        g(i,5)=1;
    end
    
    % Total Pumping Rate Constraint II --146
    % Hat Head Borefield
    if popCons(i,6)>73.0
        g(i,6)=1;
    end    
    
    % Total Pumping Rate Constraint III 
    % South West Rocks Borefield -- 2500
    % 1569 -- The total pumping should not exceed 50 percent of the allocation for each borefield.
    if popCons(i,7)>1250.0
        g(i,7)=1;
    end    
    
    % Total Pumping Rate Constraint IV -- 146
    % Kinchela Borefield
    if popCons(i,8)>73.0
        g(i,8)=1;
    end
    
    %  Maximizing Total Pumping Rate -- Penalty function
    popObj(i,1)=sum(pop(i,:))+sum(g(i,:))*(-1.0e+06);
    
    
end

% CV -- Constraint Violation Count
popCV = sum(g, 2);


end