
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
% index - number of the peaks column to plot. If index has two components
% [ index(1) index(2)] - the ratio of the columns is plotted.
% nms2 - cell array of strings that specifies the conditions in each
% quadrant/ used as a label for the x axis
% param1 - label of the y-axis, input as a string, which peaks column you
% are plotting ans what it represents ( e.g. 'Sox2 expression');
% see also: Bootstrapping

function [toplot] = HistFromQuadrantsOfFullChip(Nplot,matfile,nms2,dims,midcoord,fincoord,index,param1);


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
    nlines=zeros(length(peaksnew),1);
    for ii=1:length(peaksnew)
        nlines(ii)=size(peaksnew{ii},1);
    end
    alllines = sum(nlines);
    alldata=zeros(alllines,1);
    q=1;
    for ii=1:length(peaksnew)
        if ~isempty(peaksnew{ii}) && size(peaksnew{ii},2)>10 %AN
            
            if length(index) == 1
                alldata(q:(q+nlines(ii)-1))=peaksnew{ii}(:,index);%
                
            else
                alldata(q:(q+nlines(ii)-1))=peaksnew{ii}(:,index(1))./peaksnew{ii}(:,index(2));%
                q=q+nlines(ii);
            end
            
        end
        subplot(2,2,j),t=histogram(alldata,'normalization','pdf','Facecolor','r');
        
        
    end

ylabel('PDF');
xlabel(param1);
legend(nms2{j});
    
end




