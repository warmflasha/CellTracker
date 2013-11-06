function [hits mm mm2 ncells ncells2]=trial1_v_trial2(timepoint,plate)

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
goodinds = ncells < 2000 & ncells2 < 2000 & ncells > 300 & ncells2 > 500;
% if timepoint ==2
%     hits = find(mm2 > 1.15 & mm > 1.15 & goodinds);
% elseif timepoint == 1
%     hits = find( ((mm > 1.26 & mm2 > 1.26) | (mm < 1.1 & mm2 < 1.1)) & goodinds);
% end

zsc1=(mm-mean(mm(goodinds)))/std(mm(goodinds));
zsc2=(mm2-mean(mm2(goodinds)))/std(mm2(goodinds));

hits = abs(zsc1) > 2 & abs(zsc2) > 2 & goodinds;


figure;
subplot(2,2,1); plot(mm(goodinds),mm2(goodinds),'r.');
hold on; plot(mm(hits),mm2(hits),'c.');

subplot(2,2,2); plot(ncells(goodinds),ncells2(goodinds),'r.');
hold on; plot(ncells(hits),ncells(hits),'c.');

subplot(2,2,3); plot(ncells(goodinds),mm(goodinds),'r.');
hold on; plot(ncells(hits),mm(hits),'c.');

subplot(2,2,4); plot(ncells2(goodinds),mm2(goodinds),'r.');
hold on;plot(ncells2(hits),mm2(hits),'c.');