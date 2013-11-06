function mask = uncompressBinaryImg(mm, type)
% undo the compress function and return either a logical mask array or if
% optional argument type = 'edge' return just the edges of the regions that
% were 1 in starting image (defined by running over columns)
%
% The 'edge' option does not completely fill in the vertical edges, need
% take full mask, erode and subtract.

if nargin==2 
    if strfind(type, 'edge')
        type = 'edge';
    else
        fprintf(1, 'WARNING uncompressBinaryImg: input unknown type= %s, ignoring\n', type);
        type = 'mask';
    end
else
    type = 'mask';
end

mask = false(mm(1:2));

if strcmp(type, 'mask')
    for i = 3:2:length(mm)
        mask(mm(i):mm(i+1)) = 1;
    end
end

if strcmp(type, 'edge')
    mask(mm(3:end)) = 1;
end

return