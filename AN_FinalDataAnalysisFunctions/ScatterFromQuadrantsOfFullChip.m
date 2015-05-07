% function to plot the histograms of the peaks' column (specified in the 'index2'
% variable) separately for the sections(quadrants) of the Cytoo chip. Useful if the
% experimental conditions within the chip were different and the image
% aquisition was run in a single run;
% Output arguments:
% returns two vectors: valuestwo - x axis data
% valuesthree - y axis data
% Input Arguments:
% 
% Nplot - number of parts of the chip to plot (usually 4)
% midcoord - defines the imagenumbers which separate the two quadrants (1,1) and (1,2) in
% x direction (1,1) and (2,1) in y direction. Need to check these images while setting up the grid
% before aquisition
% fincoord - define the imagenumbers of the last images taken in x and y
% directions. Also need to check these and record while setting up the grid
% on the microscope.
% nms2 - cell array of strings that specifies the conditions in each
% quadrant/ used as a label for the x axis
% index2 = the column(s) of the 'peaks' data to plot. if input
% only one number - get the plot of this column = not normalized data
% values; if input two numbers [index2(1),index2(2)], obtain scatter plot of
% normalized index2(1) (x-axis) versus normalized index2(2) (y-axis);Normalization
% to DAPI ( DAPI is assumed to be column 5 of peaks);
% need to be within the directory with the matfiles
% param1- name for the x axis in the final plot (depends on the meaning of
% the peaks columns, e.g. peaks{}(:,6) e.g., Cdx2 in a given experiment)
% param2 - name for the y axis in the final plot

function [valuestwo,valuesthree] = ScatterFromQuadrantsOfFullChip(Nplot,nms,nms2,midcoord,fincoord,index2,param1,param2);

filename = ['.' filesep  nms{1} '.mat'];

load(filename);

[toplot,peaks] = GetSeparateQuadrantImgNumbersAN(Nplot,filename,midcoord,fincoord);

for j=1:Nplot
    peaksnew=[];
    for k=1:length(toplot{j})
        peaksnew{k} =  peaks{toplot{j}(k)};
        
    end
    
    
    colors = {'r','g','b','k'};
    valuesone =[];
    valuestwo=[];
    valuesthree=[];
    valuescmap = [];
    for ii=1:length(peaksnew)
        if ~isempty(peaksnew{ii}) ;
            
            if length(index2) == 1
                valuesone =[valuesone; peaksnew{ii}(:,index2(1))];%
                
            else
                valuestwo =[valuestwo; peaksnew{ii}(:,index2(1))./peaksnew{ii}(:,5)];        % the values on the x-axis of the resulting plot
                valuesthree =[valuesthree; peaksnew{ii}(:,index2(2))./peaksnew{ii}(:,5)];    % the values on the y-axis of the resulting plot
                if length(index2) > 2
                    valuescmap =[valuescmap; peaksnew{ii}(:,index2(3))./peaksnew{ii}(:,5)];
                    
                end
            end
            
        end
    end
    limit1(j) = max(valuestwo);
    limit2(j) = max(valuesthree);
    
    
    if length(index2)==1
        figure(2),  subplot(2,2,j),scatter(valuesone,colors{j},'marker','*');
        
    else
        
        figure(2), subplot(2,2,j),scatter(valuestwo,valuesthree,colors{j},'marker','*'),legend(nms2{j});hold on
        
        if length(index2) > 2
            figure(2),  subplot(2,2,j),scatter(valuestwo,valuesthree,[],valuescmap),legend(nms2{j});hold on
            
        end
        
        
    end
    
    xlabel(param1);
    ylabel(param2);
end
limit1 = max(limit1);
limit2 = max(limit2);
for j=1:Nplot
    figure(2),  subplot(2,2,j)
    xlim([0 limit1]);
    ylim([0 limit2]);
end

end
