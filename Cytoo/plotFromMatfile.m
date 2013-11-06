function plotFromMatfile(dirname, keyword, times)
%
% From a director= dir, find a matfile with a name containing keyword and plot
% img with overlay of nuclear outlines and centers. 
%
% For first part of code only the matfile as output by segmentCells is needed.
%

matfile = dir( fullfile(dirname, ['*',keyword,'*mat']) );
if length(matfile) > 1 
    fprintf(1, 'found more than one mat file in dir= %s with keyword= %s\n', dir, keyword);
    matfile.name;
    return
elseif length(matfile) == 1
    matfile = fullfile(dirname, matfile.name);
    load(matfile, 'imgfiles', 'statsArray', 'peaks');
    fprintf(1, 'read imgfiles and statsArray from matfile= %s, imgfiles(1)=\n', matfile);
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
