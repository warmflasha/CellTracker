% function to obtain scatter plots from the separate matfiles.
% all input arguments are described in plotallanalysisAN. and see code for GetSeparateQuadrantImgNumbersAN
%
%see also: GetSeparateQuadrantImgNumbersAN,plotallanalysisAN,mkVectorsForScatterAN


function [b,c]=GeneralizedScatterAN(nms,nms2,dir,midcoord,fincoord,index2,param1,param2,plottype)
colors = {'r','g','b','k','m','r','c'};
if plottype == 1 % need to separate into quadrants
    for k=1:size(nms,2)
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks','dims');
        %disp(['loaded file: ' filename{k}]);
        [toplot,peaks] = GetSeparateQuadrantImgNumbersAN(nms2,peaks,dims,midcoord,fincoord);
    end
    
    for j=1:size(toplot,2)
        peaksnew=[];
        for k=1:length(toplot{j})
            peaksnew{k} =  peaks{toplot{j}(k)};
        end
        [a,b,c,d] = mkVectorsForScatterAN(peaksnew,index2);
        
        limit1(j) = max(b);  % determinemax value in each vector for each axis
        limit2(j) = max(c);
        
        if length(index2)==1
            figure(2),  subplot(1,size(nms2,2),j),plot(a,colors{j},'marker','*'), legend(nms2{j});
        else
            figure(2), subplot(1,size(nms2,2),j),scatter(b,c,colors{j}), legend(nms2{j});hold on  % b = x-axis data; c = y-axis data
        end
        if length(index2)>2
            figure(2),  subplot(1,size(nms2,2),j),scatter(b,c,[],d), legend(nms2{j});hold on
        end
        
        xlabel(param1);
        ylabel(param2);
    end
    limit1 = max(limit1);
    limit2 = max(limit2);
    for xx=1:size(nms2,2)
        figure(2), subplot(1,size(nms2,2),xx)
        
        xlim([0 limit1]);
        ylim([0 limit2]);
    end
end

if plottype == 0
    for k=1:size(nms,2)
        
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks','dims');
        [a,b,c,d] = mkVectorsForScatterAN(peaks,index2);
        
        limit1(k) = max(b);
        limit2(k) = max(c);
        
        if length(index2)==1
            figure(2),  subplot(1,size(nms2,2),k),plot(a,colors{k},'marker','*'), legend(nms2{k});
        else
            figure(2), subplot(1,size(nms2,2),k),scatter(b,c,colors{k}), legend(nms2{k});hold on  % b = x-axis data; c = y-axis data
        end
        if length(index2)>2
            figure(2),  subplot(1,size(nms2,2),k),scatter(b,c,[],d), legend(nms2{k});hold on
        end
        
        xlabel(param1);
        ylabel(param2);
        
    end
    limit1 = max(limit1);
    limit2 = max(limit2);
    for xx=1:size(nms2,2)
        figure(2), subplot(1,size(nms2,2),xx)
        
        xlim([0 limit1]);
        ylim([0 limit2]);
    end
end
end



  