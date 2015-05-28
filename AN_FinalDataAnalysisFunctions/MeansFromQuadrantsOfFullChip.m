
% function to plot the average values of the peaks' column (specified in the 'index1'
% variable) separately for the sections(quadrants) of the Cytoo chip. Useful if the
% experimental conditions within the chip were different and the image
% aquisition was run in a single run (from the full chip);
% Output arguments:
% returns a matrix of average values and corresponding errors
% Input Arguments:
% matfile - single matfile obtained after running rufulltileMM on the full
% cytoo chip
% Nplot - number of parts of the chip to plot (usually 4)
% midcoord - defines the imagenumbers which separate the two quadrants (1,1) and (1,2) in
% x direction (1,1) and (2,1) in y direction. Need to check these image numbers while setting up the grid
% before aquisition
% fincoord - define the imagenumbers of the last images taken in x and y
% directions. Also need to check these and record while setting up the grid
% on the microscope.( also they are obvious if use mkCytooPLotPeaks)
% index1 - specifies which peaks' column to use. If index has two components
% [ index1(1) index1(2)] - the ratio of the columns is plotted.
% nms2 - cell array of strings that specifies the conditions in each
% quadrant/ used as a label for the x axis
% param1 - label of the y-axis, input as a string, specifies which peaks' column you
% are plotting and what it represents ( e.g. 'Sox2 expression');
% see also: Bootstrapping

function [newdata] = MeansFromQuadrantsOfFullChip(Nplot,nms,nms2,midcoord,fincoord,index1,param1);

filename = ['.' filesep  nms{1} '.mat'];

[toplot,peaks] = GetSeparateQuadrantImgNumbersAN(Nplot,filename,midcoord,fincoord);

%load(filename,'peaks');
for j=1:Nplot
    peaksnew=[];
    for k=1:length(toplot{j})
        peaksnew{k} =  peaks{toplot{j}(k)};
        
    end
    [avgs, errs, alldat{j}]=Bootstrapping(peaksnew,100,1000,index1);
    newdata(j,1)=avgs;
    newdata(j,2)=errs;
    
end

limit2 = max(avgs)+3; % define the y axis limit

figure(1), errorbar(newdata(:,1),newdata(:,2),'r*') ;

set(gca,'Xtick',1:Nplot);
set(gca,'Xticklabel',nms2);

ylabel(param1);

ylim([0 limit2]);

end
