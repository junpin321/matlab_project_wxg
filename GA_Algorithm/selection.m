function selected_pop = selection(opt, pop, popObj)
%% Constrainted Tournament Selection for Single Objective Optimization
% Population Size
N = opt.N;
%----TOURNAMENT CANDIDATES-------------------------------------------------
tour1 = randperm(N);
tour2 = randperm(N);
%----START TOURNAMENT SELECTION--------------------------------------------
selected_pop = zeros(N, opt.V); % Only the design variables of the selected members

for i = 1:N
    p1 = tour1(i);
    p2 = tour2(i);   
    % Both individuals are Feasible 
    obj1 = popObj(p1,:);
    obj2 = popObj(p2,:);
    if  obj1>obj2  %p1 dominates p2
        selected_pop(i, :) = pop(p1,1:opt.V);
    elseif obj1<obj2 % p2 dominates p1
        selected_pop(i, :) = pop(p2,1:opt.V);
    else
        if(rand <= 0.5)
            pick = p1; 
        else
            pick = p2;
        end
        selected_pop(i, :) = pop(pick,:);
    end
end
    
    
end