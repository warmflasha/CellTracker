function newmasks = cleanIlastikMasks(masks,discardsmall)

nt = size(masks,3);
newmasks = false(size(masks));

for ii = 1:nt
    mask_curr = imfill(masks(:,:,ii),'holes');
    mask_curr = bwareaopen(mask_curr,discardsmall);
    newmasks(:,:,ii) = mask_curr;
end