function statsIF(dirname, keyword )
%
% Read the matfile = *keyword*.mat ([] -> 'outall') in the directory= dirname
% Use editor and put a pause at return in main program. Then call
%
%   show_colonyIF(colony_object, dirname, 0|1, 0|1) to show IF and optionally
%       nuclei
%   scatter_all(colony_object, 0|1) various scatter plots vs radius and other
%       diagnostics taken from data in c_obj not using images.
%
%   NB in cobj.data() (x,y,nucarea, -1, nucI, w1nuc, w1cyto, w2nuc...end-1, end)
%  
% New routines 5/20/13 In the outall.mat there is only a plate object which has all
% names of colonies1000 etc, background subtractions... and colonies()
% aa = plate1.getColonyImages(72, dd)

% initialize the directory for tiffs, colonies() struct array, 2 background
% files.
global direc colonies bIms nIms
direc=[]; colonies=[]; bIms=[]; nIms=[];

if ~exist('keyword', 'var') || isempty(keyword)
    keyword = 'outall';
end
direc = dirname;
matfile = dir( fullfile(dirname, ['*',keyword,'*mat']) );
if length(matfile) > 1 
    fprintf(1, 'found more than one mat file in dir= %s with keyword= %s\n', dir, keyword);
    matfile.name;
    return
elseif length(matfile) == 1
    matfile = fullfile(dirname, matfile.name);
    mat = load(matfile, 'plate*', 'userParam', 'bIms', 'nIms'); 
    names = fieldnames(mat);
    for nn = 1:length(names)
        if ~isempty( strfind(names(nn),'plate') )
            plate1 = mat.(names{nn});
            if any(strcmp('colonies', fieldnames(plate1)) )% plate not recognized as struct  isfield(plate1, 'colonies')
                colonies = plate1.colonies;
            else
                tmp = load(matfile, 'colonies');
                colonies = tmp.colonies;
            end
            fprintf(1, 'read %s, #colonies= %d, userParam from matfile\n', names{nn}, length(colonies));
            break;
        end
        % no check if colonies() not found.
    end
    if any(strcmp(names, 'nIms')) && any(strcmp(names, 'bIms'))
        nIms = mat.nIms;   bIms = mat.bIms;
    end
else
    fprintf(1, 'No file found in %s with keyword = %s\n', dirname, keyword);
    return
end

[dims, wavel] = getDimsFromScanFile(dirname);
fprintf('data= %s, wavelengths in order\n', folder_name(dirname) );
wavel
fprintf('  1000mu & 500mu colonies printed as (colony-number, ncells)\n');
nice_print_colonies(plate1, colonies, 1000);
nice_print_colonies(plate1, colonies, 500);

% for ii = 1:100
%     opts = input('input [colony number, overlay(0|1), show nuc(0|1)] OR [] to quit input\n');
%     if isempty(opts)
%         break
%     end
%     [img, nuc] = show_colonyIF(dirname,  colonies(opts(1)), opts(2), opts(3) );
%     % can do additional plots of img files without rereading
%     for i = 1:size(img,3)
%         figure, imshow( imadjust(img(:,:,i), stretchlim(img(:,:,i)) ) );
%         title(['colony= ', num2str(opts(1)), ' wavelen= ', num2str(i)]);
%     end
% end

return

function [img, nuc] = show_colonyIF(ncolony, overlay, show_nuc)

%function [img, nuc] = show_colonyIF(dirname,  cobj, overlay, show_nuc)
%
% show the 3 IF's with various ON|OFF options to 
%   %%%mask out pts outside of center + radius
%   overlay=1   show one RGB image of all 3 channels overlay AND show 3 figs 
%          =0   show 3 figs one channel each
%   show_nuc=1  superimpose nuclear outlines and centers on DAPI. Compute nuc outlines from
%               compressNucMask if available otherwise call edge(DAPI image)
%   show_nuc=2  plot the DAPI image with nuclear edges overlayed
%
%   blockColony() automatically called to plot only square circumscribed around
% colony
%   With imadjust get better constrast if just use colony pixels, and not non
% colony and certainly not after setting non colony to 0
% For memory can do imresize when reading raw files, since big colonies only
% displayed at 25% anyway.

