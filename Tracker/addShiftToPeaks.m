function addShiftToPeaks(matfile,fr_stim)
% peaks = addShiftToPeaks(peaks,imgfiles,fr_stim)
% ----------------------------------------------------------
% For cases where microscope was bumped, adds a shift to the x,y position
% in peaks
% inputs:
%   -peaks: raw data from frames
%   -imgfiles: structure which contains the compressed binary masks
%   -fr_stim: stimulation frame (i.e. frame where the shift occurred)
% outputs: peaks with shifted x,y coordinates. 

load(matfile,'peaks','imgfiles');

%compute the shift
n1 = uncompressBinaryImg(imgfiles(fr_stim-1).compressNucMask); % this chunck is to calculate the actual shift vector, and need not be performed in the loop
n2 = uncompressBinaryImg(imgfiles(fr_stim+1).compressNucMask);
bw1 = bwconncomp(n1);
bw2 = bwconncomp(n2);
stats1 = regionprops(bw1,'Centroid');
stats2 = regionprops(bw2,'Centroid');
xy1 = [stats1(1).Centroid];
xy2 = [stats2(1).Centroid];
diffx = sqrt(power(xy1(1)-xy2(1),2));
diffy = sqrt(power(xy1(2)-xy2(2),2));
shift = round([diffx,diffy]);

for k=fr_stim+1:length(peaks)
    if ~isempty(peaks{k})
        peaks{k}(:,1:2)=bsxfun(@plus,peaks{k}(:,1:2),shift);
    end
end

%peaks{fr_stim} = []; % zero the point where there was shift (only if there was a shift)

save(matfile,'peaks','-append');

