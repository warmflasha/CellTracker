function showMovieOneCell(direc,cells,cellnum,imstring,showtext,pausetime,zoomin)
%function showMovieOneCell(direc,cells,cellnum,imstring,pausetime)
%-----------------------------------------------------------------
%Play movie with one cells position indicated
%direc -- directory with image files
%cells -- cells structure with data
%imstring -- string to use to search for images
%showtext -- set to 1 if want to print ratio next to cell (default 0)
%pausetime -- length of time to pause between frames (default 0.1)

[nucrange nucfiles]=folderFilesFromKeyword(direc,imstring);

if direc(end)~=filesep
    direc(end+1)=filesep;
end

if ~exist('pausetime','var')
    pausetime=0.1;
end

if ~exist('showtext','var')
    showtext=0;
end

if ~exist('zoomin','var')
    zoomin=0;
end

if zoomin
    px=cells(cellnum).data(:,1);
    py=cells(cellnum).data(:,2);
    maxx = max(px);
    minx = min(px);
    maxy = max(py);
    miny = min(py);
    xyrange = [minx-100 maxx+100 miny-100 maxy+100];
end

of=cells(cellnum).onframes;
for ii=1:length(of)
    filetoshow=[direc nucfiles(of(ii)).name];
    cdata=cells(cellnum).data(ii,:);
    img=imread(filetoshow);
    imshow(img,[]);
    if zoomin
        axis(xyrange);
    end
    hold on;
    plot(cdata(1),cdata(2),'r.','MarkerSize',12);
    
    if showtext
        text(cdata(1),cdata(2)-10,num2str(cdata(6),2),'Color','m');
    end
    
    drawnow;
    pause(pausetime);
    hold off;
    
end
