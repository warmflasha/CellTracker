function [bigmatrix badwells]=exportAllData

datafolder = '~/Dropbox/Screening/ScreenOutFiles';

bigmatrix = zeros(384,204*3);


col1 = 1;q=1;
for snum = 5:8
    for platenum = 1:51
        pn = int2str(platenum);
        if length(pn) == 1
            pn = ['0' pn];
        end
        filename = ['S' int2str(snum) '-MP-' pn '.mat'];
        load([datafolder filesep filename]);
        for ii=1:384
            if ~isempty(outdatall{ii})
            avgs = [meannonan(outdatall{ii}(:,6)) meannonan(outdatall{ii}(:,7)) ...
                meannonan(outdatall{ii}(:,6)./outdatall{ii}(:,7))];
            else
                avgs = [ 0 0 0];
                badwells(q).screen = snum;
                badwells(q).plate = platenum;
                badwells(q).well = ii;
                q=q+1;
            end
            
            bigmatrix(ii,col1:(col1+2))=avgs;
        end
        col1=col1+3;
    end
end
        