% plot distributions for live cell data
function [peaksnew1,peaksnew2] = histSignaling(fr_stim, resptime, index)
clear peaksnew1
clear peaksnew2
% count cells multiple times (use one time point
ff = dir('*_60X_testparam_allT.mat');%'*_3Dsegm_febdata*.mat'
q = 1;
peaksnew1 = [];
peaksnew2 = [];

for k=1:length(ff)
    outfile = ff(k).name; %nms{k};
    
    % outfile = ('12_3D_20hr_test_xyz.mat');
    load(outfile,'colonies','peaks');
    tps = length(peaks);
  
    for j=1:fr_stim
        sizenew  = size(peaks{j},1);
        if ~isempty(peaks{j})&& size(index,2)==1
        peaksnew1(q:(q+sizenew-1),1) = peaks{j}(:,index(1));%peaks{j}(:,6)./peaks{j}(:,7);
        q = q+sizenew;
        end
        if ~isempty(peaks{j})&& size(index,2)>1
        peaksnew1(q:(q+sizenew-1),1) = peaks{j}(:,index(1))./peaks{j}(:,index(2));% peaks{}(:,5) is the analogue of DAPI (for the GFPS4 cells this is RFP H2B
        q = q+sizenew;
        end
    end
    for j=(fr_stim+resptime):tps
        sizenew  = size(peaks{j},1);
        if ~ isempty(peaks{j})&& size(index,2)==1
        peaksnew2(q:(q+sizenew-1),1) = peaks{j}(:,index(1));
        q = q+sizenew;
        end
        if ~ isempty(peaks{j})&& size(index,2)>1
        peaksnew2(q:(q+sizenew-1),1) = peaks{j}(:,index(1))./peaks{j}(:,index(2));
        q = q+sizenew;
        end
    end
     
    
end
 peaksnew1(isinf(peaksnew1) == 1) = [];
 peaksnew1((peaksnew1) == 0) = [];
 peaksnew2(isinf(peaksnew2) == 1) = [];
 peaksnew2((peaksnew2) == 0) = [];
 histogram(peaksnew1,'Normalization','pdf');hold on
 histogram(peaksnew2,'Normalization','pdf'); 
%  ylim([0 3]);
%  xlim([0 3]);
 ylabel('Frequency');
 xlabel('mean Nuc/Cyto smad4');
 title('All microColonies');
 
end