ps={'k.-','r.-','g.-','b.-','g.-'};
figure; hold on;
%xx=[1 3 5 7 8];
clear mm tt nc;
xx=1:8;
direc='131101_GFPS4_MAN1';
for kk=[1:8]
    ii=xx(kk);
    for jj=1:6
        [pa tim]=peaksAverage([direc filesep 'S' int2str(ii) 's' int2str(jj) 'out.mat'],[6 7]);
        mm{ii}(jj,:)=pa;
         tt{ii}(jj,:)= tim;
        numC=numCellsVsTime([direc filesep 'S' int2str(ii) 's' int2str(jj) 'out.mat'],'k.-');
        nc{ii}(jj,:)=numC;
    end
end
%%
figure; hold all;
for kk=[1 5]
%for kk=[3 4 5 8]
    ii=xx(kk);
   plot(meannonan(tt{ii}),meannonan(mm{ii}),'.-','LineWidth',2);
   %plot(meannonan(tt{ii}),meannonan(nc{ii}),'.-','LineWidth',2);
    %errorbar(meannonan(tt{ii}),meannonan(nc{ii}),std(nc{ii}));

    %errorbar(meannonan(tt{ii}),meannonan(mm{ii}),std(mm{ii}),'LineWidth',2);
    %legend({'DAPT (2.5 uM)','YIL781 (10uM)','LY294002 (10 uM)', 'PD173074 (250 nM)','Scgb1A1 (1 ug/ml)','no stim','Scgb 3A1 (1 ug/ml)','TGFb only'});
    %legend({'TGFb only','no stim','LDN','LY','YIL','DAPT (2.5 uM)','IWR','Insulin'});
    %legend({'TGFb only','DAPT','LY','YIL'},'FontSize',14,'Location','NorthWest');
end
xlabel('time','FontSize',22);
xlim([2 21]);
ylabel('Nuc:Cyt GFP-Smad4','FontSize',22);
%legend({'Control','Man1'},'FontSize',22);
%legend({'dense -- +T','dense -- +T,+5Z','sparse -- +T','sparse -- +T,+5Z'});

%legend({'TGFb+MekI','TGFb only','No Treatment','TGFb+FGFRI','TGFb+PI3KI'},'FontSize',16);
%legend({'1uM','0.25uM','0.1uM','0.01uM','0 uM'},'FontSize',16);
%legend({'-dox','+dox'});

%legend({'0.01','0.03','0.06','0.1','0.3','0.6','1','3'},'FontSize',16);
%ylabel('Cell density','FontSize',18);

% for ii=6:8
%     plot(meannonan(tt{ii}(:,1:60)),meannonan(mm2{ii}(:,6:65)),'.-','LineWidth',2);
% end
%
legend({'Control','tt-coco,0.6 ug/ml dox','tt-coco,2 ug/ml dox'},'FontSize',16,'Location','NorthEast');
%title('1 ng/ml','Fontsize',18);
%legend({'si-Control','si-Htt'},'FontSize',14,'Location','NorthEast'); 
%xlim([0 21]);
%legend({'+TGFb','+TGFb+5Z 10uM','+TGFb+5Z 1um','+5Z 10um'});
%legend({'5Z','5Z+LDN+SB','5Z+PD','5Z+3i'},'FontSize',14);
%saveas(gcf,'5ZDoseResponse.fig');

%legend({'+TGFb','+TGFb,+MekI,+JnkI','+TGFb,MekI','+TGFb,+JnkI,+p38I','+TGF,+3i'},'FontSize',14,'Location','NorthWest');

%saveas(gcf,'Exp130215.eps','psc2');

%legend({'TGFb','+IWR','+CHIR'});
%saveas(gcf,'~/Desktop/MEKI.eps','psc2');
%legend({'DAPT','LY','IGFII','Unstim'});
%legend({'1','2','4','5','6','7','8'});
%legend({'+TGFb','+TGFb,+PD','+TGFb,+PD,+LY','+TGFb,+5Z'},'FontSize',14); xlim([0 45]);
%%
cc=colorcube(12);
figure; hold all;
for ii=1:4
    plot(mean(tt{ii}),mean(nc{ii}),'.-','Color',cc(ii,:));
    %errorbar(mean(tt{ii}),mean(nc{ii}),std(nc{ii}),'Color',cc(ii,:));
end
legend({'DAPT','LY','IGF2','Unstim'});

%legend({'DAPT (2.5 uM)','YIL781 (10uM)','LY294002 (10 uM)', 'PD173074 (250 nM)','Scgb1A1 (1 ug/ml)',...
 %   'no stim','Scgb 3A1 (1 ug/ml)','TGFb only'},'Location','NorthWest');
