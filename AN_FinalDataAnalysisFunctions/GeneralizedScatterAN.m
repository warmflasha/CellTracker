
%see also: GetSeparateQuadrantImgNumbersAN,plotallanalysisAN,mkVectorsForScatterAN


function [b,c]=GeneralizedScatterAN(nms,nms2,dir,midcoord,fincoord,index2,param1,param2,plottype,flag3)


if plottype == 0
    q = 1;
    b = cell(1,size(nms,2));
    c = cell(1,size(nms,2));
    
    for k=1:size(nms,2)
        
        filename{k} = [dir filesep  nms{k} '.mat'];
        load(filename{k},'peaks','dims','plate1');
        
        for ii=1:length(peaks)
            if ~isempty(peaks{ii})
                szpeaks = size(peaks{ii},1);
                if flag3 ==0
                    b{k}(q:(q+szpeaks-1),1) = peaks{ii}(:,index2(1));
                    c{k}(q:(q+szpeaks-1),1) = peaks{ii}(:,index2(2));
                
                end 
                
                if isempty(flag3) || flag3 == 1
                b{k}(q:(q+szpeaks-1),1) = peaks{ii}(:,index2(1))./peaks{ii}(:,5);
                c{k}(q:(q+szpeaks-1),1) = peaks{ii}(:,index2(2))./peaks{ii}(:,5);
                
                end
                      q = q+szpeaks;          
            end
        end
        
        
    end
    
    
end
end



  