function groups=getUniqueBounds(bnd,allPoints)


%connstruct adjancy matrix
A=sparse(bnd(:,1),bnd(:,2),1);

%put 1's on diagnoal
A=A+speye(size(A));

%by some magic, this will get connected components,
%explained here:
%http://blogs.mathworks.com/steve/2007/03/20/connected-component-labeling-part-3/

[p,q,r,s]=dmperm(A);

for ii=1:(length(r)-1)
    groups{ii}=p(r(ii):(r(ii+1)-1));
end
for ii=1:length(groups)
    glen(ii)=length(groups{ii});
end

groups(glen==1)=[];
cc=colorcube(25);
if exist('allPoints','var')
    figure; hold on;
    for ii=1:length(groups)
        plot(allPoints(groups{ii},1),allPoints(groups{ii},2),'.','Color',cc(mod(ii,24)+1,:));
    end
end