function sm=sumnonan(x)

notin=isnan(x) | isinf(x);
x(notin)=[];
sm=sum(x);