function data = mergeTimeHistory(tend, tbeg, data0, data1, type)
% merge all columns in two time histories data0(1..tend, :), data1(tbeg.., :)
% where tend <= tbeg, and all times assumed integer.
%
%   type = 'numeric' 
%       tbeg = tend  average data0(end) with data1(1)
%       tbeg = tend + 1  concatinate data0,1
%       tbeg > tend + 1  linear interpolate between data0(tend,:) and data1(tbeg,:)
%   type = 'cell'    ie number of cell in frame:
%       tbeg = tend  use data1 value
%       tbeg > tend +1, fill in missing entries with -1
%
% Allow special case of all data == row vector of times.

if isempty(data0) && isempty(data1)
    data = [];
    return
end

if xor(isempty(data0), isempty(data1))
    data = [];
    fprintf(1, 'WARNING one of data0,data1 empty in mergeTimeHistory, returning []\n');
    return
end

flip = 0;
if( size(data0,1)==1 && size(data1,1)==1 )
    flip = 1;
    data0 = data0';
    data1 = data1';
end

if ~(strcmp(type, 'cell') || strcmp(type, 'numeric'))
    fprintf(1, 'WARNING, bad type input to mergeTimeHistory, only cell, numeric allowed\n');
end

if tbeg == tend
    data = data0;
    if strcmp(type, 'cell')
        data(end,:) = data1(1,:);
    else
        data(end,:) = (data(end,:) + data1(1,:))/2;
    end
    data = [data; data1(2:end,:)];
elseif tbeg == tend + 1
    data = [data0; data1];
elseif tbeg > tend + 1
    incr = (data1(1,:) - data0(end,:))/(tbeg - tend);
    data = data0;
    for i = 1:(tbeg - tend -1)
        if strcmp(type, 'cell')
            one_line = -ones(1, size(data,2));
        else
            one_line = data0(end,:) + incr*i;
        end
        data = [data; one_line];
    end
    data = [data; data1];
else
    fprintf(1, 'WARNING bad times input to mergeTimeHistory, tend<=tbeg, but input= %d %d\n', tend, tbeg);
    data = [];
end

if flip;
    data = data';
end
return
