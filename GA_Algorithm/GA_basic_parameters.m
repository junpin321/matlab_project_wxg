function [opt] = GA_basic_parameters(opt)
%% -----Optimization Algorithm Parameters------------------------------------
    % Simulated Binary Crossover The value of distribution index for crossover (5-20)
    opt.eta_c = 15;   
    % Polynomial Mutation The value of distribution index for mutation (5-50)
    opt.eta_m = 20;  
    % Total Generation 
    opt.G  = 100;   
    %  Population size
    opt.N = 100;    
    % Crossover probability
    opt.pcross = 0.9;   
    % Numerical difference
    opt.Epsilon = 1.0E-14;   
    % Infinite maximum value
    opt.Inf = 1.0E+14;   
    % Maximum permissible Evalution Count
    opt.permitEval=inf;
    
%%  Intialize Variables Value
    % Initialize number of crossover performed
    opt.nrealcross = 0;    
    % Initialize number of mutation performed
    opt.nrealmut = 0;      
    % Initialize starting generation
    opt.gen = 1;  
    % Initial population
    opt.pop = [];              
    opt.popObj = [];
    % initial sample size for high fidelity computation
    opt.initpopsize = opt.N;                
    
%% Objective Function Parameters
    % Number of objectives
    opt.M = 1;
    % Number of variables
    opt.V = 20;
    % Number of constraints:  
    % Drawdown1 - SWRB, HHB, MB
    % Drawdown2 -  KB
    % Min KINC Head - KB
    % Dryout indicator - all borefields
    % Total Pumping Rate for all borefields  1-4
    opt.C = 8;
    % Variables Range
    opt.bound = zeros(2,opt.V);
    % Pumping Rate Unit // ML/yr --  Million Liter/ year = 10^3 m3/yr
    % Variables Lower Limits 
    opt.bound(1,:)=0.0;
    % Variables Upper Limits
    % Half Allocation
    %     opt.bound(2,:) =[175,175,175,...
    %         50,50,50,...
    %         250,250,250,250,250,250,250,250,250,250,...
    %         36.5,36.5,36.5,36.5];    
    
    % Full Allocatiojn
    opt.bound(2,:) =[200,200,200,...
        100,100,100,...
        350,350,350,350,350,350,350,350,350,350,...
        50,50,50,50];
    
    % Mutation probability    
    opt.pmut = 1.0/opt.V;  
    
    
    
end
