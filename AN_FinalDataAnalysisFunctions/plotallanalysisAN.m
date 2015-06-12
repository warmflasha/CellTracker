%
% Generalized function to plot infomation from number of outall
% files.The number of outall files = size of the 'nms' string
% plottype = parameter that determines whether the data needs to be devided
% into the quadrants
% plottype = 1 need to devide into quadrants: generate 'toplot,'peaksnew'
% and 'coloniesnew' within the respective functions. ( this is not
% optimized for the case if you have more than one file to separate into
% quadrants
% plottype = 0 treat all outall matfiles separately
% thresh - used in the GeneralizedColonyAnalysisAN function; determined
% based on scatter plots
% nms2 - strin specifying the experimental conditions for the separate
% matfiles or the quadrants within the single outall file.
% index1 - specifies which peaks' column to use for y-value of the means plot  If index has two components
% [ index1(1) index1(2)] - the ratio of the columns is plotted (usually index1(2) is DAPI).
% index2 = the columns of the 'peaks' data to plot from the matfile. if input
% only one number - get the plot of this column = not normalized data; If
% imput it as a 2-col vector index2(1) index2(2) then these are the x and y
% values of the scatter plot respectively
% param1 - label of the y-axis for the mean values plot ( and the x-axis in
% the scatter plots), input as a string; corresponds to the index1(1) and index2(1) values above;
% param2 - label of the y-axis of the scatter plot; corresponds to the
% index2(2) parameter above
% flag = specifies whether to display the plots of the colony-wise
% annalysis

function [] = plotallanalysisAN(thresh,nms,nms2,midcoord,fincoord,index1,index2,param1,param2,plottype,flag)

if   ~exist('plottype','var') 
    disp('Error: specify whether to devide the outall file into the quadrants (plottype var)') %error
    return
end
if    plottype==0 && size(nms2,2)>1 && size(nms,2) == 1
    error('Error:if nms2 >1 but you only have one outfile, you must separate into quadrants')
    
end
if    plottype==1 && size(nms,2) > 1
    error('Do such analysis for each file separately ( with size(nms,2) = 1 and plottype = 1)')
    
end

[newdata] = GeneralizedMeanAN(nms,nms2,midcoord,fincoord,index1,param1,plottype);
[b,c] =     GeneralizedScatterAN(nms,nms2,midcoord,fincoord,index2,param1,param2,plottype);
[~,~,~] = GeneralizedColonyAnalysisAN(thresh,nms,nms2,midcoord,fincoord,index1,param1,plottype,flag);
[rawdata] =  Intensity_vs_ColSize(nms,nms2,index1,param1);

end






 
    




      