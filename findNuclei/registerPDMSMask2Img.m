function mask_out = registerPDMSMask2Img(mask_in, img)
%
%   mask_out = registerPDMSMask2Img(mask_in, img)
%
% Given a binary mask=1 in PDMS region, shift it so as to best align with the
% low intensity regions of img. Return shifted mask, that can be applied
% directly to img.

verbose = 1;  % to print graphics
pow2 = 4;   % coarsen pixels and kill high k by this facter == 2^int

% eliminate top/bottom edges (assuming dims/16 = int)
[m, n] = size(img);
cut = round(m/16);
rows = (cut+1):(m - cut);
img  = img(rows, 1:n);
mask = mask_in(rows, 1:n);

% get rid of hi frequencies and k=0
ftI = fft2(double(img));
ftI = ftI(1:m/pow2, 1:n/pow2);
ftI(1,:) = 0;
ftI(:,1) = 0;
ftM = fft2(rot90(mask,2));
ftM = ftM(1:m/pow2, 1:n/pow2);
cc = real( ifft2(ftI .* ftM) );

% cc has approx period 6 since that number of features in vertical direction in
% CCC.  and projections take up about 1/6 of horizontal, 
% thus restrict to looking for min within one period of correl data
[m2, n2] = size(cc);
[min_col, i_col] = min(cc);
[~, jj] = min(min_col);
ii = i_col(jj);

% correct indices to 0 base spatial shift
if ii >= 5*m2/6
    ii = ii - m2 - 1;
elseif ii <= m2/6
    ii = ii - 1;
else
    fprintf(1, 'WARNING registerPDMSMask2Img(): implausible shift found for mask ii= %d\n', ii);
end
if jj >= 5*n2/6
    jj = jj - n2 - 1;
elseif jj <= n2/6
    jj = jj - 1;
else
    fprintf(1, 'WARNING registerPDMSMask2Img(): implausible shift found for mask jj= %d\n', jj);
end

shift = pow2*[ii, jj];
mask_out = shift_mask(shift, mask_in);
%%%%% need fill in mask top and bottom when shift.........

%% NB showing data with top/bottom edges clipped
if verbose
    mask_shft = shift_mask(shift, mask);
    showImgEdgePts(img, edge(mask_shft), []);
    title('img with optimal aligned PDMS mask, NB clipped top|bottom, need fill in original ');
end

return

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = shift_mask(shift, mask)
%
%   mask_out(r + shift) = mask_in(r),
%
% and fill in regions of mask_out that do not overlay mask_in with translation for x-shift 
% and =1 for y-shift 

ii = shift(1); jj = shift(2);
[m,n] = size(mask);
out = false(size(mask));

for i = 1:m
    if (i-ii < 1)||(i-ii > m)
        for j=1:n
            out(i,j) = 1;
        end
        continue
    end
    if jj > 0
        out(i, 1:jj) = mask(i-ii, 1:jj);
        for j = (jj+1):n
            out(i,j) = mask(i-ii, j-jj);
        end
    else
        out(i, (n-jj):n) = mask(i-ii, (n-jj):n);
        for j = 1:(n-jj-1)
            out(i,j) = mask(i-ii, j-jj);
        end
    end
end
        
