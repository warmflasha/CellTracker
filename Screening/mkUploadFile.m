function mkUploadFile(pn,sdata)
datall =[]; datall2=[];
wn=mkWellNames;
fid=fopen('goodhits.txt','w');
fid2=fopen('partialhits.txt','w');
for ii = 1:length(pn)
    
    hitsall=sdata{pn(ii)}.hits1 | sdata{pn(ii)}.hits6;
    hitsallp=sdata{pn(ii)}.hits1partial | sdata{pn(ii)}.hits6partial;

    dat=[find(hitsall) sdata{pn(ii)}.zsc(hitsall,:)];
    datall=[datall; dat];
    
    dat2=[find(hitsallp) sdata{pn(ii)}.zsc(hitsallp,:)];
    datall2=[datall2; dat2];
    
    
    xx=int2str(pn(ii));
    if length(xx) == 1
        xx=['0' xx];
    end
    
    wn2print=wn(hitsall);
    for jj=1:length(wn2print)
        wntmp=wn2print{jj};
        if wntmp(2)=='0'
            wntmp = [wntmp(1) wntmp(3:end)];
        end
        fprintf(fid,'%s_%s\n',xx,wntmp);
    end
    
     wn2print2=wn(hitsallp);
    for jj=1:length(wn2print2)
        wntmp=wn2print2{jj};
        if wntmp(2)=='0'
            wntmp = [wntmp(1) wntmp(3:end)];
        end
        fprintf(fid2,'%s_%s\n',xx,wntmp);
    end
end
fclose(fid);
dlmwrite('genedata_good.txt',datall);
dlmwrite('genedata_partial.txt',datall2);