function [pop_mut, nrealmut] = pol_mut(pop_crossover, pmut, nrealmut, eta_m, Xmin, Xmax )
%% Polynomial Mutation 

[N, nreal] = size( pop_crossover); 
% Population size & Number of variables

pop_mut =  pop_crossover;
% Child before mutation


for ind = 1:N
    for i = 1:nreal
        if rand <= pmut
            
            y = pop_mut(ind,i);
            yl = Xmin(i);
            yu = Xmax(i);
            
            delta1 = (y-yl) / (yu-yl);
            delta2 = (yu-y) / (yu-yl);
            
            rand_var = rand;
            mut_pow = 1.0/(eta_m+1.0);
            
            if rand_var <= 0.5
                xy = 1.0 - delta1;
                val = 2.0*rand_var + (1.0 - 2.0*rand_var) * xy^(eta_m+1.0);
                deltaq =  val^mut_pow - 1.0;
            else
                xy = 1.0 - delta2;
                val = 2.0*(1.0 - rand_var) + 2.0*(rand_var-0.5) * xy^(eta_m+1.0);
                deltaq = 1.0 - val^mut_pow;
            end
            y = y + deltaq*(yu - yl);
            
            % If Pumping Rate < 2 ML/yr , Q=0.0
            if (y<2.0), y = yl; end
            if (y>yu), y = yu; end
            
            pop_mut(ind,i) = y;
            nrealmut = nrealmut+1;
            
        end
    end
end