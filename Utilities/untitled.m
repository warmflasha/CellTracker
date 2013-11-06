function plotwcontrols(matfile)

load(matfile);

for ii=1:length(outdatall)
    if(~isempty(outdatall{ii}))
        mm(ii)=meannonan(outdatall{ii}(:,6)./outdatall{ii}(:,7));
    end
end

plot(mm,'r.')

pcinds=48:48:384;
hold on;
plot(pcinds,mm(pcinds),'g.');
ncinds=36:48:372;
plot(ncinds,mm(ncinds),'b.');
s4cont=26:48:362;
plot(s4cont,mm(s4cont),'c.');

indshi = find(mm > 1.35);
indslo = find(mm < 0.95);

indshi_check=setdiff(indshi,pcinds);
indslo_check=setdiff(indslo,[ncinds s4cont]);