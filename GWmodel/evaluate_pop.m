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
% Output Constraint condition by running Modflow
for i=1:sz
    % gwmodel returns [DryCellFlag, TotalPumpingRate]
    result = gwmodel(pop(i,:));

    % Store Dry Cell Flag in popCons column 1
    popCons(i,1) = result(1);

    % The second element is the Total Pumping Rate (Volume/Day or Total Volume)
    TotalPumping = result(2);

    % Calculate Constraints violation
    g = 0;
    if popCons(i,1) == 1
        g = 1;
    end

    % Maximizing Total Pumping Rate -- Penalty function
    % popObj is Maximized. If library minimizes, we should return -val.
    % Assuming existing code maximizes because it adds negative penalty.
    popObj(i,1) = TotalPumping + g * (-1.0e+06);
end

% CV -- Constraint Violation Count
popCV = sum(popCons(:,1), 2); % Only 1 constraint (Dry Cell)

end
