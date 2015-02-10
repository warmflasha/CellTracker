function filename = getAndorFileName(files,pos,time,z,w)

filename = files.prefix;


for ii=1:length(files.ordering)
    switch files.ordering(ii)
        case 'f'
            num = int2str(pos);
        case 't'
            num=int2str(time);
        case 'z'
            num = int2str(z);
        case 'w'
            num = int2str(w);
    end
    
    while length(num) < 4
        num = ['0' num];
    end
    str1 = ['_' files.ordering(ii) num];
    filename = [filename str1];
end

filename = [files.direc filesep filename '.tif'];