function col=plotgoodcolonies(col)
    q=1;
    figure;
    for ii=1:length(col)       
        if col(ii).aspectRatio > 0.66 && col(ii).aspectRatio < 1.5 
            col(ii).good=1;
            if ii > 1300 && ii < 1400
            subplot(10,10,q); plotcolorcolonies(col(ii).data,0,1); title(ii); axis square;
            q=q+1;
            end
            if q > 100
                q=1;
                figure;
            end
        else
            col(ii).good=0;
        end
    end
end