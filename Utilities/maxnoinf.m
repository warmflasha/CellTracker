function xmax=maxnoinf(x)
xnoinf=x(~isinf(x));
xmax=max(xnoinf);