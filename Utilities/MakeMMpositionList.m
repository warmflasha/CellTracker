

% define a list of 9 positions per well
Positions = [-1,1;0,1;1,1;-1,0;0,0;1,0;-1,-1;0,-1;1,-1];

% scaleFactor = 

WellCentersCoordinates = []; %to be defined

fid = fopen('exp.pos','a');

% write the "header" of the file
fprintf(fid,'{\n');
fprintf(fid,'\t"VERSION": 3,\n');
fprintf(fid,'\t"ID": "Micro-Manager XY-position list",\n');
fprintf(fid,'\t"POSITIONS": [\n');

% definition of each position

NbWells = 2;
NbPosPerWell = length(Positions);
WellName = ['a1';'a2']

for jj=1:NbWells
    
%     
%     XwellCenter = WellCentersCoordinates(jj,1);
%     YwellCenter = WellCentersCoordinates(jj,2);
%     ZwellCenter = WellCentersCoordinates(jj,2);
%     WellName = WellNames(jj);
    
    for ii = 1:NbPosPerWell

        
%         Xpos = 
%         Ypos = 
%         Zpos = 
        
        %% well number paded with zeros to make position name
        L=3;
        z = '000';
        s1 = num2str(ii);
        L1 = length(s1);
        if L1 < L
            str = [z(1:(L - L1)) s1];
        else
            str = s1;
        end

        posname = [WellName(jj,:) '_' str]
        
        %% definition of one position
    fprintf(fid,'\t{\n');
    fprintf(fid,'\t\t"GRID_COL": 0,\n');
    fprintf(fid,'\t\t"DEVICES": [\n');
    fprintf(fid,'\t\t{\n');
    fprintf(fid,'\t\t"DEVICE": "FocusDrive",\n');
    fprintf(fid,'\t\t"AXES": 1,\n');
    fprintf(fid,'\t\t"Y": 0,\n');
    fprintf(fid,'\t\t"X": 2142.0638,\n');%edit Z position here
    fprintf(fid,'\t\t"Z": 0\n');
    fprintf(fid,'\t\t},\n');
    fprintf(fid,'\t\t{\n');
    fprintf(fid,'\t\t"DEVICE": "XYStage",\n');
    fprintf(fid,'\t\t"AXES": 2,\n');
    fprintf(fid,'\t\t"Y": 19659.848332589998,\n');%edit Y position here
    fprintf(fid,'\t\t"X": 20873.036188,\n');%edit X position here
    fprintf(fid,'\t\t"Z": 0\n');
    fprintf(fid,'\t\t}\n');
    fprintf(fid,'\t\t],\n');
    fprintf(fid,'\t\t"PROPERTIES": {},\n');
    fprintf(fid,'\t\t"DEFAULT_Z_STAGE": "FocusDrive",\n');
    fprintf(fid,'\t\t"LABEL": "well1-1",\n');%edit position label here
    fprintf(fid,'\t\t"GRID_ROW": 0,\n');
    fprintf(fid,'\t\t"DEFAULT_XY_STAGE": "XYStage"\n');
    fprintf(fid,'\t},\n');
    fprintf(fid,'\t\t\n');
    fprintf(fid,'\t\t\n');
%%


    end

end

fprintf(fid,'\t]\n');
fprintf(fid,'}\n');


fclose (fid)
         
         
         
         
         
         
      
