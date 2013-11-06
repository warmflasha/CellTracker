function [hits mm mm2 ncells ncells2]=trial1_v_trial2_simp(timepoint,plate)

direc = '~/Desktop/ScreenData';

if timepoint==1
    mat1= [direc filesep 'S5-MP-' int2str(plate) '.mat'];
    mat2= [direc filesep 'S6-MP-' int2str(plate) '.mat'];
elseif timepoint == 2
    mat1= [direc filesep 'S7-MP-' int2str(plate) '.mat'];
    mat2= [direc filesep 'S8-MP-' int2str(plate) '.mat'];
end

load(mat1);

for ii=1:384
    if ~isempty(outdatall{ii})
        mm(ii)=meannonan(outdatall{ii}(:,6)./outdatall{ii}(:,7));
        ncells(ii)=size(outdatall{ii},1);
    end
end

load(mat2)

for ii=1:384
    if ~isempty(outdatall{ii})
        mm2(ii)=meannonan(outdatall{ii}(:,6)./outdatall{ii}(:,7));
        ncells2(ii)=size(outdatall{ii},1);
    end
end
goodinds = ncells < 2000 & ncells2 < 2000 & ncells > 500 & ncells2 > 500;
mm_mean=mean([mm; mm2]);
if timepoint ==2
    hits = find(mm_mean > 1.15 & (mm > 1.18 | mm2 > 1.18)  & goodinds);
elseif timepoint == 1
    hits = find( ((mm_mean > 1.25 & (mm > 1.28 & mm2 > 1.28)) | (mm_mean < 1.1 & (mm < 1.08 | mm2 < 1.08))) & goodinds);
end
%figure;
%subplot(2,2,1); 
plot(mm(goodinds),mm2(goodinds),'r.','MarkerSize',18);
hold on; plot(mm(hits),mm2(hits),'k.','MarkerSize',18);
xlabel('Trial 1','FontSize',18);
ylabel('Trial 2','FontSize',18);


% 
% subplot(2,2,2); plot(ncells(goodinds),ncells2(goodinds),'r.');
% hold on; plot(ncells(hits),ncells(hits),'c.');
% 
% subplot(2,2,3); plot(ncells(goodinds),mm(goodinds),'r.');
% hold on; plot(ncells(hits),mm(hits),'c.');
% 
% subplot(2,2,4); plot(ncells2(goodinds),mm2(goodinds),'r.');
% hold on;plot(ncells2(hits),mm2(hits),'c.');