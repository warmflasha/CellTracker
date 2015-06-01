function allinds=assignCellsToColonies(pts,groups,mkplot)
disp('is called here'); % AN, db

if ~exist('mkplot','var')
    mkplot=0;
end

%in=zeros(length(groups),size(pts,1));
in=sparse(length(groups),size(pts,1),0);   %The sparse function generates matrices in the MATLAB® sparse storage organization.
%S = sparse(m,n) abbreviates sparse([],[],[],m,n,0). This generates the ultimate sparse matrix, an m-by-n all zero matrix.

for ii=1:length(groups)
    if ~mod(ii,10) %mod after division ii/10
        disp(int2str(ii));
    end
    cen=mean(pts(groups{ii},:));
    disttocen=bsxfun(@minus,pts,cen);   % bsxfun - Apply element-by-element binary operation to two arrays with singleton expansion enabled
    disttocen=sqrt(sum(disttocen.*disttocen,2));
    indsgood=find(disttocen < 4000);%%original value 4000
    innow=inhull(pts(indsgood,:),pts(groups{ii},:),[],5);   %inhull: tests if a set of points are inside a convex hull.
        %usage: in = inhull(testpts,xyz,tess,tol);tol - (OPTIONAL) tolerance on
        %the tests for inclusion in the convex hull. You can think of tol as
        %the distance a point may possibly lie outside the hull, and still be
        %perceived as on the surface of the hull. original value of the tol (last input argument) = 5
        %in  - nx1 logical vector;in(i) == 1 --> the i'th point was inside the convex hull.
    indsnow=indsgood(innow);
    toadd=sparse(ii*ones(length(indsnow),1),indsnow,1,length(groups),size(pts,1));
    in=in+toadd;
end

incolonies=sum(in,1);
indstofix=find(incolonies) > 1;% ????
nfix=0;
for ii=1:length(indstofix)
    nfix=nfix+1;
    xx=find(in(:,ii),1,'first');
    in((xx+1):end,ii)=0;
end
allinds=sparse(size(pts,1),1,0);

for ii=1:length(groups)
    allinds=allinds+ii*in(ii,:)';
end


if mkplot
    ps={'g.','r.','b.','m.','c.','y.'};
    figure; hold on;
    plot(pts(:,1),pts(:,2),'k.');
    for ii=1:length(groups)
        ptoplot=allinds==ii;
        plot(pts(ptoplot,1),pts(ptoplot,2),ps{mod(ii,6)+1});
    end
end