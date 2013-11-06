direc='131024_GFPS4_MAN1';
% sampleRange=1:8;
% posRange=1:5;
prefix= 'c_Sample';
nstring='w3RFP';
sstring='w2GFP User';
%paramfile='setUserParamCCC10xBS110607_RFPsmad2';
paramfile='setUserParamCCC20xAW2';
%paramfile='setUserParamSC20X';
%samp=[1 5 7 8];
%samp=1:5;
ind1=1:5;
ind2=1:6;
[I J]=meshgrid(ind1,ind2);
allpairs=[I(:) J(:)];
%backgroundstr={'1_w3RFP_s6','1_w2GFP User_s6'};
%im1=imread('130319/130319_Sample1_w2GFP User_s6_t1.TIF');
%im2=imread('130319/130319_Sample1_w3RFP_s6_t1.TIF');
%backgroundstr={im2,im1};
parfor kk=1:size(allpairs,1)
    ii=allpairs(kk,1);
    jj=allpairs(kk,2);
    nucstring=[prefix int2str(jj) '_' nstring '_s' int2str(ii)];
    smadstring=[prefix int2str(jj) '_' sstring '_s' int2str(ii)];
    %nucstring=[prefix  '_' nstring '_s' int2str(ii) '_'];
    %smadstring=[prefix '_' sstring '_s' int2str(ii) '_'];
    outfile=[direc filesep 'S' int2str(jj) 's' int2str(ii) 'out.mat'];
    try
        runSegmentCells(direc,outfile,66,nucstring,smadstring,paramfile);
        %runSegmentCells(direc,outfile,70,nucstring,smadstring,paramfile,[],[],backgroundstr);

    catch err
        %rethrow(err);
        disp(['Error with Sample ' int2str(jj) ' position ' int2str(ii)]);
    end
end
%%
% bkGFP=mkBackgroundImage(direc,sstring,300);
% bkRFP=mkBackgroundImage(direc,nstring,300);
% gfilt=fspecial('gaussian',10,3);
% bkGFP=imfilter(bkGFP,gfilt);
% bkRFP=imfilter(bkRFP,gfilt);
% %%
%     parfor ii=1:32
%         nucstring=[prefix '_' nstring '_s' int2str(ii) '_'];
%         smadstring=[prefix '_' sstring '_s' int2str(ii) '_'];
%         outfile=[direc filesep 's' int2str(ii) 'out.mat'];
%        try
%             runSegmentCells(direc,outfile,125,nucstring,smadstring,paramfile,[],[],{bkGFP,bkRFP});
%         catch
%             disp(['Error with Sample ' int2str(ii) ' position ' int2str(ii)]);
%         end
%     end
