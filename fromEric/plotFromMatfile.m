function plotFromMatfile(dirname, keyword, times)
%
%   plotFromMatfile(dirname, keyword, times)
%
% From a director= dir, find a matfile with a name containing keyword and plot
% smad img with overlay of nuclear outlines and centers. 
%
% Only the matfile as output by segmentCells is needed. Useful for checking smad
% movies.
% TODO show the donut graphically
%

matfile = dir( fullfile(dirname, ['*',keyword,'*mat']) );
if length(matfile) > 1 
    fprintf(1, 'found more than one mat file in dir= %s with keyword= %s\n', dir, keyword);
    matfile.name;
    return
elseif length(matfile) == 1
    matfile = fullfile(dirname, matfile.name);
    load(matfile, 'imgfiles', 'statsArray', 'peaks');
    fprintf(1, 'read imgfiles and statsArray from matfile= %s, len imgfiles= %d, imgfiles(1)=\n',...
        matfile, length(imgfiles) );
    imgfiles(1)
else
    fprintf(1, 'No file found in %s with keyword = %s\n', dirname, keyword);
    return
end


for tt = times
    nucfile = imread(fullfile(dirname, imgfiles(tt).nucfile));
    for jj = 1:length(imgfiles(tt).smadfile)
        img{jj} = imread( fullfile(dirname, imgfiles(tt).smadfile{jj}) );
    end
    nucs = false(imgfiles(tt).size);
    nucs([statsArray{tt}.PixelIdxList]) = 1;
    edges = edge(nucs);
    xy = peaks{tt}(:,1:2);
    
    figure, imshow(img{1}, []);
    hold on
    addEdgeCenter(edges,xy)
    hold off
    title(['dir= ',dirname,'  time= ',num2str(tt), ' smad/IF channel']);
    
    figure, imshow(nucfile, []);
    hold on
    addEdgeCenter(edges,xy)
    hold off
    title('nuclear signal with edges');
end
    
return

function addEdgeCenter(edges, xy)

colors = ['r', 'g', 'm', 'y'];

[row, col] = find(edges);
if ~isempty(row)
    plot(col, row, [colors(1) '.'], 'MarkerSize', 1 );
end

if ~isempty(xy)
    plot(xy(:,1), xy(:,2), [colors(1) '.'] )
end
