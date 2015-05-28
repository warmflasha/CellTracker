
% function plots the mean values of the specified columns of peaks for four different quadrants of the
% cytoo chip ( or for any Nplot number of matfiles).
% Useful if the data was collected separately/or needs to be ploted
% from separate mat files.
% The input arguments are:
% Nplot = number of matfiles to process/and number of subplots in the figure
% nms =   cell array of strings with the full names of the matlab files containing all the data. Do not specify the 'mat'
%         extension
% nms2 =  cell array of strings with the names of the experimental conditions
% corresponding to each matfile/quadrant of the chip. The same strings
% appear as a legend of the plots
% index1 = the column of the 'peaks' data to plot from each matfile. if input
% only one number - get the mean of this column = not normalized data
% values; if input two numbers [index1(1) ,index1 (2)], obtain the mean for
% the ratio of peaks' data (index1(1)/index1(2); usually normalize to DApi, make
% index1(2) = 5;need to be within the directory with the matfiles
% param1 - y label;depends on the 'meaning' of the peaks' column in a a given experiment 
%
% see also: Bootstrapping

function [newdata] = MeanCytooQuadrants(Nplot,nms,nms2,index1,param1)

for k=1:Nplot
    
    filename = ['.' filesep nms{k} '.mat'];%
    load(filename,'peaks');
    disp(['loaded file: ' filename]);
      
    
    [avgs, errs, ~]=Bootstrapping(peaks,100,1000,index1);
    newdata(k,1)=avgs;
    newdata(k,2)=errs;
end
limit2 = max(avgs)+1;
figure (1),errorbar(newdata(:,1),newdata(:,2),'b*') ;

set(gca,'Xtick',1:Nplot);
set(gca,'Xticklabel',nms2);
    
    ylim([0 limit2]);

if size(index1) == 1
    ylabel(param1);
else
    ylabel([param1,'/DAPI']);
end

end


   


