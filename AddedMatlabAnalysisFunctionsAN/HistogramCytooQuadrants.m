
% function plots the histograms for four different quadrants of the
% cytoo chip. Useful if the data was collected separately/or needs to be ploted
% from separate mat files.
% The input arguments are:
% Nplot = number of matfiles to process/and number of subplots in the figure
% nms =   cell array of strings with the full names of the matlab files containing all the data. Do not specify the 'mat'
%         extension
% nms2 =  cell array of strings with the names of the experimental conditions
% corresponding to each matfile/quadrant of the chip. The same strings
% appear as a legend of the plots
% col = the column of the 'peaks' data to plot from each matfile. if input
% only one number - get the plot of this column = not normalized data
% values; if input two numbers [col(1),col(2)], obtain the histogram for
% the ratio of peaks data (col)1)/col(2); usually normalize to DApi, make
% col(2) = 5;
% param1 - the  label of the y axis, string 'name' 
% need to be within the directory with the matfiles
%
function HistogramCytooQuadrants(Nplot,nms,nms2,col,param1);

for k=1:Nplot
    
    filename = ['.' filesep nms{k} '.mat'];%
    load(filename,'peaks');
    % disp(['loaded file: ' filename]);
    
    colors = {'r','g','b','k'};
    
    nlines=zeros(length(peaks),1);
    for ii=1:length(peaks)
        nlines(ii)=size(peaks{ii},1);
    end
    alllines = sum(nlines);
    alldata=zeros(alllines,1);
    q=1;
    for ii=1:length(peaks)
        if ~isempty(peaks{ii}) && size(peaks{ii},2)>10 %AN
            
            if length(col) == 1
                alldata(q:(q+nlines(ii)-1))=peaks{ii}(:,col);%
                
            else
                alldata(q:(q+nlines(ii)-1))=peaks{ii}(:,col(1))./peaks{ii}(:,col(2));%
                q=q+nlines(ii);
            end
            
        end
        subplot(2,2,k),j=histogram(alldata,'normalization','pdf','Facecolor','r');
        
        
    end
    ylabel(param1);
    legend(nms2{k});
    title(['Dataset',nms]);
    
end
