function [mm ncells]=readPlateData(mat1)

load(mat1);
mm=zeros(384,1);
ncells=zeros(384,1);

for ii=1:384
    if ~isempty(outdatall{ii})
        mm(ii)=meannonan(outdatall{ii}(:,6)./outdatall{ii}(:,7));
        ncells(ii)=size(outdatall{ii},1);
    end
end