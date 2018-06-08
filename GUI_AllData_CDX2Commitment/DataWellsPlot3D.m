function DataWellsPlot3D(PlateNumber,wellnumber,viewpoint)

if PlateNumber == 1
    
load('AllDataMatrixDAPInorm_Plate1.mat')
NamesConditions = {'BMP 1ng/ml 0-8h','BMP 1ng/ml 0-16h','BMP 1ng/ml 0-28h','BMP 1ng/ml 0-48h','BMP 10ng/ml 0-48h','BMP 10ng/ml 0-28h','BMP 10ng/ml 0-16h','BMP 10ng/ml 0-8h'};
colourclusters = {colorconvertorRGB([11,93,174]),colorconvertorRGB([206,61,21]),colorconvertorRGB([105,26,123]),colorconvertorRGB([230,165,26]),colorconvertorRGB([101,160,37])};

elseif PlateNumber == 2

load('AllDataMatrixDAPInorm_Plate2.mat')
NamesConditions = {'BMP 1ng/ml 0-8h','BMP 1ng/ml 0-16h','BMP 1ng/ml 0-28h','BMP 1ng/ml 0-48h','BMP 10ng/ml 0-48h','BMP 10ng/ml 0-28h','BMP 10ng/ml 0-16h','BMP 10ng/ml 0-8h'};
colourclusters = {colorconvertorRGB([11,93,174]),colorconvertorRGB([206,61,21]),colorconvertorRGB([105,26,123]),colorconvertorRGB([230,165,26]),colorconvertorRGB([101,160,37])};

elseif PlateNumber == 3
 
load('AllDataMatrixDAPInorm_Plate3.mat')
NamesConditions = {'Control','BMP 1ng/ml 0-28h + SB','BMP 1ng/ml 0-38h + SB','BMP 1ng/ml 0-48h + SB','BMP 10ng/ml 0-48h + SB','BMP 10ng/ml 0-38h + SB','BMP 10ng/ml 0-28h + SB','SB'};
colourclusters = {colorconvertorRGB([11,93,174]),colorconvertorRGB([206,61,21]),colorconvertorRGB([105,26,123]),colorconvertorRGB([230,165,26]),colorconvertorRGB([101,160,37])};

elseif PlateNumber == 4
    
load('AllDataMatrixDAPInorm_25.mat');
NamesConditions = {'Control','BMP 0-4h','BMP 0-8h','BMP 0-16h','BMP 0-24h','BMP 0-32h','BMP 0-40h','BMP 0-48h'};
colourclusters = {colorconvertorRGB([11,93,174]),colorconvertorRGB([206,61,21]),colorconvertorRGB([105,26,123]),colorconvertorRGB([230,165,26]),colorconvertorRGB([101,160,37])};

elseif PlateNumber == 5
 
load('AllDataMatrixDAPInorm_1stPlate.mat')
NamesConditions = {'Control','BMP 0-24h','BMP 0-8h','BMP 0-24h','BMP 0-24h','BMP 0-28h','BMP 0-32h','BMP 0-40h'};
colourclusters = {colorconvertorRGB([11,93,174]),colorconvertorRGB([206,61,21]),colorconvertorRGB([105,26,123]),colorconvertorRGB([230,165,26]),colorconvertorRGB([101,160,37])};

end

alphas = 0.05*ones(1,size(AllDataMatrixDAPInorm,2));
alphas(wellnumber) = 0.5;


for wellnplot = 1:size(AllDataMatrixDAPInorm,2)
    if wellnplot ~= wellnumber
    scatter3(AllDataMatrixDAPInorm{wellnplot}(:,4),AllDataMatrixDAPInorm{wellnplot}(:,5),AllDataMatrixDAPInorm{wellnplot}(:,6),'filled','SizeData',30,'MarkerFaceColor',colourclusters{1},'MarkerFaceAlpha',0.05)
        hold on
    end
end
scatter3(AllDataMatrixDAPInorm{wellnumber}(:,4),AllDataMatrixDAPInorm{wellnumber}(:,5),AllDataMatrixDAPInorm{wellnumber}(:,6),'filled','SizeData',30,'MarkerFaceColor',colourclusters{2},'MarkerFaceAlpha',1)

% corrcoef(AllDataMatrixDAPInorm{wellnumber}(:,4),AllDataMatrixDAPInorm{wellnumber}(:,6))

xlabel('CDX2')
ylabel('SOX2')
zlabel('BRA')
set(gca, 'LineWidth', 1);
fs = 11;
set(gca,'FontSize', fs)
set(gca,'FontWeight', 'bold')
set(gca,'TickLabelInterpreter','latex')
title(NamesConditions{wellnumber})
% xlim([minnormValues(2),maxnormValues(2)])
% ylim([minnormValues(3),maxnormValues(3)])
% zlim([minnormValues(4),1])

xlim([0,2.5])
ylim([0,3])
zlim([0,1])

if isempty(viewpoint)
    view(3)
else
    view(viewpoint)
end
hold off
