function ComparisonData3D(Sample1,Cond1,Sample2,Cond2,viewpoint)

colourclusters = {colorconvertorRGB([11,93,174]),colorconvertorRGB([206,61,21]),colorconvertorRGB([105,26,123]),colorconvertorRGB([230,165,26]),colorconvertorRGB([101,160,37])};


if Sample1 == 1
    
load('AllDataMatrixDAPInorm_Plate1.mat')
NamesConditions1 = {'BMP 1ng/ml 0-8h','BMP 1ng/ml 0-16h','BMP 1ng/ml 0-28h','BMP 1ng/ml 0-48h','BMP 10ng/ml 0-48h','BMP 10ng/ml 0-28h','BMP 10ng/ml 0-16h','BMP 10ng/ml 0-8h'};

elseif Sample1 == 2

load('AllDataMatrixDAPInorm_Plate2.mat')
NamesConditions1 = {'BMP 1ng/ml 0-8h','BMP 1ng/ml 0-16h','BMP 1ng/ml 0-28h','BMP 1ng/ml 0-48h','BMP 10ng/ml 0-48h','BMP 10ng/ml 0-28h','BMP 10ng/ml 0-16h','BMP 10ng/ml 0-8h'};

elseif Sample1 == 3
 
load('AllDataMatrixDAPInorm_Plate3.mat')
NamesConditions1 = {'Control','BMP 1ng/ml 0-28h + SB','BMP 1ng/ml 0-38h + SB','BMP 1ng/ml 0-48h + SB','BMP 10ng/ml 0-48h + SB','BMP 10ng/ml 0-38h + SB','BMP 10ng/ml 0-28h + SB','SB'};

elseif Sample1 == 4
    
load('AllDataMatrixDAPInorm_25.mat');
NamesConditions1 = {'Control','BMP 10ng/ml 0-4h','BMP 10ng/ml 0-8h','BMP 10ng/ml 0-16h','BMP 10ng/ml 0-24h','BMP 10ng/ml 0-32h','BMP 10ng/ml 0-40h','BMP 10ng/ml 0-48h'};

elseif Sample1 == 5
 
load('AllDataMatrixDAPInorm_1stPlate.mat')
NamesConditions1 = {'Control','BMP 10ng/ml 0-24h','BMP 10ng/ml 0-8h','BMP 10ng/ml 0-24h','BMP 10ng/ml 0-24h','BMP 10ng/ml 0-28h','BMP 10ng/ml 0-32h','BMP 10ng/ml 0-40h'};

end

DataSample1 = AllDataMatrixDAPInorm{Cond1};

if Sample2 == 1
    
load('AllDataMatrixDAPInorm_Plate1.mat')
NamesConditions2 = {'BMP 1ng/ml 0-8h','BMP 1ng/ml 0-16h','BMP 1ng/ml 0-28h','BMP 1ng/ml 0-48h','BMP 10ng/ml 0-48h','BMP 10ng/ml 0-28h','BMP 10ng/ml 0-16h','BMP 10ng/ml 0-8h'};

elseif Sample2 == 2

load('AllDataMatrixDAPInorm_Plate2.mat')
NamesConditions2 = {'BMP 1ng/ml 0-8h','BMP 1ng/ml 0-16h','BMP 1ng/ml 0-28h','BMP 1ng/ml 0-48h','BMP 10ng/ml 0-48h','BMP 10ng/ml 0-28h','BMP 10ng/ml 0-16h','BMP 10ng/ml 0-8h'};

elseif Sample2 == 3
 
load('AllDataMatrixDAPInorm_Plate3.mat')
NamesConditions2 = {'Control','BMP 1ng/ml 0-28h + SB','BMP 1ng/ml 0-38h + SB','BMP 1ng/ml 0-48h + SB','BMP 10ng/ml 0-48h + SB','BMP 10ng/ml 0-38h + SB','BMP 10ng/ml 0-28h + SB','SB'};

elseif Sample2 == 4
    
load('AllDataMatrixDAPInorm_25.mat');
NamesConditions2 = {'Control','BMP 10ng/ml 0-4h','BMP 10ng/ml 0-8h','BMP 10ng/ml 0-16h','BMP 10ng/ml 0-24h','BMP 10ng/ml 0-32h','BMP 10ng/ml 0-40h','BMP 10ng/ml 0-48h'};

elseif Sample2 == 5
 
load('AllDataMatrixDAPInorm_1stPlate.mat')
NamesConditions2 = {'Control','BMP 10ng/ml 0-24h','BMP 10ng/ml 0-8h','BMP 10ng/ml 0-24h','BMP 10ng/ml 0-24h','BMP 10ng/ml 0-28h','BMP 10ng/ml 0-32h','BMP 10ng/ml 0-40h'};

end

DataSample2 = AllDataMatrixDAPInorm{Cond2};

scatter3(DataSample1(:,4),DataSample1(:,5),DataSample1(:,6),'filled','SizeData',30,'MarkerFaceColor',colourclusters{1},'MarkerFaceAlpha',0.5)
hold on
scatter3(DataSample2(:,4),DataSample2(:,5),DataSample2(:,6),'filled','SizeData',30,'MarkerFaceColor',colourclusters{2},'MarkerFaceAlpha',0.5)

minv = min([DataSample1;DataSample2]);
maxv = max([DataSample1;DataSample2]);

legend(NamesConditions1{Cond1},NamesConditions2{Cond2})

xlabel('CDX2')
ylabel('SOX2')
zlabel('BRA')
set(gca, 'LineWidth', 1);
fs = 11;
set(gca,'FontSize', fs)
set(gca,'FontWeight', 'bold')
set(gca,'TickLabelInterpreter','latex')

xlim([minv(4),maxv(4)])
ylim([minv(5),maxv(5)])
zlim([minv(6),maxv(6)])

if isempty(viewpoint)
    view(3)
else
    view(viewpoint)
end
hold off
