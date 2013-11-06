function showWellPictures(timepoint,plate,well)

basefile = '/Volumes/Compatible/ScreenData';

if timepoint == 1
    prefix1='S5-MP-';
    prefix2='S6-MP-';
elseif timepoint==2
    prefix1='S7-MP-';
    prefix2='S8-MP-';
end

pn=int2str(plate);
if length(pn) == 1
    pn =[ '0' pn];
end

f1= dir([basefile filesep prefix1 pn filesep '*' well '*d1.TIF']);
f2= dir([basefile filesep prefix2 pn filesep '*' well '*d1.TIF']);

for ii=1:length(f1)
    tt=imread([basefile filesep prefix1 pn filesep f1(ii).name]);
    figure; imshow(tt,[]);
end

for ii=1:length(f2)
    tt=imread([basefile filesep prefix2 pn filesep f2(ii).name]);
    figure; imshow(tt,[]);
end