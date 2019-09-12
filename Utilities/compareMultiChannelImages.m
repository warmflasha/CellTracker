function compareMultiChannelImages(imgs,condToUseForChan,cropwindow,toplabels,sidelabels)

nchan = min(cellfun(@(x) size(x,3), imgs)); %minimum of chan numbers
if ~exist('condToUseForChan','var')  || isempty(condToUseForChan)
    condToUseForChan = ones(nchan,1);
end
nimgs = length(imgs);
q = 1;

ax = axes('Units','normalized', ...
    'Position',[0 0 1 1], ...
    'XTickLabel','', ...
    'YTickLabel','');
set(gca,'Xtick',[]);
set(gca,'Ytick',[]);

[ha, pos] = tight_subplot(nchan,nimgs,0.003,[0.001, 0.03],[0.03, 0.001]);
axes(ax);
if exist('toplabels','var')
    for ii = 1:nimgs
        xpos = pos{ii}(1)+pos{ii}(3)/2-0.01;
        ypos = pos{ii}(2)+pos{ii}(4)+0.01;
        text(xpos,ypos,toplabels{ii},'Color','k','FontSize',24);
    end
end

if exist('sidelabels','var')
    for ii = 1:nchan
        xpos = pos{(ii-1)*nimgs+1}(1)-0.01;
        ypos = pos{(ii-1)*nimgs+1}(2)+pos{(ii-1)*nimgs+1}(4)/2-0.01;
        text(xpos,ypos,sidelabels{ii},'Color','k','Rotation',90,'FontSize',24);
    end
end

for chan = 1:nchan
    lims = stretchlim(imgs{condToUseForChan(chan)}(:,:,chan),[0.3 0.99]);
    for ii = 1:nimgs
        axes(ha(q));
        imgToUse = imgs{ii}(:,:,chan);
        if exist('cropwindow','var') && ~isempty(cropwindow)
            imgToUse = imcrop(imgToUse,cropwindow);
        end
        imshow(imadjust(imgToUse,lims));
        q = q + 1;
    end
end