global direc colonies
dirname = direc;
cobj = colonies(ncolony);

[wavel, colorIF] = marker2wavelen(dirname);  % wavel = {'w1', etc}
oout = vertcat(colorIF, wavel);
fprintf('assiging IF color= %s to file name tags= %s\n', oout{:,:} );
nIF = length(colorIF) - 1; % ie IF and not the DAPI

tic; 
scl_img = 1;
if cobj.radius > 1024
    scl_img = 0.5;
end

% do not save raw images to save memory. Should cutout non disk before doing
% imadjust. Do not use indx = find(mask) since generates list of doubles
% tmpI = my_assembleColony(cobj, dirname, wavel(1:nIF) );  % group read 15% faster than 3x single
tmpI = [];
for i = 1:nIF
    if isempty(tmpI)
        tmp = my_assembleColony(cobj, dirname, wavel(i));
    else
        tmp = tmpI(i);
    end
    if isempty(tmp)
        continue
    end
    [nrow, ncol] = size(tmp{1});  % size of input Img
    [tmp, new00] = blockColony(cobj, tmp{1});
    tmp = imresize(uint16(tmp), scl_img);
    img(:,:,i) = tmp;
end
clear tmpI tmp
toc
% use the nuclei edges from segmentCells if available or else take gradient of
% DAPI image.
nuc = [];  edges = [];   xy = [];
if show_nuc && any(strcmp(properties(cobj), 'compressNucMask') )
    edges = uncompressBinaryImg(cobj.compressNucMask, 'edge');
    edges = blockColony(cobj, edges); %edges((new00(2)+1):nrow, (new00(1)+1):ncol );
    if scl_img < 1
        edges = imdilate(edges, strel('disk',2) ); 
        edges = imresize(edges, scl_img);
    end
    xy = scl_img*(cobj.data(:,1:2) - ones(cobj.ncells,1)*new00);
end
if show_nuc==2 || isempty(edges)
    nuc = my_assembleColony(cobj, dirname, wavel(end));
    nuc = uint16( blockColony(cobj,nuc{1}) );
    nuc = imresize(nuc, scl_img);
    if isempty(edges) % gaussian smooth DAPI prior to edge
        edges = edge(smooth_img(nuc, round(4*scl_img)), 'canny');
    end
    xy = scl_img*(cobj.data(:,1:2) - ones(cobj.ncells,1)*new00);   
end

name = folder_name(dirname);
if overlay
    if size(img,3) == 2
        img(:,:,3) = zeros(size(img(:,:,1)) );
    end
    figure, imshow( imadjust(img,stretchlim(img)) );
    addCenterRadiusEdge([], [], xy, edges, 0);
    title([name, ' colony= ',num2str(cobj.data(1,end))]);
end
% plot each IF as grey scale and add nuc outline.
for i = 1:nIF
    if max(max(img(:,:,i))) < 1  % no image for this color found indata
        continue
    end
    figure, imshow( imadjust(img(:,:,i), stretchlim(img(:,:,i)) ) );      %imshow(img(:,:,i),[])
    addCenterRadiusEdge([], [], xy, edges, 1);
    title(sprintf('data= %s, colony= %d, colorIF= %s, w= %s',...
        name, cobj.data(1,end), colorIF{i}, wavel{i}) );
end
% plot DAPI with nuc outlines
if show_nuc==2
    figure, imshow( imadjust(nuc, stretchlim(nuc) ) );
    addCenterRadiusEdge([], [], xy, edges, 1);
    title(sprintf('data= %s, colony= %d, colorIF= %s',...
        name, cobj.data(1,end), colorIF{i}) );
    xlabel( sprintf('nuc edges from compressNucMask(T|F)= %d',...
        any(strcmp(properties(cobj),'compressNucMask')) ));
end

return

function fullImg = my_assembleColony(cobj, dirname, wavel)
% dummy interfact to test for background images and call appropriate fn
global bIms nIms
if isempty(bIms) || isempty(nIms)
    fullImg = assembleColony(cobj, dirname, wavel);
else
    fullImg = assembleColony(cobj, dirname, wavel, bIms, nIms);
