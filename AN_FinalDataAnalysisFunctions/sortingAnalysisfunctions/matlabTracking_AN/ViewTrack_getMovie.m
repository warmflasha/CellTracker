
function trackcelltype_movie = ViewTrack_getMovie(coordintime,celltype,matlabtracking,totrack,r)
% visualize the track on top of corresponding image sequence
% TODO here: put all into the function that outputs the movie for a given
% trackID.
% TODO2: try the tracking on the non-micropetterned data, the paper smad4
% movies in regular culture or soft substrates (if I have that here)
% get the raw image data


close all
time = 3;
if matlabtracking == 1
    time = 5;
    for i=1:size(coordintime,2)
        if size(coordintime(i).dat,1)>=50
            vect(i,1) = i;
        end
    end
    vect2 = nonzeros(vect);
end
if ~isempty(coordintime(totrack).dat)
    startpt =coordintime(totrack).dat(1,time);% 3
    endpt =coordintime(totrack).dat(end,time);% 3  needs to be the last tracked time point
end
if isempty(coordintime(totrack).dat)
    disp('This track is empty');
end
if totrack > size(coordintime,2)
    disp('This track number exceeds the number of cells tracked');
end
trackcelltype_movie = struct('cdata',[],'colormap',[]);
colormap =cool ;%spring cool hsv
randcolor = randi(size(colormap,1));
for jj=startpt:endpt% startpt:endpt
    % newimg = uint8(datatomatch(jj).img);
    % allcellsinimg = cat(1,datatomatch(jj).stats.Centroid);
    % rawimg = uint8(r{1}{jj});
    % figure(jj),imshow(rawimg,[]);hold on
    rawimg = (r{1}{jj});
    figure(jj),imshow(rawimg,[500 2000]);hold on
    % For now plot the rest of cells in the mask (centroids at each tp), to see how the tracking
    % works (not the image, just cel coordinates
    % figure(jj),plot(round(allcellsinimg(:,1)),round(allcellsinimg(:,2)),'kp','LineWidth',1,'Markersize',10,'MarkerFaceColor','b');hold on
    if isfinite(coordintime(totrack).dat(jj,1))
        figure(jj),plot(coordintime(totrack).dat(jj,1),coordintime(totrack).dat(jj,2),'rp','MarkerFaceColor',colormap(randcolor,:),'MarkerSize',6,'LineWidth',1);hold on%colormap(randcolor,:)
        figure(jj),title(['Sorting' celltype 'cells;FRAME' num2str(jj)])
        xlabel('image pixel coordinate')
        ylabel('image pixel coordinate')
        h1 = figure(jj);
        % h1.RendererMode = 'manual';
        % h1.Renderer = 'painters';
        h1.Position =[0 0 560 420];%% this is the size that the function 'movie' supports
        trackcelltype_movie(jj) = getframe(h1,h1.Position);%,[h1.Position]
        h1.Units = 'normalized';
        %size(trackcelltype_movie(jj).cdata)
        %figure, imshow(trackcelltype_movie(jj).cdata);
        close all
    end
    if ~isfinite(coordintime(totrack).dat(jj,1))
        figure(jj),title(['Sorting' celltype 'cells; This cell was lost at FRAME' num2str(jj) ]);
        xlabel('image pixel coordinate')
        ylabel('image pixel coordinate')
        h1 = figure(jj);
        h1.Position =[0 0 560 420];% this is the size that the function 'movie' supports
        trackcelltype_movie(jj) = getframe(h1,h1.Position);%,[h1.Position]
        h1.Units = 'normalized';
        %trackcelltype_movie(jj).colormap = colormap;
        %size(trackcelltype_movie(jj).cdata)
        close all
        randcolor = randi(size(colormap,1));
    end
    
end
end

