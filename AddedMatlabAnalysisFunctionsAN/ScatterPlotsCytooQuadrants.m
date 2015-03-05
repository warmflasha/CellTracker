
% function plots the scatter plots for four different quadrants of the
% cytoo chip. Useful if the data was collected separately/or needs to be ploted 
% from separate mat files.
% Cytoo chip. The imput arguments are: 
% Nplot = number of matfiles to process/and number of subplots in the figure
% nms =   cell array of strings with the full names of the matlab files containing all the data. Do not specify the 'mat'
%         extension
% nms2 =  cell array of strings with the names of the experimentsl conditions
% corresponding to each matfile/quadrant of the chip. The same strings
% appear as a legend of the plots
% col = the column of the 'peaks' data to plot from each matfile. if input
% only one number - get the plot of this column = not normalized data
% values; if input two numbers [col(1),col(2)], obtaine scatter plot of
% normalized col(1) (x axis) versus normalized col(2) (yaxis);Normalization
% to DAPI ( DAPI is assumed to be column 5 of peaks);
% need to be within the directory with the matfiles
% param1- name for the x axis in the final plot (depends on the meaning of
% the peaks columns, e.g. peaks{}(:,6) may correspond to Cdx2 in a given experiment)
% param2 - name for the y axis in the filan plot
function ScatterPlotsCytooQuadrants(Nplot,nms,nms2,col,param1,param2);

for xx=1:Nplot
    
    filename = ['.' filesep nms{xx} '.mat'];%
    load(filename,'peaks');
   % disp(['loaded file: ' filename]);

    colors = {'r','g','b','k'};
    valuesone =[];
    valuestwo=[];
    valuesthree=[];
   
    
    for ii=1:length(peaks)
        if ~isempty(peaks{ii}) && size(peaks{ii},2)>10 % this condition is added to avoid analysis of incomplete files
            if length(col)==1
                valuesone =[valuesone; peaks{ii}(:,col(1))];
            else 
                valuestwo =[valuestwo; peaks{ii}(:,col(1))./peaks{ii}(:,5)];
                valuesthree =[valuesthree; peaks{ii}(:,col(2))./peaks{ii}(:,5)];
            end
        end
   
    end
    if length(col)==1
        subplot(2,2,xx),plot(valuesone,colors{xx},'marker','*'), legend(nms2{xx});
        
    else
         subplot(2,2,xx),scatter(valuestwo,valuesthree,colors{xx}), legend(nms2{xx});hold on
    end
   
    
    
    %xlabel(['Column ',num2str(col(1)),' of peaks data']);
    xlabel(param1);
    ylabel(param2);
        
end



  
