function [splined, all_diff] = splineCells4BirthPeaks(cells)
%
% For each cell fit the x, y, nuc_area, nuc_fluor data to splines and compute 
% derivative. Use this to locate peaks in nuc fluor, and local min in diffusion
% constant (itself computed from the deriv of x,y). Then find all local max in
% nuc fluor, and local min in diffusion. 
% The splined struct is indexed by cell#, with the following fields:
% (The data and ddata fields are all spline smoothed)
%
%   data(frames, [x, y, nuc_area, nuc_fluor]) ie array(#frames, 4)
%   ddata(same ..)  the time (frame#) deriv of data
%   lmaxFluor() for given cell, a struct array local max nuc_fluor and fields
%       time    time (int frame) of local max
%       width   time difference between local max/min of deriv
%       max     value of data at max
%       max2    average of data at max/min deriv points
%       jump    abs(max - max2)
%       cellN   number of cell to which peak belongs 
%
%   lminDiff()   a struct array, local min of deriv with fields
%       time    time (int frame) of local max
%       width   time difference between local min/max of deriv
%       min     value of data at min
%       min2    average of data at min/max deriv points
%       jump    abs(min - min2)
%       cellN   number of cell to which peak belongs 
%
% all_diff      is the set of all diffusion csts from all cell trajectories
% 
% See stats_splined() for info on how to select

% add the splined data, ddata fields
splined = cells2csaps(cells);

all_diff = [];
% get local max fluor, local min diffusion cst.
for i = 1:length(splined)
    time = cells(i).onframes;
    splined(i).lmaxFluor = data2local_max1b(time, splined(i).data(:,4), splined(i).ddata(:,4));
    [splined(i).lminDiff, diff_data] = data2diff(time, splined(i).ddata(:,1:2) );
    all_diff = [all_diff, reshape(diff_data, 1, []) ];
%     if length(splined(i).lmaxFluor)
%         plot(time, splined(i).data(:,4), 'r', time, diff_data, 'g');
%         title('nuc fluor in red, diff cst in green');
%     end
end
function [lmin_diff, diff] = data2diff(time, ddata)
% Define the diffusion cst as mean sq x,y velocities, spline smooth and
% return local min + stats as structure. 
% return the struct array as row, so that one can cat over cells

lmin_diff = struct('time',{}, 'width',{}, 'min',{}, 'min2',{}, 'jump',{});
diff0 = ddata(:,1).^2 + ddata(:,2).^2;
[diff, ddiff] = smooth_spline(time, diff0);
lmin_diff = data2local_max1b(time, -diff, -ddiff);

if ~isempty(lmin_diff)
    for i = 1:length(lmin_diff)
        lmin_diff(i).min = -lmin_diff(i).max;
        lmin_diff(i).min2 = -lmin_diff(i).max2;
    end
    lmin_diff = rmfield(lmin_diff, {'max', 'max2'});
    lmin_diff = reshape(lmin_diff, 1, []);
else
    lmin_diff = [];
end

function lmax = data2local_max1b(time, data, ddata)
%
% using first deriv, find local max. Define limits of peak as min value of
% data over interval where ddata > 0 (on left) and ddata < 0 right of peak

% return struct array with fields
%   time    time (int frame) of local max
%   width   time difference between local max/min of deriv
%   max     value of data at max
%   max2    average of data at min, each side of max, or max of min's
%   jump    
%
% return the struct array as row, so that one can cat over cells
% 
% find a local max by sign change from several + ddata to several - ddata

lmax = struct('time',{}, 'width',{}, 'max',{}, 'max2',{}, 'jump',{});

pm = sign(ddata);
steps = pm(1:(end-1)) - pm(2:end);
% need at least 2 transitions +++ --- +++
if sum(abs(steps)) < 4
    return;
end

nd = length(data);
min_pts = 2;  % each run of +- in ddata must have at least this many pts. must be >1

% process ddata into blocks of +++  ---- entries and 
ii = 0;
jj = 0;
beg_block = 1;

block = struct('max',{}, 'min',{}, 'sign',{}, 'end',{}, 'beg',{}, 'len',{});
while ii < nd  
    maxd = -Inf;
    mind = +Inf;
    ss = pm(ii+1);
    beg_block = ii+1;
    while ii < nd && ss == pm(ii+1)
        ii = ii + 1;
        maxd = max(data(ii), maxd);
        mind = min(data(ii), mind);
    end
    jj = jj + 1;
    block(jj).max = maxd;
    block(jj).min = mind;
    block(jj).sign = ss;
    block(jj).end = ii;
    block(jj).beg = beg_block;
    block(jj).len = (ii - beg_block + 1);
end

if jj<=3 || (block(1).sign<0 && jj<=4)
    return
else
    if block(1).sign<0
        block(1) = [];
        jj = length(block);
    end
end

% first block for ddata = +++
ptr = 0;
for j = 1:2:(jj-1)
    if block(j).len < min_pts || block(j+1).len < min_pts
        continue
    end
    % define max at +- point where deriv changes sign
    ptr = ptr + 1;
    if data(block(j).end) > data(block(j+1).beg)
        lmax(ptr).time = time(block(j).end);
    else
        lmax(ptr).time = time(block(j+1).beg);
    end
    lmax(ptr).max = max(block(j).max, block(j+1).max);
    lmax(ptr).max2 = ( block(j).min + block(j+1).min )/2;
    lmax(ptr).max2 = max( block(j).min, block(j+1).min ); % eliminates sholders
    lmax(ptr).jump = lmax(ptr).max - lmax(ptr).max2;
    % define width at half max
    halfmax = (lmax(ptr).max + lmax(ptr).max2)/2;
    for k1 = block(j).end:-1:block(j).beg
        if data(k1) < halfmax
            break
        end
    end
    for k2 = block(j+1).beg:block(j+1).end
        if data(k2) < halfmax
            break
        end
    end
    lmax(ptr).width = k2 - k1; 
%     if length(lmax)
%         data'
%         ddata'
%         lmax(ptr)
%     end
end

function smoothed = cells2csaps(cells)
% 
% Apply smoothing splines csaps() fn to the cells data
%
% Return a smoothed struct array with fields 
%   data(frames, [x, y, nuc_area, nuc_fluor]
%   ddata( ibid ) time deriv of data
%

for ii = 1:length(cells)
    xx = cells(ii).onframes;
    for jj = 1:3
        [smoothed(ii).data(:, jj), smoothed(ii).ddata(:,jj)] = ...
            smooth_spline(xx, cells(ii).data(:,jj) );
    end
    [smoothed(ii).data(:, 4), smoothed(ii).ddata(:,4)] = ...
        smooth_spline(xx, cells(ii).fdata(:,1) );
end       
    
function [data, ddata, dddata] = smooth_spline(xx, yy)
% smoothing splines on yy -> data and d data/d xx
% might also drop outlier points and refit.

sp = 0.95;
ddata = [];
dddata = [];

pp = csaps(xx, yy, sp);
data = fnval(pp, xx);
dpp = fnder(pp);
ddata = fnval(dpp, xx);
%ddpp = fnder(pp, 2);
%dddata = fnval(ddpp, xx);
return

%%%%%%%%%%%  various failed attempts of find max

% function lmax = data2local_max2(time, data, dddata)
% % 
% % using the second deriv find local max and eval properties.
% % return struct array with fields
% %   time    time (int frame) of local max
% %   width   time difference between local max/min of deriv
% %   max     value of data at max
% %   max2    average of data at max/min deriv points
% %   jump    
% %
% % return the struct array as row, so that one can cat over cells
% % WORKS poorly, 2nd deriv seems shifted right by 1 from data
% %
% 
% lmax = struct('time',{}, 'width',{}, 'max',{}, 'max2',{}, 'jump',{});
% 
% i2 = find(dddata>0, 1, 'first');
% if i2 > 0
%     ptr = zeros(size(dddata));
%     ptr(1) = i2;
% else
%     return
% end
% 
% min_pts = 2;
% nptr = 1;
% pm = 1;
% % record location of first element of each string of +, - entries, starting
% % with +
% for i = ptr(1):length(dddata)
%     if sign(dddata(i)) == pm
%         continue
%     else
%         pm = -pm;
%         nptr = nptr + 1;
%         ptr(nptr) = i;
%     end
% end
% % want to end with + entry to isolate all the - value strings
% if pm < 0
%     nptr = nptr - 1;  % NB nptr is odd
% end
% ptr = ptr(1:nptr);
% 
% % find all regions with >= minpts - and define local max
% ptr2 = 0;
% for i = 2:2:nptr
%     if ptr(i+1) - ptr(i) > min_pts
%         rr = ptr(i):(ptr(i+1)-1);
%         ptr2 = ptr2 + 1;
%         [lmax(ptr2).max, i2] = max(data(rr));
%         lmax(ptr2).time = time(i2);
%         left = ptr(i) - 1;   %
%         right = ptr(i+1);
%         lmax(ptr2).width = right - left;
%         lmax(ptr2).max2 = (data(left) + data(right) )/2;
%         lmax(ptr2).jump = abs(lmax(ptr2).max - lmax(ptr2).max2);
%     end
% end
% lmax = reshape(lmax, 1, []);
% if length(lmax)
%     data'
%     dddata'
% end
% return
% 
% 
% function lmax = data2local_max1(time, data, ddata)
% %
% % using first deriv, find local max and eval properties.
% % return struct array with fields
% %   time    time (int frame) of local max
% %   width   time difference between local max/min of deriv
% %   max     value of data at max
% %   max2    average of data at max/min deriv points
% %   jump    
% %
% % return the struct array as row, so that one can cat over cells
% % 
% % find a local max by sign change from several + ddata to several - ddata
% 
% ptr = 0;    % tally up local max
% lmax = struct('time',{}, 'width',{}, 'max',{}, 'max2',{}, 'jump',{});
% times = zeros(1,3);  % record index in data(:) of max, 0, min
% state = 0;
% minpts = 2; % min number of points of each sign of deriv to define local max >1
% 
% %reshape(ddata, 1, [])
% for i = 1:length(data)
%     % record state and number of plus and minus ddata values in stretch.
%     if state==0 && ddata(i)>0
%         state = 1;
%         ipp = 1;
%         max_dd = ddata(i);
%         times(1) = i;
%     elseif state==1 && ddata(i)>0
%         ipp = ipp + 1;
%         if ddata(i) > max_dd
%             max_dd = ddata(i);
%             times(1) = i;
%         end
%     elseif state==1 && ddata(i)<=0
%         if ipp < minpts
%             state = 0;
%             continue
%         else
%             state = 2;
%             % define max as pt i with smallest abs(ddata)
%             if -ddata(i) < ddata(i-1)
%                 times(2) = i;
%             else
%                 times(2) = i-1;
%             end
%             imm = 1;
%             min_dd = ddata(i);
%             times(3) = i;
%         end
%     elseif state==2 && ddata(i)<0
%         imm = imm + 1;
%         if ddata(i) < min_dd
%             min_dd = ddata(i);
%             times(3) = i;
%         end
%     elseif state==2 && ddata(i)>=0
%         % inconsistency in logic, if state2 too short, ignore the first >=
%         % data point and start in state 0 rather than state 1
%         if imm < minpts
%             state = 0;
%             continue;
%         else
%             % success! record data on local max
%             ptr = ptr + 1;
%             lmax(ptr).time = time(times(2));
%             lmax(ptr).width = time(times(3)) - time(times(1));
%             lmax(ptr).max = data(times(2));
%             lmax(ptr).max2 = (data(times(1)) + data(times(3)) )/2;
%             lmax(ptr).jump = abs(lmax(ptr).max - lmax(ptr).max2);
%             state = 0;
% %             if lmax(ptr).max > lmax(ptr).max2 + 300
% %                 lmax(ptr)
% %                 reshape(data, 1, [])
% %                 reshape(ddata, 1, [])
% %             end
%         end
%     end
% end
% 
% lmax = reshape(lmax, 1, []);
% return