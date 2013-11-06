function lmax = ddata2lmaxStruct(onframes, data, ddata)
%
%   lmax = ddata2lmaxStruct(onframes, data, ddata) ( where ddata = d data/d frame)
%
% using first deriv, return a struct array containing all local max with associated 
% data. A valid local max must have at least 2 points with ddata > 0
% followed by at least 2 points with ddata < 0. eg 
% the configuration ddata = +++-+--- would be skipped as will an implied
% local max at beginning of data as in ddata = ---
% NB the jump defn is wacky unless data > 0
%
% return struct array with fields
%   frame   time (int frame) of local max
%   width_half   width based on half max
%   width_min    width based on diff of flanking local mins
%   max     value of data at max
%   min1    value of left local min
%   min2    value of right local min
%   max2    average of data at min, each side of max, OR max of min's
%           to disfavor shoulders in data
%   jump    max/max(0, max2) - 1
%
% return the struct array as row, so that one can cat over cells

lmax = struct('frame',{}, 'width_half',{}, 'width_min',{}, 'min1',{}, 'min2',{}, 'max',{}, 'max2',{}, 'jump',{});

pm = sign(ddata);
if find(0 == pm)
    pm = sign(ddata + 1.e-12*max(abs(ddata))*(rand()-1) );
end
steps = pm(1:(end-1)) - pm(2:end);
% need at least ++ --
if sum(abs(steps)) < 2  % nb steps even
    return;
end

nd = length(data);
min_pts = 2;  % each run of +- in ddata must have at least this many pts. must be >1

% process ddata into blocks of +++  ---- entries and 
ii = 0;
jj = 0;

block = struct('max',{}, 'min',{}, 'sign',{}, 'end',{}, 'beg',{}, 'len',{});
while ii < nd  
    maxd = -Inf;
    mind = +Inf;
    ss = pm(ii+1);
    beg_block = ii+1;
    while ii < nd && ss == pm(ii+1)
        ii = ii + 1;
        maxd = max(data(ii), maxd);
        if data(ii) < mind
            kmin = ii;
            mind = data(ii);
        end
    end
    jj = jj + 1;
    block(jj).max = maxd;
    block(jj).min = mind;
    block(jj).kmin = kmin;
    block(jj).sign = ss;
    block(jj).end = ii;
    block(jj).beg = beg_block;
    block(jj).len = (ii - beg_block + 1);
end

% ignore first block if data decreasing
if block(1).sign<0
    block(1) = [];
    jj = length(block);
end
% quit if not enough data
if jj<2
    return
end

% first block for ddata = +++
ptr = 0;
for j = 1:2:(jj-1)
    if block(j).len < min_pts || block(j+1).len < min_pts
        continue
    end
    % define max at +- point where deriv changes sign and data largest
    ptr = ptr + 1;
    if data(block(j).end) > data(block(j+1).beg)
        lmax(ptr).frame = onframes(block(j).end);
    else
        lmax(ptr).frame = onframes(block(j+1).beg);
    end
    lmax(ptr).max = max(block(j).max, block(j+1).max);
    lmax(ptr).min1 = block(j).min;
    lmax(ptr).min2 = block(j+1).min;
    lmax(ptr).max2 = ( block(j).min + block(j+1).min )/2;
    % lmax(ptr).max2 = max( block(j).min, block(j+1).min ); % suppresses sholders
    lmax(ptr).jump = lmax(ptr).max/max(0, lmax(ptr).max2) - 1;
    
    % define width based on 2 flanking min
    lmax(ptr).width_min = onframes(block(j+1).kmin) - onframes(block(j).kmin);
    
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
    lmax(ptr).width_half = k2 - k1; 

end