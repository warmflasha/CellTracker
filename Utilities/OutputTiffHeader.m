%--------------------------------------------------------------------------
function  data = OutputTiffHeader( filename )
% -------------------------------------------------------------------------
%       Name: OutputTiffHeader
%       Disc: function to extract header information
%           
%       Input: filename - image file to extract data from
%
%       Output: data - image header dataj
%
%       Owner: Lad Dombrowski
%                       Center for Live Cell Imaging
%                       Department of Microbiology and Immunology
%                       University of Michigan
%                       http://sitemaker.umich.edu/4dimagingcenter/center_for_live-cell_imaging_home
%               
%       Files needed: TiffHeader.fig, TiffHeader.m, OutputTiffHeader.m
%                       
%               
%------------------------------------------------------------------------
%
% This software is based on the tiffread software 
% provided at no cost by a public research institution.
%
% Francois Nedelec
% nedelec (at) embl.de
% Cell Biology and Biophysics, EMBL; Meyerhofstrasse 1; 69117 Heidelberg; Germany
% http://www.embl.org
% http://www.cytosim.org

data(1).filename = ['filename = ' filename];

%Optimization: join adjacent TIF strips: this results in faster reads
consolidateStrips = 1;

%if there is no argument, we ask the user to choose a file:
if (nargin == 0)
    [filename, pathname] = uigetfile('*.tif;*.stk;*.lsm', 'select image file');
    filename = [ pathname, filename ];
end

% if (nargin<=1)  img_first = 1; img_last = 10000; end
% if (nargin==2)  img_last = img_first;            end

% default to everything
img_first = 1;
img_last = 10000;

% not all valid tiff tags have been included, as they are really a lot...
% if needed, tags can easily be added to this code
% See the official list of tags:
% http://partners.adobe.com/asn/developer/pdfs/tn/TIFF6.pdf
%
% the structure IMG is returned to the user, while TIF is not.
% so tags usefull to the user should be stored as fields in IMG, while
% those used only internally can be stored in TIF.

global TIF;
TIF = [];

%counters for the number of images read and skipped
img_skip  = 0;
img_read  = 0;

% set defaults values :
TIF.SampleFormat     = 1;
TIF.SamplesPerPixel  = 1;
TIF.BOS              = 'l';          %byte order string

if  isempty(findstr(filename,'.'))
    filename = [filename,'.tif'];
end

[TIF.file, message] = fopen(filename,'r','l');
if TIF.file == -1
    filename = strrep(filename, '.tif', '.stk');
    [TIF.file, message] = fopen(filename,'r','l');
    if TIF.file == -1
        error(['file <',filename,'> not found.']);
    end
end

% read header


% keep track of the number of images
imageIndex = 1;

% read byte order: II = little endian, MM = big endian
byte_order = setstr(fread(TIF.file, 2, 'uchar'));

