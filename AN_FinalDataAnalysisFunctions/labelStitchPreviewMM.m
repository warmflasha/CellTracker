function labelStitchPreviewMM(dir,matfile,chan,scale)
% function to plot the montage of the chip, with the image numbers and the 

load(matfile,'peaks','plate1','acoords',',bIms','nIms');
files = readMMdirectory(dir);
if ~exist('xrange','var') || isempty(xrange)
    xrange = files.pos_x;
end

if ~exist('yrange','var') || isempty(yrange)
    yrange = files.pos_y;
end
if ~exist('chan','var') || isempty(chan)
    chan='DAPI';
end

if ~exist('scale','var') || isempty(scale)
    scale = 0.2;
end
fi = StitchPreviewMM(files,acoords);


 
q=1;
for ii=xrange(end):-1:xrange(1)
    for jj=yrange(1):yrange(end)
        
        tmp = mkMMfilename(files,ii,jj,[],[],{chan});
        
        ind = sub2ind([length(files.pos_x) length(files.pos_y)],ii+1,jj+1);
        xy=ceil(scale*acoords(ind).absinds);
        for k=1:size(plate1.colonies,2)
            if (plate1.colonies(k).imagenumbers(1) == ind) && (plate1.colonies(k).ncells == N)
                
                toplot = 0.2*plate1.colonies(k).data(:,1:2);
            end
        end
        figure(1), hold on
        text(xy(1),xy(2),num2str(ind),'color','r');
        figure(1), hold on
        plot(toplot(:,1)+acoords(ind).absinds(2),toplot(:,2)+acoords(ind).absinds(1),'.r','markersize',10);
        if q==1
            xy0=xy;
        end
        
        xy=xy-xy0+1;
        
        %disp(tmp{1});
        xy(xy<1)=1;
       % fullImage(xy(2):(xy(2)+si(2)-1),xy(1):(xy(1)+si(1)-1))=img';
        q=q+1;
    end
end
end



