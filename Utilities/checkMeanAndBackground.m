function [mf mb]=checkMeanAndBackground(matfile)

load(matfile,'statsArray','pictimes');
for ii=1:length(statsArray)
    mf(ii)=mean([statsArray{ii}.NuclearAvr]);
    mb(ii)=mean([statsArray{ii}.BackgroundIntensity]);
end

plot(pictimes,[mf' mb' mf'+mb'],'.-','LineWidth',2);