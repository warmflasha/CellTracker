function plotcolorcolonies(od,newfig,col)

if ~exist('newfig','var')
    newfig=1;
end

if newfig
    figure; hold on;
else
    hold on;
end

dlen=length(od(1,:));
if ~exist('col','var')
    col=dlen;
elseif col==0
    col=dlen;
elseif col==1;
    col=dlen-1;
end

cols=unique(od(:,col));

ncols = length(cols);
cc=colorcube(28);

for ii=1:ncols
    inds=od(:,col)==cols(ii);
    colorind=mod(cols(ii),27);
    plot(od(inds,1),od(inds,2),'.','Color',cc(colorind+1,:),'MarkerSize',18);
end