function writeMultichannel(data,filename)

imwrite(data(:,:,1),filename,'Compression','none');
for ii = 2:size(data,3)
    imwrite(data(:,:,ii),filename,'Compression','none','Writemode','append');
end