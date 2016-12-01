function [ fullIm ] = computeMontageAndSubBG( filename,dims,channels,parrange,imsize,backgroundImage)
%computeMontageAndSubBG subtracts background using provided image and
%stitches together the montage for the channels specified
%   see alignAndorOneFileProvideBackground for variable explanations

for iChannels = 1:length(channels);
if iChannels == 1;
    [acoords, fullIm{iChannels}] = alignAndorOneFileProvideBackground(filename,dims,channels(iChannels),parrange,imsize,backgroundImage{1}{channels(iChannels),1});
end
if iChannels > 1
    [acoords, fullIm{iChannels}] = alignAndorOneFileProvideBackground(filename,dims,channels(iChannels),parrange,imsize,backgroundImage{1}{channels(iChannels),1},acoords);
end
end

end

