function outdat=mkNormPlot(matfile,ps)

load(matfile,'cells2','pictimes');

if ~exist('ps','var')
    ps='k.-';
end

avgs=zeros(100,1); counter=zeros(100,1);
for ii=1:length(cells2)
    xx=cells2(ii).onframes;
    %if(cells2(ii).onframes(1)==1)
       avgs(xx)=avgs(xx)+cells2(ii).data(:,6)/cells2(ii).data(1,6);
       counter(xx)=counter(xx)+ones(length(xx),1);
    %end
end

inds=counter > 0;
outdat=avgs(inds)./counter(inds);
plot(pictimes(inds),outdat,ps)