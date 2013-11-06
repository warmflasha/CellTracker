function gridfitandplot(matfile,frame,crange,sm)

if ~exist('crange','var')
    crange=[1.1 2.0];
end
load(matfile,'peaks');

if ~exist('sm','var')
    sm=1.6;
end

pdat = peaks{frame}(:,[1 2 6 7]);
pdat(pdat(:,4)==0,:)=[];
xmin=min(pdat(:,1)); xmax=max(pdat(:,1));
ymin=min(pdat(:,2)); ymax=max(pdat(:,2));

xnodes=xmin:20:xmax;
ynodes=ymin:20:ymax;

[zz xx yy]=gridfit(pdat(:,1),525-pdat(:,2),pdat(:,3)./pdat(:,4),xnodes,ynodes,'smoothness',sm);


figure; pcolor(xx,yy,zz); xlim([0 672]); ylim([0 512]); caxis(crange); shading flat;