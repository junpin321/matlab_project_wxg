%This is main function that runs GA procedure
function opt = GA_main(opt)
%% ------------INITIALIZE POPULATION-------------------
   % Generate Initial Population using Latin Hypercube Sample 
   opt.initialpop=lhsample(opt.bound(2,:),opt.bound(1,:),opt.N);
   opt.initialobj=zeros(opt.N,opt.M);
   [opt.initialobj, opt.initialCons, opt.initialCV] = evaluate_pop(opt, opt.initialpop);  
   
   opt.popObj =opt.initialobj ;          
   opt.pop = opt.initialpop;                   
   opt.popCV = opt.initialCV;          
   opt.popCons = opt.initialCons;        
   
   opt.archivepopObj=opt.popObj;
   opt.archivepop=opt.pop;
   opt.archivepopCV=opt.popCV;
   opt.archivepopCons=opt.popCons;
   
   
       %% -------------------- Optimization Starting -------------------------------
        %  Generation # 1 to Generation # N
        while opt.gen <= opt.G 
            
            %------Mating Parent Selection // Binary constraint tournament selection
            opt.popChild = selection(opt, opt.pop, opt.popObj);
            %-------------------Crossover-----------------                     
            [opt.popChild, opt.nrealcross] = sbx(opt.popChild, opt.pcross, opt.nrealcross, opt.eta_c, opt.bound(1,:), opt.bound(2,:), opt.Epsilon);
            %-------------------Mutation------------------
            [opt.popChild, opt.nrealmut] = pol_mut(opt.popChild, opt.pmut, opt.nrealmut,  opt.eta_m,  opt.bound(1,:), opt.bound(2,:) );
            %---------------Evalution----------------------
            [opt.popChildObj, opt.popChildCons, opt.popChildCV] = evaluate_pop(opt, opt.popChild);
            
            %--------------- Archive evolutionary Individuals------------------
            %---------Concatenate arrays vertically------------------------------
            opt.archivepopObj = vertcat(opt.archivepopObj,opt.popChildObj);          % Total Objection Function Value
            opt.archivepop = vertcat(opt.archivepop,opt.popChild);                            % Total Population Individals
            opt.archivepopCV = vertcat(opt.archivepopCV,opt.popChildCV);            % Total Constrain Violation Count 
            opt.archivepopCons = vertcat(opt.archivepopCons,opt.popChildCons);    % Total Constrain Function Value
            
            opt.popObj=opt.popChildObj;
            opt.pop=opt.popChild;
            opt.popCV=opt.popChildCV;
            opt.popCons=opt.popChildCons;
            
            
          %% ------------PLOT NEW SOLUTIONS-------
            disp(['Evol Generation:',num2str(opt.gen)]);
            
            opt.gen=opt.gen+1;
            
            % Save optimization results for every generation
            save optimizationData.mat opt
            
            
            
        end
        
        
        
end
