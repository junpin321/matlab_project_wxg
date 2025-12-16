function Y=lhsample(xu,xl,n)
%% Input variables : 
% x ---Input decision variables
% xu(1:m)---variables upper limits
% xl(1:m)---variables low limits
% n ---Sample points
% m ---decesion variables numbers 
m=size(xu,2);
% Generate a latin hypercube of N datapoints in the M-dimensional hypercube
X = lhsdesign(n,m);
Y=zeros(n,m);

for i=1:m
    Y(:,i)=X(:,i).*(xu(i)-xl(i))+xl(i);
end

% < 2 ML/yr === 0.0 ML/yr
for i=1:n
    for j=1:m
        if Y(i,j)<2.0
            Y(i,j)=0.0;
        end
    end
end

end
