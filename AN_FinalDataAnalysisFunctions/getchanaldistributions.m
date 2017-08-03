
%% look at histograms of the raw chanel data for FGF pathway manipulation
dir = ('/Volumes/data2/Anastasiia/13_20160222-PaperFigures_DATA/matlab_Figure3Panels');
nms = {'Control_inh(2)','FGFReceptor_inh'};                 % ,'FGFReceptor_inh'
nms2 = {'Control','FGFRi at 100 nM'};                       %,'FGFRi at 100 nM'
% 
% % dir = ('/Volumes/data2/Anastasiia/13_20160222-PaperFigures_DATA/matlab_Figure3Panels');
% nms = {'C_R_pErkNanogSmad2','MEKi_R_pErkNanogSmad2'};     % ,'MEKi_R_pErkNanogSmad2'
% nms2 = {'Control','PD98059 at 10 uM'};                    %,'PD98059 at 10 uM'

% dir = ('/Volumes/data2/Anastasiia/13_20160222-PaperFigures_DATA/matlab_Figure3Panels');
% nms = {'R2control160','R2otherMEK160'};     % here stained for nanog (rfp), Sox2 (GFP)
% nms2 = {'Control','PD0325901 at 1 uM'};

ucol = 7;
param1 = 'DAPI';
index1 = [5];
flag = 1;
dapimax =5000;   %now used as the area thresh in colony analysis; dapimax is set to max 60000 within the generalized mean function
scaledapi = 1;

if (scaledapi == 1) 
for k=1:size(nms2,2)
[dapi(k),ncells] = getmeandapi(nms(k),dir,index1, dapimax);
disp(['cells found' num2str(ncells) ]);
disp(['dapi mean value' num2str(dapi(k)) ]);
end
dapiscalefactor = dapi/dapi(1);
end
if (scaledapi == 0) 
dapiscalefactor = ones(1,size(nms,2));
end
disp(dapiscalefactor);
[data] =  Hist_vs_ColSize(nms,nms2,dir,index1,param1,dapimax,scaledapi,flag,ucol);
%%
 % get the cell data from each chanel as cell rray, regardless of colony
 % grouping
 index = [5 6 8]; 
 [chandata]= rawdatainchan(nms,dir,index);
 
 for k=1:size(chandata,1)
   disp(['mean dapi' num2str(mean(chandata{k}(:,1)))]);
  figure(1),histogram(chandata{k}(:,1),'normalization','probability','BinWidth',100);hold on  
 end
title('DAPI values distributions');
legend(nms2);
h = figure(1);
h.CurrentAxes.LineWidth = 3;
box on;
h.CurrentAxes.FontSize = 18;
xlabel('DAPI');
ylabel('Frequency');
ylim([0 0.3])
xlim([0 6000]);
  