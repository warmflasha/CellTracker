function ifit = extractGaussianFromHist(cnts, frac_bad)
%
%    ifit = extractGaussianFromHist(cnts, frac_bad)
%
% from a histogram counts extract the best gaussian fit to the low values,
% keeping >= 50% of all points. 
%   ifit is first point such that cnts >= gaussian_fit/(1-frac_bad)
% ie if frac bad = .75, counts in hist bin > 4*gaussian_fit
% Should use 1000's of pts (= sum counts in histogram) for decent fit.
%   return ifit < 0 if cnts <= gaussian_fit for all bins with more that a
% counts.
% 

cnts = reshape(cnts, [], 1);  
pts = sum(cnts);
nc = length(cnts);

% if minimal data, merge bins to get statistically sig counts in bins
nbins = round(pts/10);
merge = floor(nc/nbins);
if merge > 1
    cnts0 = zeros(floor((nc-1)/merge)+1, 1);
    for i=1:nc
        ii = floor((i-1)/merge) + 1;
        cnts0(ii) = cnts0(ii) + cnts(i);
    end
    fprintf(1, 'WARNING too sparse a histogram input to extractGaussianFromHist need more points, fewer bins,\ngrouping %d bins together, pts= %d\n',...
        merge, pts);
    cnts = cnts0;
    nc = length(cnts);
else
    merge = 1;
end

sumc = 0;
%logcnts = log(cnts+1);
% n = (1:nc)';
% nn = n.^2;
%coef = [ones(nc,1), n, n.^2];
error = 100*ones(1,nc);
error2 = 0;  % to avoid an undef
for i = 1:nc
    sumc = sumc + cnts(i);
    if sumc<0.5*pts || i<=4  % fitting 3 params to >4 pts
        continue
    end
    if cnts(i) < 4 % truncate loop if too few points
        break
    end
    [i1, i2] = mean_rms_cnts(cnts(1:i));
    gaus = exp(-((1:i) - i1).^2/(2*i2) )';
    gaus = gaus/sum(gaus);
    error(i) = sum( abs(cnts(1:i)/sumc - gaus) );
    error2(i) = (cnts(i)/sumc - gaus(end))/gaus(end);  % additional test
%     fit of quad fn to log of counts
%     [cnts(1:i)/sumc, gaus]
% poly fit to log cnts did not work well
%     fit = coef(1:i, 1:3) \ logcnts(1:i);
%     error(i) = sum( abs(logcnts(1:i) - coef(1:i, 1:3)*fit) )/sum(logcnts(1:i));
%     (coef(1:i, 1:3)*fit)'
end
% start with bin corresp to min error in fit and 
[minfit, ifit0] = min(error);

% increase ifit until number of counts > (~2)*gaussian prediction
nc = length(error2);
if frac_bad >= 1;
    frac_bad = 0.5;
    fprintf(1, 'WARNING input invalid frac_bad argument %d to extractGaussianFromHist(), resetting to 0.5\n', frac_bad);
end
for ifit = ifit0:nc
    if error2(ifit) >= 1/(1 - frac_bad);
        break
    end
end

if isempty(ifit) || ifit==5 || ifit==nc
    fprintf(1, 'WARNING potential bad fit in extractGaussianFromHist(). Try incr # pts or #bins in hist. errors=\n');
    error(1:nc)
    error2(1:nc)
end

ifit = merge*ifit;

if max(error2) < 1
    ifit = -ifit;
    fprintf(1, 'WARNING extractGaussianFromHist() is returning an invalid bin number, use default cutoff\n');
end

return


function [mean, rms] = mean_rms_cnts(cnts)
% for counts in uniformily space histogram bins compute mean bin index and
% rms of bin index characterizing a gaussian fit to data

sumc(1:3) = 0;
for i = 1:length(cnts)
    sumc(1) = sumc(1) + cnts(i);
    sumc(2) = sumc(2) + i*cnts(i);
    sumc(3) = sumc(3) + i*i*cnts(i);
end
mean = sumc(2)/sumc(1);
rms = sumc(3)/sumc(1) - mean^2;