end

function addCenterRadiusEdge(center, radius, nucctr, nucedges, bw)
% plot on current image the center, disk perimeter, and edges of nuclei, input
% [] to skip property.  
% the bw = 1 flag says overlaying edges etc on grey scale image, =0 RGB image.
% Implies to chose the nuc outlines for better contrast

colors = ['r', 'g', 'm', 'y', 'k'];

hold on
if ~isempty(center)
    plot(center(1), center(2), [colors(1) 'x'], 'MarkerSize', 5);
end

if ~isempty(radius)
    pts = 2*pi*radius;
    theta = (1:pts)'*(2*pi/pts);
    [x,y] = pol2cart(theta, radius);
    x = round(x + center(1));
    y = round(y + center(2));
    plot(x, y, [colors(1) '.'] )
end

if ~isempty(nucctr)
    if bw
        plot(nucctr(:,1), nucctr(:,2), [colors(1),'x'] );
    else
        plot(nucctr(:,1), nucctr(:,2), [colors(5),'x'] );
    end
end

if ~isempty(nucedges)
    [row, col] = find(nucedges);
    if bw
        plot(col, row, [colors(1) '.'], 'MarkerSize', 1 );
    else
        plot(col, row, [colors(5) '.'], 'MarkerSize', 1 );  %makes lines finer
    end
end
hold off

function [img, new00] = blockColony(cobj, img)
% restrict the image to just the disk + border in pixels. 
% return new00 to reset origin of xy data in cobj. Base 0
border = 50;
radius = cobj.radius + border;
si = size(img);
lo = max(1, round(cobj.center - radius) );
new00 = lo - [1,1];
hi = min([si(2), si(1)], round(cobj.center + radius) );
img = img(lo(2):hi(2), lo(1):hi(1) );
return

function img1 = smooth_img(img0, radius)
% apply a gaussian filter to an image
hg = fspecial('gaussian', 6*radius, radius);
img1 = imfilter(img0, hg, 'replicate');
return

function nice_print_colonies(plate1, colonies, microns)
% print pairs of (col-number, ncells), perline pairs per line of output

ff = ['inds', num2str(microns)];
out(1,:) = plate1.(ff);
cobj = colonies(out(1,:));
out(2,:) = [cobj.ncells];
perline = 5;
for i = 1:perline:size(out,2)
    fprintf('%d %d   ', out(1:2, i:min(i+perline-1,end)) );
    fprintf('\n');
end
fprintf('\n');
return

function name= folder_name(dirname)
% extract the data file name from either dirname or if dirname = '.' assume the path
[path, name] = fileparts(dirname);
if isempty(name)  % if use dirname = '.' 
    [path, name] = fileparts(pwd);
end
name = strrep(name, '_', '-');

function [wavelout, colorIF] = marker2wavelen(dirname)
% read the scan file in the directory and order the cell array 
% {'w1', 'w2', 'w3', 'w4'} so that DAPI is last and the number of entries matches
% colors in the scan file
allwavel = {'w1', 'w2', 'w3', 'w4'};
[dims, colorIF] = getDimsFromScanFile(dirname);
dapi = strcmpi('DAPI', colorIF);
if sum(dapi) == 0
    wavelout = [];
    fprintf('did not find a DAPI image in dir= %s in scan file wavelen= \n', dirname);
    colorIF
else
    wavelout = allwavel(~dapi);
    wavelout(end+1) = allwavel(dapi);
end
return

function mask = colonyMask(size_img, center, radius)
% return mask, size(mask) = size(img) based on center, radius, with mask=1
% inside of colony and zero outside.
pts = 2*pi*radius;
theta = (1:pts)'*(2*pi/pts);
[x,y] = pol2cart(theta, radius);
x = round(x + center(1));
x = max(x,1);  x = min(x, size_img(2));
y = round(y + center(2));
y = max(y,1);  y = min(y, size_img(1));
indx = sub2ind(size_img, y, x);
mask = false(size_img);
mask(indx) = 1;
mask = imdilate(mask, strel('disk',2) );
mask = imfill(mask, 'holes');
% figure, imshow(bndry)
return
