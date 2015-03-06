% function to plot the histograms of the peaks' column (specified in the 'index'
% variable) separately for the sections(quadrants) of the Cytoo chip. Useful if the
% experimental conditions within the chip were different and the image
% aquisition was run in a single run;
% Output arguments:
% returns a cell array of imagenumbers (peaks numbers) to plot for each
% section of the chip.toplot cell array: toplot{1} - (1,1);toplot{2} -
% (1,2); toplot{3} - (2,1); toplot{4} - (2,2);( assuming the full chip is a
% matrix with four elements - quadrants - (1,1)(1,2)
%                                         (2,1)(2,2) 
% Input Arguments:
% matfile - single matfile obtained after running rufulltileMM on the full
% cytoo chip
% Nplot - number of parts of the chip to plot (usually 4)
% dims - dimensions of the chip in images
% midcoord - defines the imagenumbers which separate the two quadrants (1,1) and (1,2) in
% x direction (1,1) and (2,1) in y direction. Need to check these images while setting up the grid
% before aquisition
% fincoord - define the imagenumbers of the last images taken in x and y
% directions. Also need to check these and record while setting up the grid
% on the microscope.
% nms2 - cell array of strings that specifies the conditions in each
% quadrant/ used as a label for the x axis
% index = the column of the 'peaks' data to plot. if input
% only one number - get the plot of this column = not normalized data
% values; if input two numbers [index(1),index(2)], obtaine scatter plot of
% normalized index(1) (x axis) versus normalized index(2) (yaxis);Normalization
% to DAPI ( DAPI is assumed to be column 5 of peaks);
% need to be within the directory with the matfiles
% param1- name for the x axis in the final plot (depends on the meaning of
% the peaks columns, e.g. peaks{}(:,6) e.g., Cdx2 in a given experiment)
% param2 - name for the y axis in the filan plot

function [toplot] = ScatterFromQuadrantsOfFullChip(Nplot,matfile,nms2,dims,midcoord,fincoord,index,param1,param2);


%load(matfile);
load(matfile,'peaks');

xx=0:midcoord(1);
yy=0:midcoord(2);
[I, J]=meshgrid(xx,yy);
allpairs=[I(:) J(:)];
toplot{1} = sub2ind(dims,allpairs(:,1)+1,allpairs(:,2)+1); %

xx=(midcoord(1)+1):fincoord(1);
[I, J]=meshgrid(xx,yy);
allpairs=[I(:) J(:)];
toplot{2} = sub2ind(dims,allpairs(:,1)+1,allpairs(:,2)+1);

yy=(midcoord(2)+1):fincoord(2);
[I, J]=meshgrid(xx,yy);
allpairs=[I(:) J(:)];
toplot{4} = sub2ind(dims,allpairs(:,1)+1,allpairs(:,2)+1);

xx=0:midcoord(1);
[I, J]=meshgrid(xx,yy);
allpairs=[I(:) J(:)];
toplot{3} = sub2ind(dims,allpairs(:,1)+1,allpairs(:,2)+1);

for j=1:Nplot
    toplot{j}=toplot{j}(toplot{j} < length(peaks));
end

for j=1:Nplot
    peaksnew=[];
    for k=1:length(toplot{j})
        peaksnew{k} =  peaks{toplot{j}(k)};
        
    end
    %     [avgs, errs, alldat{j}]=Bootstrapping(peaksnew,100,1000,index);
    %     newdata(j,1)=avgs;
    %     newdata(j,2)=errs;
    colors = {'r','g','b','k'};
    valuesone =[];
    valuestwo=[];
    valuesthree=[];
    
    for ii=1:length(peaksnew)
        if ~isempty(peaksnew{ii}) && size(peaksnew{ii},2)>10 %AN
            
            if length(index) == 1
                valuesone =[valuesone; peaksnew{ii}(:,index(1))];%
                
            else
                valuestwo =[valuestwo; peaksnew{ii}(:,index(1))./peaksnew{ii}(:,5)];
                valuesthree =[valuesthree; peaksnew{ii}(:,index(2))./peaksnew{ii}(:,5)];
            end
            
        end
    end
        if length(index)==1
            subplot(2,2,j),plot(valuesone,colors{j},'marker','*');
        else
            subplot(2,2,j),scatter(valuestwo,valuesthree,colors{j}),legend(nms2{j});hold on
            
        end
    
    xlabel(param1);
    ylabel(param2);
    
   
end