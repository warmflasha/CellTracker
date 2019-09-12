function plot_handle = barWithError(data,errs,fig_handle)

if exist('fig_handle','var')
    figure(fig_handle);
else
    figure;
end

h = bar(data); hold on;

for ii = 1:length(h)
    xx = h(ii).XData + h(ii).XOffset;
    errorbar(xx,data(:,ii),errs(:,ii),'k.','LineWidth',2.5);
end

plot_handle = h;
hold off;