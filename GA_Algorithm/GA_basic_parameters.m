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
    % Number of variables (Decision Variables)
    % 7 Groups defined in 2000.wel
    opt.V = 7;

    % Number of constraints:
    % 1. Dry Cell Indicator
    opt.C = 1;

    % Variables Range
    opt.bound = zeros(2,opt.V);

    % Variables Lower Limits (Multiplier)
    opt.bound(1,:)=0.0;

    % Variables Upper Limits (Multiplier)
    % Allow up to 2x the base pumping rate defined in 2000.wel
    opt.bound(2,:) = 2.0;

    % Mutation probability
    opt.pmut = 1.0/opt.V;

end
