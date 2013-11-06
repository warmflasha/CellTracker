function cells = findGoodCells(cells)
%
%   cells = findGoodCells(cells)
%
% Filter data for cells based on length of trajectories, some degree of
% smoothness and availability of cyto signal (fdata = 0 if no cyto)

global userParam

% userParam.minlength   %minlength of trajectories to be considered good
% userParam.mincyto     %minimum fraction of points with cytoplasm detected
% userParam.devthresh   % relative error for data pts>0
% 
% if ~exist('useframes','var') || isempty(useframes)
%     useframes=1:length(pictimes);
%     disp('For cells2: using all frames');
% end

tooshort=0;     nocyto=0;   noisy=0;
for ncell = 1:length(cells)
%     of=cells(cellnum).onframes;
%     uf=of(ismember(of,useframes));
%     cells(cellnum).onframes=uf;
%     cells(cellnum).data=cells(cellnum).data(ismember(of,useframes),:);
%     goodframes=find(cells(cellnum).data(:,7)>0);
%     ngoodframes=length(goodframes);

    % apply tests for not good cells, if pass them all then good
    cells(ncell).good = 1;
    nframes = length(cells(ncell).onframes);
    % length test
    if nframes < userParam.minlength 
        cells(ncell).good=0;
        tooshort = tooshort + 1;
        continue
    end
    % check for fraction of cyto fluor ==0
    [pts, ncol] = size(cells(ncell).fdata);
    for col = 3:2:ncol
        iscyto = (cells(ncell).fdata(:,col) > 0);
        if sum(iscyto) < userParam.mincyto*pts
            cells(ncell).good = 0;
            % can not do continue here, need to jump to end of ncell loop
        end
        if cells(ncell).good == 0
            nocyto = nocyto + 1;  
        end
    end
    % check for relative error vs splines
    sppoints=cells(ncell).sdata;
    datpoints=cells(ncell).fdata;
    inds=datpoints > 0;
    dev=mean2(abs(sppoints(inds)-datpoints(inds))./datpoints(inds));
    if dev > userParam.devthresh
        cells(ncell).good=0;
        noisy = noisy + 1;
    end

end

if userParam.verboseCellTrackerEDS >=1
    fprintf(1, 'findGoodCells: found %d good cells, tested on: minlength= %d mincyto= %d devthresh= %d\n',...
        sum([cells.good]), userParam.minlength, userParam.mincyto, userParam.devthresh);
    fprintf(1, '  cells rejected by 3 tests in order= %d %d %d\n', tooshort, nocyto, noisy);
end