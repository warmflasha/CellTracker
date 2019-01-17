function compareMultiChannelImages(imgs,condToUseForChan)

nchan = min(cellfun(@(x) size(x,3), imgs)); %minimum of chan numbers
if ~exist('condToUseForChan','var')  || isempty(condToUseForChan)
    condToUseForChan = ones(nchan,1);
end
nimgs = length(imgs);
q = 1;
for chan = 1:nchan
    lims = stretchlim(imgs{condToUseForChan(chan)}(:,:,chan),[0.3 0.9999]);
    for ii = 1:nimgs
        subplot(nchan,nimgs,q);
        imgToUse = imgs{ii}(:,:,chan);
        if exist('cropwindow','var')
            imgToUse = imcrop(imgToUse,cropwindow);
        end
        imshow(imadjust(imgToUse,lims));
        q = q + 1;
    end
end