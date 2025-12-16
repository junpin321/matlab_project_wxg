%This function plots population of each generation with different color
function plot_population(GEN,popObj,optfig)
%%
    figure(optfig);
    [optV,LocV]=max(popObj);
    N=size(popObj,1);
    scatter(1:N,popObj,12,'filled','MarkerEdgeColor',...
        [0.6,0.6,0.6],'MarkerFaceColor',[0.7 0.0 0.0]) ;hold on;grid minor;
    scatter(LocV,optV,20,'filled','MarkerEdgeColor',...
        [0.6,0.6,0.6],'MarkerFaceColor',[0.0 1.0 0.0]);grid minor;
    title(['Evol. Generation:',num2str(GEN)]);
    hold off;
    drawnow;
    
end