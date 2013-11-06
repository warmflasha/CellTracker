function ifit = extractFitFromHist(cnts, frac_bad, method)
%
%    ifit = extractFitFromHist(cnts, frac_bad, method)
%
%   method= 'gamma'  cnts(i) = c*i^a exp(-b*i)
%   method= 'expon'   gamma with a=0
%   method= 'gaussian0'      = c* exp(-b*i^2)
%
% from a histogram counts extract the best fn fit to low values,
% keeping >= 50% of all points. 
%   ifit is first point such that cnts >= fit/(1-frac_bad)
% ie if frac bad = .75, counts in hist bin > 4*fit
% Should use 1000's of pts (= sum counts in histogram) for decent fit.
%   return ifit < 0 if cnts <= gaussian_fit for all bins with more that a
% few counts.
%
% BUGS in the way the parameters are fit to data, least squares over
% weights the tails of distributions and should weight the pts via cnts in
% as in nonlinear least squares.
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
    fprintf(1, 'WARNING too sparse a histogram input to extractGammaFromHist need more points, fewer bins,\ngrouping %d bins together, pts= %d\n',...
        merge, pts);
    cnts = cnts0;
    nc = length(cnts);
else
    merge = 1;
end

sumc = 0;
error = 100*ones(1,nc);
error2 = 0;  % to avoid an undef
for i = 1:nc
    sumc = sumc + cnts(i);
    if sumc<0.5*pts || i<=4  % not enough pts fit or fitting 3 params to >4 pts
        continue
    end
    if cnts(i) < 4 % truncate loop if too few points
        break
    end
    if strcmp(method,'gamma')
        fit = fit_gamma(cnts(1:i));
    elseif strcmp(method,'expon')
        fit = fit_expon(cnts(1:i));
    elseif strcmp(method,'gaussian0')
        fit = fit_gaussian0(cnts(1:i));
    else
        fprintf(1,'ERROR extractFitFromHist: unknown method= %s\n', method);
    end
    fit = fit/sum(fit);
    error(i) = sum( abs(cnts(1:i)/sumc - fit) );
    error2(i) = (cnts(i)/sumc - fit(end))/fit(end);  % additional test
end
% start with bin corresp to min error in fit and 
[minfit, ifit0] = min(error);

% increase ifit until number of counts > (~2)*gaussian prediction
nc = length(error2);
if frac_bad >= 1;
    frac_bad = 0.5;
    fprintf(1, 'WARNING input invalid frac_bad argument %d to extractGammaFromHist(), resetting to 0.5\n', frac_bad);
end
for ifit = ifit0:nc
    if error2(ifit) >= 1/(1 - frac_bad);
        break
    end
end

% warning if error2 never large enough, ifit is the first non trivial term,
% or ifit hits the last bin
if isempty(ifit) || ifit==5 || ifit==nc
    fprintf(1, 'WARNING potential bad fit in extractGammaFromHist(). Try incr # pts or #bins in hist. errors=\n');
    error(1:nc)
    error2(1:nc)
end

ifit = merge*ifit;

if max(error2) < 1
    ifit = -ifit;
    fprintf(1, 'WARNING extractGammaFromHist() is returning an invalid bin number, use default cutoff\n');
end

return


function fit = fit_gamma(cnts)
% return fit to cnts(i) = cc*i^aa exp(-bb*i)
nc = length(cnts);
logcnts = reshape(log(cnts+1), [], 1);
nn = (1:nc)';
coef = [ones(nc,1), log(nn), -nn];
fit = coef \ logcnts;
aa = fit(2);
bb = fit(3);
cc = exp(fit(1));
fit = cc*exp(aa*coef(:,2) - bb*nn);
return

function fit = fit_expon(cnts)
% return fit to cnts(i) = cc*exp(-bb*i)
nc = length(cnts);
logcnts = reshape(log(cnts+1), [], 1);
nn = (1:nc)';
coef = [ones(nc,1), -nn];
fit = coef \ logcnts;
bb = fit(2);
cc = exp(fit(1));
fit = cc*exp( - bb*nn);
return

function fit = fit_gaussian000(cnts)
% return fit to cnts(i) = cc*exp(-bb*i^2) via second moment
nc = length(cnts);
nn = (1:nc)';
xsum=0;
for i = 1:nc
    xsum = xsum + cnts(i)*i*i;
end
xsum = xsum/sum(cnts);
bb = 1/(2*xsum);
fit = exp(-bb*nn.*nn);
fit = sum(cnts)*fit/sum(fit);
return

function fit = fit_gaussian00(cnts)
% return fit to cnts(i) = cc*exp(-bb*i^2) via weight < sigma ie number of
% std, sigma=1 -> get 68% of total weight
nc = length(cnts);
sigma = 1;
frac = erf(sigma/sqrt(2));
sumcnts = sum(cnts);
csum = cumsum(cnts);
ii = find(csum > frac*sumcnts, 1, 'first');
bb = 1/(2*ii*ii);
nn = (1:nc)';
fit = exp(-bb*nn.*nn);
fit = sum(cnts)*fit/sum(fit);
return

function fit = fit_gaussian0(cnts)
% return fit to cnts(i) = max(cnts)*exp(-bb*i^2) via matching 2x decr in
% fit
nc = length(cnts);
max_cnts = max(cnts);
ii = find(cnts < max_cnts/2, 1, 'first');
bb = log(2)/(ii*ii);
nn = (1:nc)';
fit = max_cnts*exp(-bb*nn.*nn);
fit = sum(cnts)*fit/sum(fit);
return
