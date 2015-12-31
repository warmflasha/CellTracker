function acoords = olympusToMMbtf(MMdirec,filenames,chan,imsize)
tic;
% files = olympusToMM(MMdirec,filenames,chan,imsize)
%------------------------------------------------------
% Convert from Olympus output large tiled image into a directory with a
% subdirectory for each postion.
% inputs:   MMdirec - name of output directory
%           filenames - cell array of input file names, one for each
%               channel
%           chan - channel names. will be used for the image names in
%               micromanager
%           imsize - size of individual images to break the image into
%           (default is 2048x2048).

if ~exist('imsize','var'),
    imsize = [2048 2048];
end

files = mkMMFileStruct(MMdirec,chan);
h = imread(filenames,1);
n_width = size(h,2)/imsize(1);
n_height = size(h,1)/imsize(2);

if ~isinteger(n_width)
    n_width = floor(n_width) + 1;
end
if ~isinteger(n_height)
    n_height = floor(n_height)+1;
end

%for ii = 2
for ii = 1:n_width
    %for jj = n_height
    for jj = 1:n_height
 
        xmin = (ii-1)*imsize(2)+1;
        xmax = min(ii*imsize(2),size(h,2));
        ymin = (jj-1)*imsize(1)+1;
        ymax = min(jj*imsize(1),size(h,1));
        pos_y = jj - 1;
        pos_x = n_width - ii; %MM labels img 0,0 as upper right corner
        
        spos_x=int2str(pos_x);
        while length(spos_x) < 3
            spos_x = ['0' spos_x];
        end
        
        spos_y=int2str(pos_y);
        while length(spos_y) < 3
            spos_y = ['0' spos_y];
        end
        
        direc = [files.direc filesep files.prefix 'Pos_' spos_x '_' spos_y];
        if ~exist(direc,'dir')
            mkdir(direc);
        end
        for kk = 1:4
            img = imread(filenames,kk);
            %img = img(xmin:xmax, ymin:ymax);
            img = img(ymin:ymax, xmin:xmax);
            if size(img,1) ~= imsize(1) || size(img,2) ~= imsize(2)
                zz =zeros(imsize,'uint16');
                zz(1:size(img,1),1:size(img,2))=img;
            else
                zz = img;
            end
            savename = mkMMfilename(files,pos_x,pos_y,[],[],kk);
            imwrite(zz,savename{1});
        end
        
        %make accords structure for later use
        ind = sub2ind([n_width, n_height],pos_x+1,pos_y+1);
        acoords(ind).wabove = [0 0];
        acoords(ind).wside = [0 0];
        acoords(ind).absinds =[xmin, ymin];
        
    end
end



function files = mkMMFileStruct(direc,chan)

files.direc = direc;
files.prefix = '1-';
files.chan = chan;
files.subprefix = 'img';
end

toc;
end
