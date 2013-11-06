function output=evaluateColony(matfile,frame,cols)

load(matfile,'peaks');

nbins=100;
rad=10;
colorax=[1.2 1.9];

if length(cols)==1
    dd=peaks{frame}(:,cols);
else
    dd=peaks{frame}(:,cols(1))./peaks{frame}(:,cols(2));
end

pos=peaks{frame}(:,1:2);

xmax=max(pos(:,1)); xmin=min(pos(:,1));
ymax=max(pos(:,2)); ymin=min(pos(:,2));

xbin=(xmax-xmin)/nbins; ybin=(ymax-ymin)/nbins;
q1=1; 
for xx=(xmin+xbin/2):xbin:(xmax-xbin/2)
    q2=1;
    for yy=(ymin+ybin/2):ybin:(ymax-ybin/2)
        rpos=bsxfun(@minus,pos,[xx yy]);
        dists=sqrt(sum(rpos.*rpos,2));
        inds=dists < rad;
        output(q1,q2)=meannonan(dd(inds));
        q2=q2+1;
    end
    q1=q1+1;
end

pcolor((xmin+xbin/2):xbin:(xmax-xbin/2),(ymin+ybin/2):ybin:(ymax-ybin/2),output');
caxis(colorax);
colorbar;
shading flat;