if ( strcmp(byte_order', 'II') )
    TIF.BOS = 'l';                                %normal PC format
    data(imageIndex,1).byteOrder = 'Byte Order = II';
elseif ( strcmp(byte_order','MM') )
    TIF.BOS = 'b';
    data(imageIndex,1).byteOrder = 'Byte Order = MM';
else
    error('This is not a TIFF file (no MM or II).');
end

%----- read in a number which identifies file as TIFF format
tiff_id = fread(TIF.file,1,'uint16', TIF.BOS);
if (tiff_id ~= 42)
    error('This is not a TIFF file (missing 42).');
end

% create dummy exposures for .tifs - ljd (5-22-08)
TIF.info.Exposure = 1;

%----- read the byte offset for the first image file directory (IFD)
ifd_pos = fread(TIF.file,1,'uint32', TIF.BOS);

while (ifd_pos ~= 0)

    clear IMG;
    IMG.filename = fullfile( pwd, filename );

    % move in the file to the first IFD
    fseek(TIF.file, ifd_pos, -1);
    data(imageIndex,1).position = ['reading img at pos : ' num2str(ifd_pos)];

    %read in the number of IFD entries
    num_entries = fread(TIF.file,1,'uint16', TIF.BOS);
    data(imageIndex,1).numEntries = ['num_entries = ' num2str(num_entries)];

    %read and process each IFD entry
    for i = 1:num_entries

        % save the current position in the file
        file_pos  = ftell(TIF.file);
        data(imageIndex,i).filePosition = ['File Position = ' num2str(file_pos)];

        % read entry tag
        TIF.entry_tag = fread(TIF.file, 1, 'uint16', TIF.BOS);

        entry = readIFDentry;
        
        data(imageIndex,i).entryTag = ['Entry tag = ' num2str(TIF.entry_tag)];
 
        %disp(strcat('reading entry <',num2str(TIF.entry_tag),'>'));
        switch TIF.entry_tag
            case 254
                TIF.NewSubfiletype = entry.val;
                data(imageIndex,i).string = ['Sub-file Type = ' num2str(entry.val)];
            case 256         % image width - number of column
                IMG.width          = entry.val;
                data(imageIndex,i).string = ['Image Width = ' num2str(entry.val)];
            case 257         % image height - number of row
                IMG.height         = entry.val;
                TIF.ImageLength    = entry.val;
                data(imageIndex,i).string = ['Image Height = ' num2str(entry.val)];
            case 258         % BitsPerSample per sample
                TIF.BitsPerSample  = entry.val;
                TIF.BytesPerSample = TIF.BitsPerSample / 8;
                IMG.bits           = TIF.BitsPerSample(1);
                data(imageIndex,i).string = ['Bits per sample = ' num2str(IMG.bits)];
                %fprintf(1,'BitsPerSample %i %i %i\n', entry.val);
            case 259         % compression
                if (entry.val ~= 1) error('Compression format not supported.'); end
                data(imageIndex,i).string = ['Compression = ' num2str(entry.val)];
            case 262         % photometric interpretation
                TIF.PhotometricInterpretation = entry.val;
                data(imageIndex,i).string = ['Photometric Interpretation = ' num2str(entry.val)];
                if ( TIF.PhotometricInterpretation == 3 )
                    fprintf(1, 'warning: ignoring the look-up table defined in the TIFF file');
                end
            case 269
                IMG.document_name  = entry.val;
                data(imageIndex,i).string = ['Document Name = ' entry.val];
            case 270         % comment:
                TIF.info           = parseMM_info(entry.val,i);
                data(imageIndex,i).string = 'Metamorph info';
                data(imageIndex,i).mmInfo = TIF.info;
            case 271
                IMG.make = entry.val;
                data(imageIndex,i).string = ['Make = ' num2str(entry.val)];
            case 273         % strip offset
                TIF.StripOffsets   = entry.val;
                TIF.StripNumber    = entry.cnt;
                data(imageIndex,i).string = ['Strip Offsets/Number = ' num2str(entry.val(1)) '/' num2str(entry.cnt)];
                %fprintf(1,'StripNumber = %i, size(StripOffsets) = %i %i\n', TIF.StripNumber, size(TIF.StripOffsets));
            case 277         % sample_per pixel
                TIF.SamplesPerPixel  = entry.val;
                data(imageIndex,i).string = ['Color image: sample per pixel = ' num2str(entry.val)];
                %fprintf(1,'Color image: sample_per_pixel=%i\n',  TIF.SamplesPerPixel);
            case 278         % rows per strip
                TIF.RowsPerStrip   = entry.val;
                data(imageIndex,i).string = ['Rows per strip = ' num2str(entry.val)];
            case 279         % strip byte counts - number of bytes in each strip after any compressio
                TIF.StripByteCounts= entry.val;
                data(imageIndex,i).string = ['Strip Byte Count = ' num2str(entry.val(1))];
            case 282         % X resolution
                IMG.x_resolution   = entry.val;
                data(imageIndex,i).string = ['X resolution = ' num2str(entry.val(1)) ',' num2str(entry.val(2))];
            case 283         % Y resolution
                IMG.y_resolution   = entry.val;
                data(imageIndex,i).string = ['Y resolution = ' num2str(entry.val(1)) ',' num2str(entry.val(2))];
            case 284         %planar configuration describe the order of RGB
                TIF.PlanarConfiguration = entry.val;
                data(imageIndex,i).string = ['Planar configuration = ' num2str(entry.val)];
            case 296         % resolution unit
                IMG.resolution_unit= entry.val;
                data(imageIndex,i).string = ['Resolution units = ' entry.typechar];
            case 305         % software
                IMG.software       = entry.val;
                len = length(entry.val);
                name = '';
                for iname = 1:len
                    name = [name entry.val(iname)];
                end
                data(imageIndex,i).string = ['Software = ' name];
            case 306         % datetime
                IMG.datetime = entry.val;
                len = length(entry.val);
                filedate = '';
                for idate = 1:len
                    filedate = [filedate entry.val(idate)];
                end
                data(imageIndex,i).string = ['Date-Time = ' filedate];
            case 315
                IMG.artist         = entry.val;
                data(imageIndex,i).string = ['Artist = ' entry.val];
            case 317        %predictor for compression
                data(imageIndex,i).string = ['Predictor for compression = ' num2str(entry.val)];
                if (entry.val ~= 1) error('unsuported predictor value'); end
            case 320         % color map
                IMG.cmap           = entry.val;
                IMG.colors         = entry.cnt/3;
                data(imageIndex,i).string = ['Color Map/Colors = ' num2str(entry.val) '/' num2str(entry.cnt/3)];
            case 339
                TIF.SampleFormat   = entry.val;
                data(imageIndex,i).string = ['Sample Format = ' num2str(entry.val)];
                if (( TIF.SampleFormat ~= 1) && (TIF.SampleFormat ~= 3))
                    error(sprintf('unsuported sample format = %i', TIF.SampleFormat));
                end
            case 33628       %metamorph specific data
                IMG.MM_private1    = entry.val;
                % ljd 6-4-08 added illumination setting and creation time variables
                if (isfield(TIF, 'MM_illumSetting'))
                    IMG.MM_illumSetting = TIF.MM_illumSetting;
                end
                if (isfield(TIF, 'MM_ctime'))
                    IMG.MM_ctime = TIF.MM_ctime;
                end
                data(imageIndex,i).string = 'Metamorph Private Data';
            case 33629       %this tag identify the image as a Metamorph stack!
                TIF.MM_stack       = entry.val;
                TIF.MM_stackCnt    = entry.cnt;
                data(imageIndex,i).string = ['Metamorph Stack - count = ' num2str(entry.cnt)];
                if ( img_last > img_first )
                    waitbar_handle = waitbar(0,'Please wait...','Name',['Reading ' filename]);
                end
            case 33630       %metamorph stack data: wavelength  
                TIF.MM_wavelength  = entry.val;
                data(imageIndex,i).string = ['Metamorph wavelength = ' num2str(entry.val(1)) ',' num2str(entry.val(2))];
            case 33631       %metamorph stack data: gain/background?
                TIF.MM_private2    = entry.val;
                data(imageIndex,i).string = ['Metamorph - gain/background = ' num2str(entry.val(1)) ...
                                ',' num2str(entry.val(2)) ];
            case 34412       % Zeiss LSM data (I have no idea what that represents...)
                IMG.LSM            = entry.val;
                data(imageIndex,i).string = ['Zeiss LSM data = ' num2str(entry.val)];
            otherwise
                data(imageIndex,i).string = ['Unrecognized tag = ' num2str(TIF.entry_tag)];
                fprintf(1,'ignored TIFF entry with tag %i (cnt %i)\n', TIF.entry_tag, entry.cnt);
        end
        % move to next IFD entry in the file
        fseek(TIF.file, file_pos+12,-1);
    end

    %Planar configuration is not fully supported
    %Per tiff spec 6.0 PlanarConfiguration irrelevent if SamplesPerPixel==1
    %Contributed by Stephen Lang
    if ((TIF.SamplesPerPixel ~= 1) && (TIF.PlanarConfiguration == 1))
        error(sprintf('PlanarConfiguration = %i not supported', TIF.PlanarConfiguration));
    end

    %total number of bytes per image:
    PlaneBytesCnt = IMG.width * IMG.height * TIF.BytesPerSample;

    data(imageIndex,i).bytesPerImage = ['Bytes per image = ' num2str(PlaneBytesCnt)];
    
    if consolidateStrips
        %Try to consolidate the strips into a single one to speed-up reading:
        BytesCnt = TIF.StripByteCounts(1);

        if BytesCnt < PlaneBytesCnt

            ConsolidateCnt = 1;
            %Count how many Strip are needed to produce a plane
            while TIF.StripOffsets(1) + BytesCnt == TIF.StripOffsets(ConsolidateCnt+1)
                ConsolidateCnt = ConsolidateCnt + 1;
                BytesCnt = BytesCnt + TIF.StripByteCounts(ConsolidateCnt);
                if ( BytesCnt >= PlaneBytesCnt ) break; end
            end

            %Consolidate the Strips
            if ( BytesCnt <= PlaneBytesCnt(1) ) && ( ConsolidateCnt > 1 )
                %fprintf(1,'Consolidating %i stripes out of %i', ConsolidateCnt, TIF.StripNumber);
                TIF.StripByteCounts = [BytesCnt; TIF.StripByteCounts(ConsolidateCnt+1:TIF.StripNumber ) ];
                TIF.StripOffsets = TIF.StripOffsets( [1 , ConsolidateCnt+1:TIF.StripNumber] );
                TIF.StripNumber  = 1 + TIF.StripNumber - ConsolidateCnt;
            end
        end
    end

    %read the next IFD address:
    ifd_pos = fread(TIF.file, 1, 'uint32', TIF.BOS);
    %if (ifd_pos) disp(['next ifd at', num2str(ifd_pos)]); end
    
    if (ifd_pos)
        data(imageIndex,i).ifd = ['Next Ifd at = ' num2str(ifd_pos)];
    end

    if isfield( TIF, 'MM_stack' )
        
        if ( img_last > TIF.MM_stackCnt )
            img_last = TIF.MM_stackCnt;
        end

        %this loop is to read metamorph stacks:
        for ii = img_first:img_last

            TIF.StripCnt = 1;

            %read the image
            fileOffset = PlaneBytesCnt * ( ii - 1 );
            data(imageIndex,i).mmImage(ii).planeNo = ['Reading Metamorph image # ' num2str(ii)];
            data(imageIndex,i).mmImage(ii).fieldOffset = ['Field offset = ' num2str(fileOffset)];
            %fileOffset = 0;
            %fileOffset = ftell(TIF.file) - TIF.StripOffsets(1);

            if ( TIF.SamplesPerPixel == 1 )
                IMG.data  = read_plane(fileOffset, IMG.width, IMG.height, 1);
            else
                IMG.red   = read_plane(fileOffset, IMG.width, IMG.height, 1);
                IMG.green = read_plane(fileOffset, IMG.width, IMG.height, 2);
                IMG.blue  = read_plane(fileOffset, IMG.width, IMG.height, 3);
            end

            % print a text timer on the main window, or update the waitbar
            % fprintf(1,'img_read %i img_skip %i\n', img_read, img_skip);
            if exist('waitbar_handle', 'var') && (round(ii/10) == ii/10)
                waitbar( img_read/TIF.MM_stackCnt, waitbar_handle);
            end
            
            [ IMG.info, IMG.MM_stack, IMG.MM_wavelength, IMG.MM_private2 ] = extractMetamorphData(ii);
            
            data(imageIndex,i).mmImage(ii).wavelength = ['Metamorph wavelength = ' num2str(IMG.MM_wavelength(1)), ',', ...
                                    num2str(IMG.MM_wavelength(2))];
            
            img_read = img_read + 1;
            stack( img_read ) = IMG;

        end
        break;

    else

        %this part to read a normal TIFF stack:

        if ( img_skip + 1 >= img_first )

            TIF.StripCnt = 1;
            %read the image
            if ( TIF.SamplesPerPixel == 1 )
                IMG.data  = read_plane(0, IMG.width, IMG.height, 1);
            else
                IMG.red   = read_plane(0, IMG.width, IMG.height, 1);
                IMG.green = read_plane(0, IMG.width, IMG.height, 2);
                IMG.blue  = read_plane(0, IMG.width, IMG.height, 3);
            end

            img_read = img_read + 1;

            try
                % ljd - added Exposure to .tif images data (5-22-08)
                IMG.info = TIF.info;
                stack( img_read ) = IMG;
            catch
                %stack
                %IMG
                error('The file contains dissimilar images: you can only read them one by one');
            end
        else
            img_skip = img_skip + 1;
        end

        if ( img_skip + img_read >= img_last )
            break;
        end
    end
    
    % increment image counter
    imageIndex = imageIndex + 1;
end

%clean-up
fclose(TIF.file);
if exist('waitbar_handle', 'var')
    delete( waitbar_handle );
    clear waitbar_handle;
end
drawnow;
%return empty array if nothing was read
if ~ exist( 'stack', 'var')
    stack = [];
end

return;


%============================================================================

function plane = read_plane(offset, width, height, planeCnt )

global TIF;

%return an empty array if the sample format has zero bits
if ( TIF.BitsPerSample(planeCnt) == 0 )
    plane=[];
    return;
end

%fprintf(1,'reading plane %i size %i %i\n', planeCnt, width, height);

% Preallocate the matrix to hold the data:
%string description of the type of integer needed: int8 or int16...
typecode = sprintf('int%i', TIF.BitsPerSample(planeCnt) );
%unsigned int if SampleFormat == 1
if ( TIF.SampleFormat == 1 )
    typecode = [ 'u', typecode ];
    % Preallocate a matrix to hold the sample data:
    plane = eval( [ typecode, '(zeros(width, height))'] );
elseif ( TIF.SampleFormat == 3 )
    typecode = 'float';
    plane = zeros(width, height);
end

line = 1;

while ( TIF.StripCnt <= TIF.StripNumber )

    strip = read_strip(offset, width, planeCnt, TIF.StripCnt, typecode );
    TIF.StripCnt = TIF.StripCnt + 1;

    % copy the strip onto the data
    plane(:, line:(line+size(strip,2)-1)) = strip;

    line = line + size(strip,2);
    if ( line > height )
        break;
    end

end

% Extract valid part of data if needed
if ~all(size(plane) == [width height]),
    plane = plane(1:width, 1:height);
    error('Cropping data: more bytes read than needed...');
end

% transpose the image
plane = plane';

return;


%=================== sub-functions to read a strip ===================

function strip = read_strip(offset, width, planeCnt, stripCnt, typecode)

global TIF;

%fprintf(1,'reading strip at position %i\n',TIF.StripOffsets(stripCnt) + offset);
StripLength = TIF.StripByteCounts(stripCnt) ./ TIF.BytesPerSample(planeCnt);

%fprintf(1, 'reading strip %i\n', stripCnt);
fseek(TIF.file, TIF.StripOffsets(stripCnt) + offset, 'bof');
bytes = fread( TIF.file, StripLength, typecode, TIF.BOS );

if ( length(bytes) ~= StripLength )
    error('End of file reached unexpectedly.');
end

strip = reshape(bytes, width, StripLength / width);

return;


%===================sub-functions that reads an IFD entry:===================


function [nbbytes, typechar] = matlab_type(tiff_typecode)
switch (tiff_typecode)
    case 1
        nbbytes=1;
        typechar='uint8';
    case 2
        nbbytes=1;
        typechar='uchar';
    case 3
        nbbytes=2;
        typechar='uint16';
    case 4
        nbbytes=4;
        typechar='uint32';
    case 5
        nbbytes=8;
        typechar='uint32';
    otherwise
        error('tiff type not supported')
end
return;

%===================sub-functions that reads an IFD entry:===================

function  entry = readIFDentry()

global TIF;
entry.typecode = fread(TIF.file, 1, 'uint16', TIF.BOS);
entry.cnt      = fread(TIF.file, 1, 'uint32', TIF.BOS);

%disp(['typecode =', num2str(entry.typecode),', cnt = ',num2str(entry.cnt)]);

[ entry.nbbytes, entry.typechar ] = matlab_type(entry.typecode);

if entry.nbbytes * entry.cnt > 4
    %next field contains an offset:
    offset = fread(TIF.file, 1, 'uint32', TIF.BOS);
    %disp(strcat('offset = ', num2str(offset)));
    fseek(TIF.file, offset, -1);
end
if TIF.entry_tag == 33629   %special metamorph 'rationals'
    entry.val = fread(TIF.file, 6*entry.cnt, entry.typechar, TIF.BOS);
elseif TIF.entry_tag == 33628  % MM_private1 - ljd 6-4-08 added code
    %disp(strcat('offset = ', num2str(offset)));
    %disp(['typecode =', num2str(entry.typecode),', cnt = ',num2str(entry.cnt)]);
    entry.val = fread(TIF.file, entry.cnt, entry.typechar, TIF.BOS);
    for i = 1:entry.cnt-1

        switch entry.val(i)
            case 49     % illumsetting, magsetting, magni, magri
                offset = entry.val(i+1);

                if (offset < 300)
                    % nothing
                else
                    fseek(TIF.file, offset, -1);
                    id = fread(TIF.file, 1, 'uint16', TIF.BOS);
                    id = fread(TIF.file, 1, 'uint16', TIF.BOS);
                    id = fread(TIF.file, 1, 'uint16', TIF.BOS);
                    switch id
                        case 24334 % illumSetting
                            %disp('49 = ')
                            name = setstr(fread(TIF.file, 13, 'uint8', TIF.BOS));
                            TIF.MM_illumSetting = setstr(fread(TIF.file, 13, 'uint8', TIF.BOS));
                        case 24332      % MagSetting
                            name = setstr(fread(TIF.file, 23, 'uint8', TIF.BOS));
                        case 24327      % MagRI, MagNA
                            name = setstr(fread(TIF.file, 25, 'uint8', TIF.BOS));
                    end

                    % name = setstr(fread(TIF.file, 1, 'uint32', TIF.BOS));
                    %name
                end
            case 16         % creation time - since midnight in milsec
                %disp('16 = ');
                offset = entry.val(i+1);
                fseek(TIF.file, offset, -1);
                date = fread(TIF.file, 1, 'uint32', TIF.BOS);

                time = fread(TIF.file, 1, 'uint32', TIF.BOS);
                hour = 3600000;
                hours = floor(time/hour);
                time = time - hours*hour;
                minutes = floor(time/60000);
                time = time - minutes*60000;
                sec = floor(time/1000);
                milsec = time - sec*1000;
                TIF.MM_ctime = strcat(num2str(hours), ':', num2str(minutes), ':',...
                    num2str(sec), ':',num2str(milsec));
        end
    end
else
    if entry.typecode == 5
        entry.val = fread(TIF.file, 2*entry.cnt, entry.typechar, TIF.BOS);
    else
        entry.val = fread(TIF.file, entry.cnt, entry.typechar, TIF.BOS);
    end 
end
if ( entry.typecode == 2 )
    entry.val = char(entry.val);
end

return;


%==============distribute the metamorph infos to each frame:
function [info, stack, wavelength, private2 ] = extractMetamorphData(imgCnt)

global TIF;

info = [];
stack = [];
wavelength = [];
private2 = [];

if TIF.MM_stackCnt == 1
    return;
end

left  = imgCnt - 1;

if isfield( TIF, 'info' )
    %         S = length(TIF.info) / TIF.MM_stackCnt;
    infoSize = size(TIF.info);
    if (infoSize(2) == 1)
        info = TIF.info;
    else
        info = TIF.info(imgCnt);
    end
end

if isfield( TIF, 'MM_stack' )
    S = length(TIF.MM_stack) / TIF.MM_stackCnt;
    stack = TIF.MM_stack( [S*left+1:S*left+S] );
end

if isfield( TIF, 'MM_wavelength' )
    S = length(TIF.MM_wavelength) / TIF.MM_stackCnt;
    wavelength = TIF.MM_wavelength( [S*left+1:S*left+S] );
end

if isfield( TIF, 'MM_private2' )
    S = length(TIF.MM_private2) / TIF.MM_stackCnt;
    private2 = TIF.MM_private2( [S*left+1:S*left+S] );
end


return;


%%%%  Parse the Metamorph camera info tag into respective fields
% EVBR 2/7/2005
function mm_infor = parseMM_info(info,p)

i=0;
propCount = 1;
cpropCount = 1;
kk=info;
kk(find(double(kk)==0)) = '';
while(length(kk))
    i=i+1;
    [tmp, kk] = strtok(kk, 13);
    %     [tmp,b] = strtok(tmp, 0);
    token{i} = sscanf(tmp, '%s');
end
tok = {token{1:end-1}};

len = length(tok)/11;
k=1;            % changed default to 1 - for data without exposure
if (length(tok) == 0)
    % more metamorph info data - at least set exposure
    mm_infor(1).Exposure = 1;
end

for i=1:length(tok)
    if ~isempty(token{i})
        [tkk, remk] = strtok(token{i}, 58);

        % if remark is empty - say so LJD - (7-15-08)
        if (isempty(remk))
            remk = ' empty';
        end

        % removed kludge for exposure only - ljd 7-22-08
        %if strcmp(tkk, 'Exposure')
        %    k=k+1;
        %end

        switch tkk
            case 'Exposure'
                % Exposure: 200 ms -> 200
                mm_infor(k).Exposure = str2double(remk(2:strfind(remk, 'ms')-1));
                
                data(p).mmData(i).exposure = ['Metamorph Exposure = ' num2str(mm_infor(k).Exposure)];
            case 'Binning'
                % Binning: 1 x 1 -> [1 1]
                tmp = sscanf(remk, '%c %d %c %d')';
                mm_infor(k).Binning = tmp([2,4]);
                data(p).mmData(i).binning = ['Metamorph Binning = ' mm_infor(k).Binning];
            case 'Region'
                % Region: 1392 x 1040, offset at (0, 0) -> [1392 1040], [0 0]
                [a,b] = strtok(remk, ',');
                tmp = sscanf(a, '%c %d %c %d')';
                mm_infor(k).Region.Size = tmp([2,4]);
                [a,b] = strtok(b, ',');
                mm_infor(k).Region.Offset = [str2double(a(end)), str2double(b(2))];
                data(p).mmData(i).region = ['Metamorph Region = ' a(end), ',' b(2)];
            case 'Subtract'
                % Subtract: Off -> 0
                mm_infor(k).Subtract = ~strcmp(remk(2:end),'Off');
                data(p).mmData(i).subtract = ['Metamorph Subtract = ',  remk(2:end)];
            case 'Shading'
                % Shading: Off -> 0
                mm_infor(k).Shading = ~strcmp(remk(2:end),'Off');
                data(p).mmData(i).shading = ['Metamorph Shading = ',  remk(2:end)];
            case 'Digitizer'
                % Digitizer: 5MHz -> 5
                mm_infor(k).Digitizer = sscanf(remk(2:end), '%d %*s');
                data(p).mmData(i).digitize = ['Metamorph Digitizer = ',  sscanf(remk(2:end), '%d %*s')'];
            case 'Gain'
                % Gain: Gain 1 (1x) -> 1
                mm_infor(k).Gain = sscanf(remk(strfind(remk,'(')+1:end),...
                    '%d %*s %d')';
                data(p).mmData(i).gain = ['Metamorph Gain = ',  sscanf(remk(strfind(remk,'(')+1:end),...
                    '%d %*s %d')'];
            case 'CameraShutter'
                % Camera Shutter: Always Open -> 'AlwaysOpen'
                mm_infor(k).CameraShutter = remk(2:end);
                data(p).mmData(i).cameraShutter = ['Metamorph Camera Shutter = ',  remk(2:end)];
            case 'ClearCount'
                % Clear Count: 2 -> 2
                tmp = sscanf(remk, '%c %d')';
                mm_infor(k).ClearCount = tmp(2);
                data(p).mmData(i).clearCount = ['Metamorph Clear Count = ',  num2str(tmp(2))];
            case 'TriggerMode'
                % Trigger Mode: Normal -> 'Normal'
                mm_infor(k).TriggerMode = remk(2:end);
                data(p).mmData(i).tiggerMode = ['Metamorph Trigger mode = ',  remk(2:end)];
            case 'Temperature'
                % Temperature: 20 -> 20
                tmp = sscanf(remk, '%c %d')';
                mm_infor(k).Temperature = tmp(2);
                data(p).mmData(i).temp = ['Metamorph Camera Shutter = ',  num2str(tmp(2))];
            case 'ClearMode'        % ljd - added ClearMode case (5-30-08)
                % Clear Mode: Normal -> 'Normal'
                mm_infor(k).ClearMode = remk(2:end);
                data(p).mmData(i).clearMode = ['Metamorph Clear Mode = ',  remk(2:end)];
            case 'FramestoAverage'  % ljd - FramestoAverage (5-30-08)
                % FramestoAverage: Normal -> 'Normal'
                mm_infor(k).FramestoAverage = remk(2:end);
                data(p).mmData(i).frames = ['Metamorph Frame to Average = ',  remk(2:end)];
            case 'AcquiredfromPhotometrics'  % ljd - AcquiredfromPhotometrics (5-30-08)
                % AcquiredfromPhotometrics: Normal -> 'Normal'
                mm_infor(k).AcquiredfromPhotometrics = remk(2:end);
                data(p).mmData(i).photo = ['Metamorph Photometrics = ',  remk(2:end)];
            case 'SensorMode'  % ljd - SensorMode (5-30-08)
                % SensorMode: Normal -> 'Normal'
                mm_infor(k).SensorMode = remk(2:end);
                data(p).mmData(i).sensorMode = ['Metamorph Sensor Mode = ',  remk(2:end)];
            case 'MultiplicationGain'  % ljd - MultiplicationGain (5-30-08)
                % MultiplicationGain: Normal -> 'Normal'
                mm_infor(k).MultiplicationGain = remk(2:end);
                data(p).mmData(i).mult = ['Metamorph Multiplication Gain = ',  remk(2:end)];
            case 'Illumination'  % ljd - Illumination (5-30-08)
                % Illumination: Normal -> 'Normal'
                mm_infor(k).Illumination = remk(2:end);
                data(p).mmData(i).illumination = ['Metamorph Illumination = ',  remk(2:end)];
            case '[IntensityMapping]'  % ljd - IntensityMapping (7-23-09)
                % IntensityMapping: Normal -> 'MapCh0'
                p = 1;
                index = i+1;
                [tkk, remk] = strtok(token{index}, 58);
                while (strcmpi(tkk,'[IntensityMappingEnd]') == 0)
                    mm_infor(k).IntensityMapping{p} = tkk;
                    index = index+1;
                    [tkk, remk] = strtok(token{index}, 58);
                    p = p+1;
                end
                data(p).mmData(i).intensity = mm_infor(k).IntensityMapping;
            case '[DisplaySettings]'  % ljd - DisplaySettings (7-23-09)
                % DisplaySettings: Normal -> 'Gamma0=1,DisplayMode=545,DisplayZoom=1'
                 p = 1;
                index = i+1;
                [tkk, remk] = strtok(token{index}, 58);
                while (strcmpi(tkk,'[DisplaySettingsEnd]') == 0)
                    mm_infor(k).displaySettings{p} = tkk;
                    index = index+1;
                    [tkk, remk] = strtok(token{index}, 58);
                    p = p+1;
                end
                data(p).mmData(i).display = mm_infor(k).displaySettings;
            case '[AcquisitionParameters]'  % ljd - AquisitionParameters (7-23-09)
                % MultiplicationGain: Normal -> 'Normal'
                 p = 1;
                index = i+1;
                [tkk, remk] = strtok(token{index}, 58);
                while (strcmpi(tkk,'[AcquisitionParametersEnd]') == 0)
                    mm_infor(k).acquisition{p} = tkk;
                    index = index+1;
                    [tkk, remk] = strtok(token{index}, 58);
                    p = p+1;
                end
                data(p).mmData(i).acquisition = mm_infor(k).acquisition;
            case '[Description]'  % ljd - Description (7-23-09)
                % Description: Normal -> 'Normal'
                 p = 1;
                index = i+1;
                [tkk, remk] = strtok(token{index}, 58);
                while (strcmpi(tkk,'[DescriptionEnd]') == 0)
                    mm_infor(k).description{p} = tkk;
                    index = index+1;
                    [tkk, remk] = strtok(token{index}, 58);
                    p = p+1;
                end
                data(p).mmData(i).description = mm_infor(k).description;
            case '[Physiology]'  % ljd - Physiology (7-23-09)
                % Physiology: Normal -> 'Normal'
                 p = 1;
                index = i+1;
                [tkk, remk] = strtok(token{index}, 58);
                while (strcmpi(tkk,'[PhysiologyEnd]') == 0)
                    mm_infor(k).physiology{p} = tkk;
                    index = index+1;
                    [tkk, remk] = strtok(token{index}, 58);
                    p = p+1;
                end
                data(p).mmData(i).physiology = mm_infor(k).physiology;
            case '[LUTCh0]'  % ljd - LUTCh0 (7-23-09)
                % LUTCh0: Normal -> 'Normal'
                 p = 1;
                index = i+1;
                [tkk, remk] = strtok(token{index}, 58);
                while (strcmpi(tkk,'[LUTCh0End]') == 0)
                    mm_infor(k).LUTCh0{p} = tkk;
                    index = index+1;
                    [tkk, remk] = strtok(token{index}, 58);
                    p = p+1;
                end
                data(p).mmData(i).LUTCh0 = mm_infor(k).LUTCh0;
            case '[VersionInfo]'  % ljd - VersionInfo (7-23-09)
                % VersionInfo: Normal -> 'Normal'
                 p = 1;
                index = i+1;
                [tkk, remk] = strtok(token{index}, 58);
                while (strcmpi(tkk,'[VersionInfoEnd]') == 0)
                    mm_infor(k).versionInfo{p} = tkk;
                    index = index+1;
                    [tkk, remk] = strtok(token{index}, 58);
                    p = p+1;
                end
                data(p).mmData(i).version = mm_infor(k).versionInfo;
            case '<MetaData>'  % ljd - multitif metadata (8-28-09)
                index = i+1;
                [tkk, remk] = strtok(token{index}, 13);
                
                % extract the metaData fields
                tmpInfo = decodeTkk(tkk);
                
                if (isfield(tmpInfo,'Exposure'))
                    mm_infor(k).Exposure = tmpInfo.Exposure;
                    data(p).mmData(i).exposure = ['Metamorph Exposure = ' ...
                        num2str(mm_infor(k).Exposure)];
                end
                if (isfield(tmpInfo,'Binning'))
                   mm_infor(k).Binning = tmpInfo.Binning;
                   data(p).mmData(i).binning = ['Metamorph Binning = ' ...
                       '[' num2str(mm_infor(k).Binning(1)) ' x ' ...
                       num2str(mm_infor(k).Binning(2)) ']'];
                end
                if (isfield(tmpInfo,'Region'))
                   mm_infor(k).Region = tmpInfo.Region;
                   sizeString = [' Size(' num2str(tmpInfo.Region.Size(1)) ',' ...
                       num2str(tmpInfo.Region.Size(2)) ') '];
                   offString = [' Offset at(' num2str(tmpInfo.Region.Offset(1)) ...
                       ',' num2str(tmpInfo.Region.Offset(2)) ') '];
                   data(p).mmData(i).region = ['Metamorph Region = '...
                       sizeString offString];
                end
                if (isfield(tmpInfo,'Subtract'))
                   mm_infor(k).Subtract = tmpInfo.Subtract;
                   if (tmpInfo.Subtract)
                       data(p).mmData(i).subtract = ['Metamorph Subtract = On'];
                   else
                       data(p).mmData(i).subtract = ['Metamorph Subtract = Off'];
                   end
                end
                if (isfield(tmpInfo,'Shading'))
                   mm_infor(k).Shading = tmpInfo.Shading;
                  if (tmpInfo.Shading)
                       data(p).mmData(i).shading = ['Metamorph Shading = On'];
                   else
                       data(p).mmData(i).shading = ['Metamorph Shading = Off'];
                  end
                end
                if (isfield(tmpInfo,'Digitizer'))
                    mm_infor(k).Digitizer = tmpInfo.Digitizer;
                    data(p).mmData(i).digitize = ['Metamorph Digitizer = ' ...
                        mm_infor(k).Digitizer];
                end
                if (isfield(tmpInfo,'Gain'))
                    mm_infor(k).Gain = tmpInfo.Gain;
                    data(p).mmData(i).gain = ['Metamorph Gain = ' ...
                        num2str(tmpInfo.Gain(1)) '('  num2str(tmpInfo.Gain(2)) 'x)'];
                end
                if (isfield(tmpInfo,'CameraShutter'))
                   mm_infor(k).CameraShutter = tmpInfo.CameraShutter;
                   data(p).mmData(i).temp = ['Metamorph Camera Shutter = '  ...
                       mm_infor(k).CameraShutter];
                end
                if (isfield(tmpInfo,'ClearCount'))
                   mm_infor(k).ClearCount = tmpInfo.ClearCount;
                   data(p).mmData(i).clearCount = ['Metamorph Clear Count = '  ...
                       num2str(mm_infor(k).ClearCount)];
                end
                if (isfield(tmpInfo,'ClearMode'))
                    mm_infor(k).ClearMode = tmpInfo.ClearMode;
                    data(p).mmData(i).clearMode = ['Metamorph Clear Mode = '  ...
                        mm_infor(k).ClearMode];
                end
                if (isfield(tmpInfo,'FramestoAverage'))
                    mm_infor(k).FramestoAverage = tmpInfo.FramestoAverage;
                    data(p).mmData(i).frames = ['Metamorph Frame to Average = '  ...
                        num2str(mm_infor(k).FramestoAverage)];
                end
                if (isfield(tmpInfo,'TriggerMode'))
                    mm_infor(k).TriggerMode = tmpInfo.TriggerMode;
                    data(p).mmData(i).tiggerMode = ['Metamorph Trigger mode = ' ...
                        mm_infor(k).TriggerMode];
                end
                if (isfield(tmpInfo,'Temperature'))
                    mm_infor(k).Temperature = tmpInfo.Temperature;
                    data(p).mmData(i).temperature = ['Metamorph Temperature mode = '...
                        num2str(mm_infor(k).Temperature)];
                end
                % &&& to see what's in mm data - uncomment these two lines
                %data(p).mmData(i)
                %mm_infor(k)
            case '<PlaneInfo>'  % ljd - multitif metadata - plane info (8-28-09)  
                index = i+1;
                [tkk, remk] = strtok(token{index}, 13);
                
                equPos = findstr('=',tkk);

                subTkk = tkk(equPos(3)+2:end-2);

                mm_infor(k).planeInfo = subTkk;
                   
                data(p).mmData(i).planeInfo = mm_infor(k).planeInfo;
            case '</prop>'  % ljd - multitif metadata (9-9-09) 
                % ignore 
            case '</custom-prop>'  % ljd - multitif metadata (9-9-09) 
                % ignore 
            case '</PlaneInfo>'  % ljd - multitif metadata (9-9-09) 
                % ignore 
                 
            otherwise
                % check for <prop and <custom_prop
                if (strncmp(tkk,'<prop',5))
                    % found <prop - extract data
                    [id, type, value] = decompose(tkk(6:end-1));
                    mm_infor(k).propid(propCount).id = id;
                    mm_infor(k).propid(propCount).type = type;
                    mm_infor(k).propid(propCount).value = value;
                    data(p).mmData(i).propid(propCount).id = mm_infor(k).propid(propCount).id;
                    data(p).mmData(i).propid(propCount).type = mm_infor(k).propid(propCount).type;
                    data(p).mmData(i).propid(propCount).value = mm_infor(k).propid(propCount).value;
                    propCount = propCount + 1;
                elseif (strncmp(tkk,'<custom-prop',12))
                    % found <custom-prop - extract data
                    [id, type, value] = decompose(tkk(13:end-1));
                    mm_infor(k).cpropid(cpropCount).id = id;
                    mm_infor(k).cpropid(cpropCount).type = type;
                    mm_infor(k).cpropid(cpropCount).value = value;
                    data(p).mmData(i).cpropid(cpropCount).id = mm_infor(k).cpropid(cpropCount).id;
                    data(p).mmData(i).cpropid(cpropCount).type = mm_infor(k).cpropid(cpropCount).type;
                    data(p).mmData(i).cpropid(cpropCount).value = mm_infor(k).cpropid(cpropCount).value;
                    cpropCount = cpropCount + 1;
                else 
                    % unknown html tag  
                    data(p).mmData(i).unknownStrings = tkk;
                end
                
        end
    end
end



function info = decodeTkk(tkk)

% function to decode metatdata string
% go to 'Value" section
equPos = findstr('=',tkk);

% extract everything after 'Value'
subTkk = tkk(equPos(3)+2:end-2);

% find number of entries
ampPos = findstr('&amp;#13;&amp;#10;',subTkk);

dims = size(ampPos);

loc = 1;
for i = 1:dims(2)
    % pull out metadata entries
    mmString = subTkk(loc:ampPos(i)-1);
   % output{i} = mmString;
    mmProp = mmString(1:strfind(mmString,':')-1);
    switch mmProp
        case 'Exposure'
            info.Exposure = str2double(mmString(10:end-2));
        case 'Binning'
            tempk = mmString(9:end);
            tmp = sscanf(tempk, '%d %c %d')';
            info.Binning = tmp([1,3]);
        case 'Region'
            % Region: 1392 x 1040, offset at (0, 0) -> [1392 1040], [0 0]
            [a,b] = strtok(mmString(8:end), ',');
            tmp = sscanf(a, '%d %c %d')';
            info.Region.Size = tmp([1,3]);
            [a,b] = strtok(b, ',');
            info.Region.Offset = [str2double(a(end)), str2double(b(2))];
        case 'Subtract'
            % Subtract: Off -> 0
            info.Subtract = ~strcmp(mmString(10:end),'Off');
        case 'Digitizer'
            % Digitizer: 5MHz -> 5
            info.Digitizer = sscanf(mmString(11:end), '%d %*s');
        case 'Shading'
            % Shading: Off -> 0
            info.Shading = ~strcmp(mmString(9:end),'Off');
        case 'Gain'
            % Gain: Gain 1 (1x) -> 1j
            tempk = mmString(strfind(mmString,'(')-1:end);
            tmp = sscanf(tempk, '%d %c %d')';
            info.Gain = tmp([1,3]);
        case 'CameraShutter'
            % Camera Shutter: Always Open -> 'AlwaysOpen'
            info.CameraShutter = mmString(15:end);
        case 'ClearCount'
            % Clear Count: 2 -> 2
            info.ClearCount = str2num(mmString(12:end));
        case 'ClearMode'
            % Clear Mode: Normal -> 'Normal'
            info.ClearMode = mmString(11:end);
        case 'FramestoAverage'
            % FramestoAverage: Normal -> 'Normal'
            info.FramestoAverage = str2num(mmString(17:end));
        case 'TriggerMode'
            % Trigger Mode: Normal -> 'Normal'
            info.TriggerMode = mmString(13:end);
        case 'Temperature'
            % Temperature: 20 -> 20
            info.Temperature = str2num(mmString(13:end));    
        otherwise
            mmProp;
    end
    loc = ampPos(i)+18;
end


function [id, type, value] = decompose(propString)

% propString has format id="xxx"type="xxxx"value="xxxx"

typePos = 1;
typePos = findstr('type=',propString);

valuePos = 1;
valuePos = findstr('value=',propString);

id = propString(5:typePos-2);

type = propString(typePos+6:valuePos-2);

value = propString(valuePos+7:end-1);


