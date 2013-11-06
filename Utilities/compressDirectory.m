function compressDirectory(indir,outfile,suf,jqual,bits)

ff=dir([indir filesep '*.' suf]);

tmpdir=strtok(outfile,'.');
mkdir([indir filesep tmpdir]);

for ii=1:length(ff)
    
    if ~mod(ii,100)
        disp(int2str(ii));
    end
    
    imgname=strtok(ff(ii).name,'.');
    img=imread([indir filesep ff(ii).name]);
    
    imwrite(img,[indir filesep tmpdir filesep imgname '.jpg'],'jpeg','Quality',jqual,'BitDepth',bits);

end

tar([tmpdir '.tgz'],[indir filesep tmpdir]);

