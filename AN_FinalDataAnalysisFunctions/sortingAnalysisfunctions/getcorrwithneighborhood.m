
function [r1,r2,r3,r4] = getcorrwithneighborhood(colonylocalstats,colonysizes)
r1 = zeros(size(colonylocalstats,2),1);
r2 = zeros(size(colonylocalstats,2),1);
r3 = zeros(size(colonylocalstats,2),1);
r4 = zeros(size(colonylocalstats,2),1);

brathresh = 0;
count = 0;
if ~isempty(colonysizes)
    for jj=1:size(colonylocalstats,2) % loop over colonies
        if ~isempty(colonylocalstats(jj).allstats)          
            
            braincell = cat(1,colonylocalstats(jj).allstats.braincell);
            greenincell = cat(1,colonylocalstats(jj).allstats.greenincell);
            cfpcellsclose =  cat(1,colonylocalstats(jj).allstats.cfpclose);
            cfpfracclose =  cat(1,colonylocalstats(jj).allstats.cfpclosefr);
            xycell= cat(1,colonylocalstats(jj).allstats.currcell);
            colsz =  size(braincell,1);
            if (colsz>colonysizes(1))  && (colsz <colonysizes(2)) % test various conditions here
                count = count+1;
                % may consider only brapositive (braincell>brathresh)
                r= corrcoef(greenincell(braincell>brathresh),cfpcellsclose(braincell>brathresh));
                r1(jj,1) = r(2);
                r = corrcoef(braincell(braincell>brathresh),cfpfracclose(braincell>brathresh));
                r2(jj,1) = r(2);
                r = corrcoef(greenincell(braincell>brathresh),cfpfracclose(braincell>brathresh));
                r3(jj,1) = r(2);
                r = corrcoef(greenincell(braincell>brathresh),braincell(braincell>brathresh));
                r4(jj,1) = r(2);
            end
        end
    end
end
if isempty(colonysizes)
    for jj=1:size(colonylocalstats,2) % loop over colonies
        if ~isempty(colonylocalstats(jj).allstats)
            braincell = cat(1,colonylocalstats(jj).allstats.braincell);
            greenincell = cat(1,colonylocalstats(jj).allstats.greenincell);
            cfpcellsclose =  cat(1,colonylocalstats(jj).allstats.cfpclose);
            cfpfracclose =  cat(1,colonylocalstats(jj).allstats.cfpclosefr);
            xycell= cat(1,colonylocalstats(jj).allstats.currcell);
            colorrand =randi(50);
            colsz =  size(braincell,1);
            count = count+1;
            % may consider only brapositive (braincell>brathresh)
            r= corrcoef(braincell(braincell>brathresh),cfpcellsclose(braincell>brathresh));
            r1(jj,1) = r(2);
            r = corrcoef(braincell(braincell>brathresh),cfpfracclose(braincell>brathresh));
            r2(jj,1) = r(2);
            r = corrcoef(greenincell(braincell>brathresh),cfpfracclose(braincell>brathresh));
            r3(jj,1) = r(2);
            r = corrcoef(greenincell(braincell>brathresh),braincell(braincell>brathresh));
            r4(jj,1) = r(2);
            
        end
    end
    
end

 
 
end