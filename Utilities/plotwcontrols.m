function plotwcontrols(matfile)

load(matfile);

for ii=1:length(outdatall)
    if(~isempty(outdatall{ii}))
        mm(ii)=meannonan(outdatall{ii}(:,6)./outdatall{ii}(:,7));
    end
end

plot(mm,'r.','MarkerSize',12)

pcinds=48:48:384;
hold on;
plot(pcinds,mm(pcinds),'g.','MarkerSize',12);
ncinds=36:48:372;
plot(ncinds,mm(ncinds),'b.','MarkerSize',12);
s4cont=26:48:362;
plot(s4cont,mm(s4cont),'c.','MarkerSize',12);

xlabel('Well','FontSize',20);
ylabel('Ratio nuc:cyt Smad4','FontSize',20);



indshi = find(mm > 1.35);
indslo = find(mm < 0.99);

indshi_check=setdiff(indshi,pcinds);
indslo_check=setdiff(indslo,[ncinds s4cont]);