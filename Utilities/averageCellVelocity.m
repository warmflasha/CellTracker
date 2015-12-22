function [avgVel, avgTurn, counter]=averageCellVelocity(matfile,minperframe)

if ~exist('minperframe','var')
    minperframe = 1;
end

pp=load(matfile,'cells','peaks');

counter = zeros(length(pp.peaks),1); 
avgVel = counter; avgTurn = counter;

if ~isfield(pp,'cells')
    return;
end

cells = pp.cells;
for ii=1:length(cells)
    vels = cells(ii).data(2:end,1:2)-cells(ii).data(1:(end-1),1:2);
    mag_vels = sqrt(sum(vels.*vels,2))*minperframe;
    of = cells(ii).onframes(2:end);
    counter(of)=counter(of)+ones(length(of),1);
    avgVel(of) = avgVel(of)+mag_vels;
    
    turns = sum((vels(2:end,:).*vels(1:(end-1),:)),2)./mag_vels(2:end)./mag_vels(1:(end-1));
    of=of(2:end);
    avgTurn(of)=avgTurn(of)+turns;
    
    
end

avgVel = avgVel./counter;
avgTurn = avgTurn./counter;   
    