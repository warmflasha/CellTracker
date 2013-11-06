function cells = addPhylogeny2Cells(cells, peaks)
% 
% NOT CURRENTLY USED
%
%   cells = addPhylogeny2Cells(cells, peaks)
%
% Add the fields divisionframes and sibling to cells struct array.
% Each is a list of frames or cell # involved in a division. Birth is when
% the first division frame == cells().onframe(1)
%
% Could pull out list of xy for each frame indexed by cell # and would not
% need peaks{}, also a lot less testing of indices.
%
% NB all AW routines run from runTracker.m to make cells and splines
% GUI: can not both zoom and show good cells, 'find cell' button does not
% work. Show good cells does not work with zoom, need button to show all
% nuclei with number (if zoom).  Image name will not update if move around
% cell number slider.
%
% Filter potential divisions by filtering all cells for local max in nuc
% marker and which do not move much.

global userParam

% find all trajectories that begin in frame > 1.
%cells_aux = struct('beg',{}, 'end',{}, 'divisionframes',{}, 'sibling',{}, 'sibdistance',{});
for i = 1:length(cells)
    cells_aux(i).beg = cells(i).onframes(1);
    cells_aux(i).end = cells(i).onframes(end);
    cells(i).sibdistance = [];
end

all_beg = [cells_aux.beg];
min_born = userParam.minTrajLen;  % ignore new cells first few frames
min_born = max(2, min_born); % cells that first appear frame 1 not born
max_beg = max(all_beg);
% run over frames and find all cells born in that frame.
%for n = min_born:max_beg
for n = 20:25
    born = find(all_beg == n);
    if isempty(born)
        continue
    end
    
    % both xy0 and xy1 refer to real cells not interp, but for different
    % reasons.
    for ii = 1:length(born)
        xy0(ii,1:2) = cells(born(ii)).data(1,1:2);
    end
    xy1 = peaks{n}(:,1:2);
    % dst_struct = ipdm(xy0, xy1, 'Result', 'Structure', 'SmallestFew', 3);
    dst = ipdm(xy0, xy1);
    for ii = 1:size(xy0,1)
        [dst0, jj] = min(dst(ii,:));
        if dst0 < 0.1  % dst in units of pixels
            % check indexing..
            self = peaks{n}(jj, 8);  % should be cell # corresp to nuc number jj in frame
            if self ~= born(ii)
                fprintf(1, 'WARNING addPhylogeny2Cells() indices off, frame= %d, nuc= %d, cell# from peaks= %d, ii= %d, born\n',...
                    n, jj, self, ii);
                born
            end
            dst(ii,jj) = Inf;
            [dst0, jj] = min(dst(ii,:));
        else
            fprintf(1, 'WARNING addPhylogeny2Cells(), did not find self among nuc in frame, frame= %d, nuc= %d, cell# from peaks= %d, ii= %d, born\n',...
                    n, jj, self, ii); 
        end
        parent = peaks{n}(jj,8);
        % closest nuc may not be part of a cell trajectory.
        if parent < 1
            continue
        end
        
        % check parent assignment in cells data
        nf = find(cells(parent).onframes == n);
        if isempty(nf)
            fprintf(1, 'WARNING addPhylogeny2Cells(), cells(parent) does not exist in frame,, frame= %d, nuc= %d, cell# from peaks= %d, ii= %d, born\n',...
                    n, jj, self, ii); 
        end
        xyp = cells(parent).data(nf, 1:2);
        dst_pc = sqrt( sum( (xyp - xy0(ii,:)).^2 ));
        if abs(dst_pc - dst0) > 1.e-6
            fprintf(1, 'WARNING addPhylogeny2Cells() dst from cells and peaks ~=, frame= %d, nuc= %d, cell# from peaks= %d, ii= %d, born\n',...
                    n, jj, self, ii); 
        end
        
        % test boundary dst
        if dst0 > dst2Boundary(xy0(ii, 1:2), userParam.sizeImg)
            continue
        end
        
        cells(born(ii)).divisionframes = [cells(born(ii)).divisionframes, n];
        cells(born(ii)).sibling = [cells(born(ii)).sibling, parent];
        cells(born(ii)).sibdistance = [cells(born(ii)).sibdistance, dst0];
        cells(parent).divisionframes = [cells(parent).divisionframes, n];
        cells(parent).sibling = [cells(parent).sibling, born(ii)];
        cells(parent).sibdistance = [cells(parent).sibdistance, dst0];
        
        test_plot(cells, parent, n)
    end
end

% filter parents for repeats of same time in divisionframes, ie 1 begets 2
% children, filter for min time between divisions, filter for parent
% visible some time before putative division.  Filter on data for cells
% that to not move and have peaks in nuc. fluor.(col 5 of .data
                
        
function test_plot(cells, parent, nf)
% for parent cell and a frame when it divides, plot parent, child
% trajectories in xy.
% GUI counts good cells only, so number in cell array has to be computed

    nn = find(cells(parent).divisionframes == nf);
    if length(nn) > 1
        fprintf(1, 'WARNING addPhylogeny2Cells:test_plot, parent= %d taking last child\n', parent);
        nn
        nn = nn(1);
    end
    child = cells(parent).sibling(nn);
    xy0 = cells(parent).data(:, 1:2);
    xy1 = cells(child).data(:, 1:2);
    
    ptr_frame = find(cells(parent).onframes == nf);
    xy_birth = [xy0(ptr_frame,1:2); xy1(1,1:2)];  % for marking common time
    %good = [cells(parent).good, cells(child).good];
    good = count_good_cells(cells, [parent,child])

    figure, plot(xy0(:,1), xy0(:,2), '-r+', xy1(:,1), xy1(:,2), '-g*');
    hold on
    plot(xy_birth(:,1), xy_birth(:,2), 'xk', 'MarkerSize', 10);  % black mark for beginning of child
    title(['r,g parent,child cells= ', num2str([parent, child]),' birthframe= ', num2str(nf), ' good= ', num2str(good) ]);
    hold off
    return
    
function ngood = count_good_cells(cells, ii)
% convert index array ii for cells into index for list of good cells. 
% BS's viewer lists cells by their number in the 'good' array.
    [iis, permu] = sort(ii);
    good = [cells.good];
    nn = -1*ones(size(ii));
    next = 1;
    prev = 0;
    % cummulative sum of good array corresp to sorted ii
    for j = 1:length(ii);
        nn(j) = prev + sum( good(next:iis(j)) );
        next = iis(j)+1;
        prev = nn(j);
    end
    % restore order of inputs
    ngood(permu) = nn;
    % if cell ii is not good sent index to -1;
    not_good = ~good(ii);
    ngood(not_good) = -1;
        
    