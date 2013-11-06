function newfilename=findnextfile(fstring)

endp=findstr(fstring,'.');
ii=1;
currstring=fstring(endp-ii);
currnum=str2num(fstring(endp-ii));
while ~isempty(currnum)
    ii=ii+1;
    lastgoodnum=currnum;
    lastgoodstr=currstring;
    currstring=fstring((endp-ii):(endp-1));
    currnum=str2num(currstring);
end

nextnum=lastgoodnum+1;
nextnumstr=int2str(nextnum);

if lastgoodstr(1)=='0'
    while length(nextnumstr) < length(lastgoodstr)
        nextnumstr=['0' nextnumstr];
    end
end
    
newfilename=[fstring(1:(endp-ii)) nextnumstr fstring(endp:end)];

