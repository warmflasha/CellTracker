
% function to plot mean values of the peaks columnd from the outall
% matfiles obtained after running runFUllTileMM segmentation.
% midcoord,fincoord are optional and are used only if plottype = 1 ( you
% need to separate the chip into the quadrants). They correspond to
% imagenumbers delimiting the different quadrants of the chip). If not
% supplied, then the code devides the chip into quadrants automatically (
% see code and description of the MMrunScriptsAN


function [newdata] = GeneralizedMeanAN(nms,nms2,dir,midcoord,fincoord,index1,param1,plottype,flag)

if plottype == 1
    for k=1:size(nms,2)                                 % load however many files are in the nms string
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks','dims');
        %disp(['loaded file: ' filename{k}]);
        
    end
    [toplot,peaks] = GetSeparateQuadrantImgNumbersAN(nms2,peaks,dims,midcoord,fincoord);
    
    for k=1:size(toplot,2)
        peaksnew=[];
        for j=1:length(toplot{k})
            peaksnew{j} =  peaks{toplot{k}(j)};
            
        end
        [avgs, errs, alldat{k}]=Bootstrapping(peaksnew,100,1000,index1);
        newdata(k,1)=avgs;
        newdata(k,2)=errs;
    end

    if flag == 1
    figure (1),errorbar(newdata(:,1),newdata(:,2),'b*') ;
    
    set(gca,'Xtick',1:size(nms2,2));
    set(gca,'Xticklabel',nms2);
    limit2 = max(newdata(:,1))+1;
    ylim([0 limit2]);
    
    if size(index1) == 1
        ylabel(param1);
    else
        ylabel([param1,'/DAPI']);
    end
    end
end

if plottype == 0
    for k=1:size(nms,2)        % load however many files are in the nms string
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks','plate1');
        disp(['loaded file: ' filename{k}]);
        %
        [avgs, errs, alldat{k}]=Bootstrapping(peaks,100,1000,index1);
        newdata(k,1)=avgs;
        newdata(k,2)=errs;
    end
    if flag == 1
    figure(1),errorbar(newdata(:,1),newdata(:,2),'b*') ;
    
    set(gca,'Xtick',1:size(nms2,2));
    set(gca,'Xticklabel',nms2);
    limit2 = max(newdata(:,1))+0.5;
    ylim([0 limit2]);
    
    if size(index1) == 1
        ylabel(param1);
    else
        ylabel([param1,'/DAPI']);
    end
    end
end
end

