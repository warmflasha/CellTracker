
% function plots the scatter plots for four different quadrants of the
% cytoo chip. Useful if the data was collected separately/or needs to be ploted 
% from separate mat files.
%   [valuestwo,valuesthree]=ScatterPlotsCytooQuadrants(Nplot,nms,nms2,index2,param1,param2)
% Output:
% two vectors of normalized to dapi data corresponding to the columns of
% peaks{} of interest: valuestwo = specifies the x-axis and is defined by
% index2(1)
% valuesthree = specifies the y-axis and is defined by
% index2(2)
% Input: 
% Nplot = number of matfiles to process/and number of subplots in the figure
% nms =   cell array of strings with the full names of the matlab files containing all the data. Do not specify the 'mat'
%         extension
% nms2 =  cell array of strings with the names of the experimentsl conditions
% corresponding to each matfile/quadrant of the chip. The same strings
% appear as a legend of the plots
% index2 = the column of the 'peaks' data to plot from each matfile. if input
% only one number - get the plot of this column = not normalized data
% values; if input two numbers [index2(1),index2(2)], obtain scatter plot of
% normalized index2(1) (x-axis) versus normalized index2(2) (y-axis);Normalization
% to DAPI ( DAPI is assumed to be column 5 of peaks);
% need to be within the directory with the matfiles
% param1- name for the x axis in the final plot (depends on the meaning of
% the peaks' columns, e.g. peaks{}(:,index2(1)) may correspond to Cdx2 in a given experiment)
% param2 - name for the y axis in the final plot (depends on the meaning of
% the peaks' columns, e.g. peaks{}(:,index2(2)) may correspond to another gene a given experiment)
% see also: MeanCytooQuadrants
function [valuestwo,valuesthree]=ScatterPlotsCytooQuadrants(Nplot,nms,nms2,index2,param1,param2)

for xx=1:Nplot
    
    filename = ['.' filesep nms{xx} '.mat'];%
    load(filename,'peaks');
   % disp(['loaded file: ' filename]);
    
    colors = {'r','g','b','k'};
    valuesfour = [];
    valuesone =[];
    valuestwo=[];
    valuesthree=[];
    
    
    for ii=1:length(peaks)
        if ~isempty(peaks{ii})
            if length(index2)==1
                valuesone =[valuesone; peaks{ii}(:,index2(1))];
            else
                valuestwo =[valuestwo; peaks{ii}(:,index2(1))./peaks{ii}(:,5)];          % data plotted on the x axis
                valuesthree =[valuesthree; peaks{ii}(:,index2(2))./peaks{ii}(:,5)];      % data plotted on the y axis
                if length(index2) > 2
                    valuesfour = [valuesfour; peaks{ii}(:,index2(3))./peaks{ii}(:,5)];
                end
            end
        end
        
    end
    limit1(xx) = max(valuestwo);
    limit2(xx) = max(valuesthree);
    
    if length(index2)==1
        figure(2),  subplot(2,2,xx),plot(valuesone,colors{xx},'marker','*'), legend(nms2{xx});
        
    else
        figure(2), subplot(2,2,xx),scatter(valuestwo,valuesthree,colors{xx}), legend(nms2{xx});hold on
    end
    if length(index2)>2
        figure(2),  subplot(2,2,xx),scatter(valuestwo,valuesthree,[],valuesfour), legend(nms2{xx});hold on
    end
    
    
    xlabel(param1);
    ylabel(param2);
    
end
limit1 = max(limit1);
limit2 = max(limit2);
for xx=1:Nplot
    figure(2), subplot(2,2,xx)
    
    xlim([0 limit1]);
    ylim([0 limit2]);
end
end


  
