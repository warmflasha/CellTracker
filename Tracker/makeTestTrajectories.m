function [cells, xx, yy, peaks] = makeTestTrajectories()
% cells = struct array with fields
%   mother  = 0 if cell present frame=1 otherwise cell number of mother
%   birth   = time/frame number when created, 0 if in frame 1 
%   age     = array(nt,1) = [0, tdiv) age of cell since last division <tdiv
%   x       = array(nt,1) of x positions [0,1], -1 for unborn cells
%   y       = y positions
% Store age, x, y as column vectors so that [cells(range).x] dumps
% array(nt, cells)
%

global userParam
userParam.L = 0.04; %% distance threshold for match to dummy particle ~2*rstep

nt      = 20;   % number of times/frames, 
ncell0  = 10;   % number of cells initially
loss    = 0.05; % rate per cell per frame that loose point
tdiv    = 40;   % frames between cell division, initial cell age= random
rstep   = 0.02; % step by +-rstep*rand() in x,y each frame
border  = 0.02; % cells within this distance of 0 or 1 in x or y vanish (<0 ignore
rand('twister',1);

% age,x,y are vectors of length nt. age=0 at birth and x,y=rand(). 
% When birth=t > 0, x,y(1..(t-1)) == -1, age(1..t) = 0
cells = struct('mother',{}, 'birth',{}, 'age',{}, 'x',{}, 'y',{});

% make cells struct for first frame
for n = 1:ncell0
    cells(n)    = new_cell(nt);
    cells(n).age = max(1, floor(rand()*tdiv));  % no births frame 1
    cells(n).x(1) = rand();
    cells(n).y(1) = rand();
end

% make frames 2:nt
ncell_tm = ncell0;   % number of cells at time = t-1
ncell_t  = ncell0;   % number of cells time t after all births
for t = 2:nt
    for n = 1:ncell_tm
        cells(n).x(t) = bounded_step(cells(n).x(t-1), rstep);
        cells(n).y(t) = bounded_step(cells(n).y(t-1), rstep);
        cells(n).age(t) = cells(n).age(t-1) + 1;
        % birth
        if cells(n).age(t) == tdiv
            cells(n).age(t) = 0;
            ncell_t = ncell_t + 1;
            cells(ncell_t) = new_cell(nt);
            cells(ncell_t).mother = n;
            cells(ncell_t).birth = t;
            cells(ncell_t).x(t) = cells(n).x(t);
            cells(ncell_t).y(t) = cells(n).y(t);
        end
    end
    ncell_tm = ncell_t;
end

% mutate the x, y(times, cells) arrays. Note ncell== all cells at end
xx = [cells.x];
yy = [cells.y];
ncell = size(xx, 2);

for t = 1:nt
    ncell_t = length( find(xx(t,:)>=0) );
    n2mutate = poissrnd(loss*ncell_t, 1,1);  
    for nn = 1:n2mutate
        n = 1 + floor(rand()*ncell_t);
        xx(t,n) = -1;
        yy(t,n) = -1;
    end
    % remove cells close to boundaries
    for n = 1:ncell_t
        if( xx(t,n)>border && xx(t,n)<1-border && yy(t,n)>border && yy(t,n)<1-border )
            continue
        end
        xx(t,n) = -1;
        yy(t,n) = -1;
    end
end

% format data into peaks{time} array, ie keep only real cells
% peaks = [x, y, area, map_cell_next_time]  rows are cells for given time
for t = 1:nt
    allx = find(xx(t,:) >= 0);
    ally = find(yy(t,:) >= 0);
    allxy = intersect(allx, ally);
    peaks{t} = [xx(t,allxy)', yy(t,allxy)', ones(length(allxy), 1)];
end

return

function cell = new_cell(nt)
% initialization for frame=1, define storage for frame > 1
cell.mother = 0;
cell.birth  = 0;
cell.age    = zeros(nt,1);
cell.x      = -ones(nt,1);
cell.y      = -ones(nt,1);

function rp = bounded_step(r, rstep)
rp = r + (2*rand()-1)*rstep;
rp = max(0, rp);
rp = min(1, rp);
