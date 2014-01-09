function varargout=HKloadLif(filename)
% HKloadLif - Load Leica Image File Format
% 
% HKloadLif('filename') shows a table of images in a Leica Image File
% Turn checkbox on to view an image. 
% The exported data in matlab work space is a structure that includes
% following menbers.
% loc1 = 
%               Image: {[1024x1024x101 uint8]}
%                Info: [1x1 struct]
%                Name: 'loc1'
%                Type: 'X-Y-Z'
%     NumberOfChannel: 1
%                Size: '1024  1024   101'

% History
% Version 1.0
% 21-Apr-2010: return limited information concerning with images
% 13-May-2010: previewer added
% 21-Jul-2010: Previewer modified (mainly, XYZ)
% 
% Version 2.0
% 01-Sep-2011
% Output Data sturucture completely changed. 
% Data were intaracticely loaded from HDD with turning on checkbox in table

% (c) Hiroshi Kawaguchi, Ph.D, 
% Molecular Imaging Center 
% National Institute of Radiological Sciences, Japan

%% Main function

if nargin ==0
    [filename pathname]=uigetfile({'*.lif','Leica Image Format (*.lif)'});
    if filename==0; return; end
    filename=[pathname filename];
end

fp=fopen(filename,'r');

%h=MsgBox('Reading XML Part');
[fp, xmlHdrStr] = ReadXMLPart(fp);

% xmlList is cell array (n x 5)
% rank(double) name(string) attributes(cell(n,2)) parant(double) children(double array)
%MsgBox(h,'Changing XML to Cell');
xmlList=XMLtxt2cell(xmlHdrStr); % =============== VERY SLOW! NEED MORE CONSIDERATION ==============
lifVersion = GetLifVersion(xmlList(1,:)); % lifVersion is double scalar

%MsgBox(h,'Reading Image Info');
imgList    = GetImageDescriptionList(xmlList);% imgList is struct vector
% memoryList is cell array (n x 4)
% ID(string), startPoint(uint64), sizeOfMemory, Index(double)
imgList  = ReadObjectMemoryBlocks(fp,lifVersion,imgList);
fclose(fp);

% change memory 2 friendly image
% imgList=ReconstructionImages(imgList,memoryList);

% evaluate option
% if exist('option','var')
%     switch lower(option);
%     end
% end

%MsgBox(h,'Prepareing list of images');
ShowListOfImage(imgList,filename,xmlHdrStr);
%DeleteMsgBox(h);

if (nargout>0)
    varargout{1}=imgList;
end
if (nargout>1)
    varargout{2}=xmlList;
end
    
return;

function ShowListOfImage(imgList,filename,xmlList)
dat=cell(numel(imgList),5);
for n=1:numel(imgList)
    dat{n,1}=imgList(n).Name;           % Name of image
    dat{n,2}=numel(imgList(n).Channels);% number of channel
    %dat{n,3}=EvalDimension(imgList(n).Dimensions);  % dimension of Image(assumming all channel has same dimension)
    %imSize=zeros(numel(imgList(n).Dimensions));
    %for m=1:numel(imgList(n).Dimension)
    %    imSize(m)=str2double(imgList(n).Dimensions(m));
    %end
    %dat{n,4}=int2str(imSize);
    [dimType, dimSize]=GetDimensionInfo(imgList(n).Dimensions);
    dat{n,3}=dimType;
    dat{n,4}=int2str(dimSize');
    dat{n,5}=false;
end

[dirName fileName]=fileparts(filename);
fgh=figure('Position',[0 100 415 600],'Name',[fileName '(' dirName ')'],...
    'UserData',imgList,'Resize','off','NumberTitle','off');

setappdata(fgh,'FILENAME',filename); % 

uitable('Parent',fgh,...
    'Units','pixels','Position',[0 0 415 600],...
    'Data', dat,... 
    'ColumnName',     {'Name', '#Ch','Type', 'Size', 'Open'},...
    'ColumnWidth',    { 100,    40,        100, 100, 40},....
    'ColumnFormat',   {'char', 'numeric', 'char', 'char', 'logical'},...
    'ColumnEditable', [ false   false   false false true],...
    'CellEditCallback', @ViewerToggle,...
    'Userdata',zeros(numel(imgList),1)); % UserData: List of figure handle or 0
uicontrol('Parent',fgh,'Style','Pushbutton','String','Show XML', 'Callback', @ShowXML,'UserData',xmlList);
set(fgh,'HandleVisibility','callback');


function ShowXML(oh,~)
fgh=figure('Resize','off','Name', ['Header:' get(get(oh,'Parent'),'Name')],'Number','off');
fgpos=get(fgh,'Position');
str=['{''' strrep(regexprep(strrep(strrep(get(oh,'Userdata'),char(10),''),char(13),''),'\s\s+',''),'><', '>'',''<') '''}'''];
cellXML=eval(str);
num=length(cellXML);
uicontrol('Parent',fgh,'Style','Listbox','Position',[0 0 fgpos(3:4)],...
    'String',cellXML,'Max',num)


function [dimType, dimSize]=GetDimensionInfo(dimensions)
% dimType: just like X-T, X-Y-Z, X-Y-T, ....

ndims=numel(dimensions);
dimType=cell(2*ndims,1);
dimSize=zeros(ndims,1);

for n=1:ndims
    dimSize(n)=str2double(dimensions(n).NumberOfElements);
    switch dimensions(n).DimID
        case '0';dimType{2*n-1}='Not Valied';
        case '1';dimType{2*n-1}='X';
        case '2';dimType{2*n-1}='Y';
        case '3';dimType{2*n-1}='Z';
        case '4';dimType{2*n-1}='T';
        case '5';dimType{2*n-1}='Lambda';
        case '6';dimType{2*n-1}='Rotation';
        case '7';dimType{2*n-1}='XT';
        case '8';dimType{2*n-1}='TSlice';
        otherwise
    end
    dimType{2*n}='-';
end
dimType=strrep(sprintf('%s',char(dimType)'),' ','');
dimType=dimType(1:end-1);% Delete last '-'
    
function ViewerToggle(oh,ev)
% Indices
% EditData
% NewData
% PreviousData
% Error
fgh=gcbf;
n=ev.Indices(1);
figList  = get(oh, 'Userdata');
if ev.NewData
    h=MsgBox('Reading Image Data...');
    % Collect Data
    tableList= get(oh, 'Data');
    imgInfo  = get(fgh, 'UserData');
    filename = getappdata(fgh, 'FILENAME');
    % Extract Data
    imgData  = ReadAnImageData( imgInfo(n), filename);
    imgStruct= ReconstructImage(imgInfo(n), imgData);
    imgStruct.Name            = tableList{n,1};
    imgStruct.Type            = tableList{n,3};
    imgStruct.NumberOfChannel = tableList{n,2};
    imgStruct.Size            = tableList{n,4};
    % Draw Figure
    MsgBox(h,'Drawing Image')
    fghv=figure('Visible','off', 'UserData', fgh);
    ShowImage(fghv,imgStruct);
    %delete(get(get(h,'Parent'),'Parent'));
    DeleteMsgBox(h);
    set(fghv,'Visible','on')
    % Save Figure handle for delete figure
    figList(n) = fghv;
else
    delete(figList(n));
    figList(n) = 0;
end
set(oh, 'Userdata', figList);

% ==================================================
%% Viewer Functions
% Common UserData List
%     Export button: image struct
%     Figure: figure handle including table
% ================================================== 
function ShowImage(fgh,imgStruct)
set(fgh,'Name',[imgStruct.Name '(' imgStruct.Type ',' imgStruct.Size ')'],'DeleteFcn',@ClearViwer);

%ah = axes('Parent',ph,'Unit','pixels','Position',[60 180 384 384],'Tag','ImgAxis');
%title(ah,[imageName ' (' dimInfo ')']);
%uicontrol('Style','pushbutton','Parent',ph,'Unit','pixels','Position',[384 20 60  20],...
%    'String','Export','Callback',@CallBack_Export);

switch imgStruct.Type
    case {'X-Y','X-T'}
        Viewer2D(fgh,imgStruct);
    case {'X-Y-Z', 'X-Y-T','X-T-XT'}
        Viewer3D(fgh,imgStruct);
    case {'X-Y-Z-T'}
        Viewer4D(fgh,imgStruct);
    otherwise
        errordlg(['Unsupported Image Type: ' imgStruct.Type])
end

function ClearViwer(oh,~)
fghtb = get(oh,'UserData');
tbh   = findobj(fghtb,'Type','uitable');
figList  =get(tbh, 'Userdata');
tableData=get(tbh, 'Data');
ind=(figList==oh);
tableData{ind,5}=false;
figList(ind)=0;
set(tbh, 'Userdata',figList);
set(tbh, 'Data',tableData);

function h=MsgBox(handle,message)
if ishandle(handle)
    set(handle,'String',message);
else
    message=handle;
    h = msgbox(message);
    set(h,'DeleteFcn',@DeleteMsgBox)
    ch=get(h,'Children');
    delete(ch(2));
    set(h,'WindowStyle','modal')
    h=get(ch(1),'Children');
end

function DeleteMsgBox(oh,~)
delete(get(get(oh,'Parent'),'Parent'));

function Viewer3D(fgh,img)
% UserData List
%     Image: uint8 3D image
%     Axis:  Colromap of image
%     Button: handle of slider

nCh=img.NumberOfChannel;
switch nCh
    case 1; fgpos=[0 0  512 512];
    case 2; fgpos=[0 0 1024 512];
end
set(fgh,'Position',fgpos);
centerfig(fgh);

ph = uipanel('Position', [0 0 250 15],'Parent',fgh); 
imh=zeros(nCh,1);
axh=zeros(nCh,1);
for n=1:nCh
    axh(n)=subplot(1,nCh,n);
    cmap=LifColorMap([img.Info.Channels(n).LUTName, img.Info.Channels(n).IsLUTInverted]);
    tmpImg=uint8((2^8-1)/(2^str2double(img.Info.Channels(n).Resolution)-1)*single(squeeze(img.Image{n})));
    imh(n)=imshow(ind2rgb(tmpImg(:,:,1),cmap),'Parent',axh(n));
    set(imh(n),'Userdata',tmpImg);
    axis(axh(n),'off','equal','tight');
    set(axh(n), 'Userdata', cmap);
end

% Sliders on panel
slh=uicontrol('Parent',ph,'Style','slider',    'Position', [ 0 0 220 15],...
    'Max', size(tmpImg,3), 'Min', 1, 'Value', 1,...
    'Sliderstep', [1 10]/(size(tmpImg,3)-1),'Callback',@Callback_UpdateSlider);
uicontrol('Parent',ph, 'Style','pushbutton','Position', [220 0 15 15], 'String','<',     'Callback',@Callback_UpdateButton,'UserData',slh);
uicontrol('Parent',ph, 'Style','pushbutton','Position', [235 0 15 15], 'String','>',     'Callback',@Callback_UpdateButton,'UserData',slh);
uicontrol('Parent',fgh,'Style','pushbutton','Position', [250 0 75 15], 'String','Export','Callback',@CallBack_Export,'UserData',img);

set(ph,'Userdata',imh);

function Viewer4D(fgh,img)
% UserData List
%     Image: uint8 3D image
%     Axis:  Colromap of image
%     Button: handle of slider

imSize=str2num(img.Size); %#ok<ST2NM>
if imSize(4)==1
    Viewer3D(fgh,img);
    return;
end

nCh=img.NumberOfChannel;
switch nCh
    case 1; fgpos=[0 0  512 512];
    case 2; fgpos=[0 0 1024 512];
end
set(fgh,'Position',fgpos);
centerfig(fgh);

ph = uipanel('Position', [0 0 250 15],'Parent',fgh); 
imh=zeros(nCh,1);
axh=zeros(nCh,1);
for n=1:nCh
    axh(n)=subplot(1,nCh,n);
    cmap=LifColorMap([img.Info.Channels(n).LUTName, img.Info.Channels(n).IsLUTInverted]);
    tmpImg=uint8((2^8-1)/(2^str2double(img.Info.Channels(n).Resolution)-1)*single(squeeze(img.Image{n})));
    imh(n)=imshow(ind2rgb(tmpImg(:,:,1,1),cmap),'Parent',axh(n));
    set(imh(n),'Userdata',tmpImg);
    axis(axh(n),'off','equal','tight');
    set(axh(n), 'Userdata', cmap);
end

% Sliders on panel
slhz=uicontrol('Parent',ph,'Style','slider',    'Position', [ 0 0 220 15],...
    'Max', size(tmpImg,3), 'Min', 1, 'Value', 1,...
    'Sliderstep', [1 10]/(size(tmpImg,3)-1),'Callback',@Callback_UpdateSlider4D,'TooltipString','Z');
slht=uicontrol('Parent',ph,'Style','slider',    'Position', [ 0 15 220 15],...
    'Max', size(tmpImg,4), 'Min', 1, 'Value', 1,...
    'Sliderstep', [1 10]/(size(tmpImg,4)-1),'Callback',@Callback_UpdateSlider4D,'TooltipString','T');

uicontrol('Parent',ph, 'Style','pushbutton','Position', [220 0 15 15], 'String','<',...
    'Callback',@Callback_UpdateButton4D,'UserData',[slhz, slht],'TooltipString','Z');
uicontrol('Parent',ph, 'Style','pushbutton','Position', [235 0 15 15], 'String','>',...
    'Callback',@Callback_UpdateButton4D,'UserData',[slhz, slht],'TooltipString','Z');

uicontrol('Parent',ph, 'Style','pushbutton','Position', [220 15 15 15], 'String','<',...
    'Callback',@Callback_UpdateButton4D,'UserData',[slhz, slht],'TooltipString','T');
uicontrol('Parent',ph, 'Style','pushbutton','Position', [235 15 15 15], 'String','>',...
    'Callback',@Callback_UpdateButton4D,'UserData',[slhz, slht],'TooltipString','T');
% 
set(slhz, 'UserData', slht);
set(slht, 'UserData', slhz);

uicontrol('Parent',fgh,'Style','pushbutton','Position', [250 0 75 15], 'String','Export','Callback',@CallBack_Export,'UserData',img);

set(ph,'Userdata',imh);


function Viewer2D(fgh,img)
nCh=img.NumberOfChannel;
switch nCh
    case 1; fgpos=[0 0  512 512];
    case 2; fgpos=[0 0 1024 512];
end
set(fgh,'Position',fgpos);
centerfig(fgh);

imh=zeros(nCh,1);
axh=zeros(nCh,1);
for n=1:nCh
    axh(n)=subplot(1,nCh,n);
    cmap=LifColorMap([img.Info.Channels(n).LUTName, img.Info.Channels(n).IsLUTInverted]);
    tmpImg=uint8((2^8-1)/(2^str2double(img.Info.Channels(n).Resolution)-1)*single(squeeze(img.Image{n})));
    imh(n)=imshow(ind2rgb(tmpImg(:,:,1),cmap),'Parent',axh(n));
    set(imh(n),'Userdata',tmpImg);
    axis(axh(n),'off','equal','tight');
    set(axh(n), 'Userdata', cmap);
end


% ==================================================
%% CALL BACK FUNCTIONS for SIMPLE VIEWER
% ================================================== 

function Callback_UpdateSlider(oh,~)
imh=get(get(oh,'Parent'),'Userdata');
for n=1:length(imh)
    img=get(imh(n),'Userdata');
    set(imh(n),'Cdata',ind2rgb(img(:,:,round(get(oh,'Value'))), get(get(imh(n),'Parent'),'Userdata')))
end

function Callback_UpdateSlider4D(oh,~)
imh=get(get(oh,'Parent'),'Userdata');
switch get(oh,'TooltipString')
    case 'Z'; 
        newZ=round(get(oh,'Value'));
        newT=round(get(get(oh,'UserData'),'Value'));
    case 'T'; 
        newT=round(get(oh,'Value'));
        newZ=round(get(get(oh,'UserData'),'Value'));
end
for n=1:length(imh)
    img=get(imh(n),'Userdata');
    set(imh(n),'Cdata',ind2rgb(squeeze(img(:,:,newZ,newT)), get(get(imh(n),'Parent'),'Userdata')))
end


function Callback_UpdateButton(oh,~)
imh=get(get(oh,'Parent'),'Userdata');
slh=get(oh, 'UserData');
val=round(get(slh,'Value'));
switch get(oh,'String')
    case '>'; val=val+1;
    case '<'; val=val-1;
end
if val>get(slh,'Max') || val<get(slh,'Min')
    return
end
set(slh,'Value',val);
for n=1:length(imh)
    img=get(imh(n),'Userdata');
    set(imh(n),'Cdata',ind2rgb(img(:,:,val,1), get(get(imh(n),'Parent'),'Userdata')))
end

function Callback_UpdateButton4D(oh,~)
imh=get(get(oh,'Parent'),'Userdata');
slhs=get(oh, 'UserData');

switch get(oh,'TooltipString')
    case 'T'; slh=slhs(2);otherSlh=slhs(1);
    case 'Z'; slh=slhs(1);otherSlh=slhs(2);
end

val=round(get(slh,'Value'));
switch get(oh,'String')
    case '>'; val=val+1;
    case '<'; val=val-1;
end
if val>get(slh,'Max') || val<get(slh,'Min')
    return
end
set(slh,'Value',val);
keepval=round(get(otherSlh,'Value'));
for n=1:length(imh)
    img=get(imh(n),'Userdata');
    switch get(oh,'TooltipString')
        case 'Z'; set(imh(n),'Cdata',ind2rgb(squeeze(img(:,:,val,keepval)), get(get(imh(n),'Parent'),'Userdata')))
        case 'T'; set(imh(n),'Cdata',ind2rgb(squeeze(img(:,:,keepval,val)), get(get(imh(n),'Parent'),'Userdata')))
    end
end


function CallBack_Export(oh,~)
imgStr=get(oh,'UserData');
answer=inputdlg({'Varuable Name'},'',1,...
    {genvarname(imgStr.Info.Name,evalin('base','who'))});
if isempty(answer)
    return;
else
    assignin('base',genvarname(char(answer),evalin('base','who')),imgStr);
end

% ==================================================
% ================================================== 

% function [lenstr unitpre]= LengthStrSeparate(lenstr)
% lenstr=sprintf('%1.2e',str2double(lenstr));

% ==================================================
% ================================================== 

function cmap=LifColorMap(str)

switch lower(str(1:end-1))
    case 'red';  cmap=[linspace(0,1,256)', zeros(256,1), zeros(256,1)];
    case 'green';cmap=[zeros(256,1), linspace(0,1,256)', zeros(256,1)];
    otherwise;   cmap=gray(256);
end

if str2double(str(end))
    cmap=flipud(cmap);
end

% ==================================================
% ================================================== 

function imgList=ReconstructImage(imgInfo, imgData)
% =================================================================== 
% imgInfo description
% =================================================================== 
% <ChannelDescription>
%%% DataType   [0, 1]               [Integer, Float]
%%% ChannelTag [0, 1, 2, 3]         [GrayValue, Red, Green, Blue]
% Resolution [Unsigned integer]   Bits per pixel if DataType is Float value can be 32 or 64 (float or double)
% NameOfMeasuredQuantity [String] Name
% Min        [Double] Physical Value of the lowest gray value (0). If DataType is Float the Minimal possible value (or 0).
% Max        [Double] Physical Value of the highest gray value (e.g. 255) If DataType is Float the Maximal possible value (or 0).
% Unit       [String] Physical Unit
% LUTName    [String] Name of the Look Up Table (Gray value to RGB value)
% IsLUTInverted [0, 1] Normal LUT Inverted Order
%%% BytesInc   [Unsigned long (64 Bit)] Distance from the first channel in Bytes
% BitInc     [Unsigned Integer]       Bit Distance for some RGB Formats (not used in LAS AF 1..0 ? 1.7)
% <DimensionDescription>
% DimID   [0, 1, 2, 3, 4, 5, 6, 7, 8] [Not valid, X, Y, Z, T, Lambda, Rotation, XT Slices, T Slices]
%%% NumberOfElements [Unsigned Integer] Number of elements in this dimension
% Origin           [Unsigned integer] Physical position of the first element (Left pixel side)
% Length   [String] Physical Length from the first left pixel side to the last left pixel side (Not the right. A Pixel has no width!)
% Unit     [String] Physical Unit
%%% BytesInc [Unsigned long (64 Bit)] Distance from one Element to the next in this dimension
% BitInc   [Unsigned Integer] Bit Distance for some RGB Formats (not used, i.e.: = 0 in LAS AF 1..0 ? 1.7)
% =================================================================== 
% imgList info
% =================================================================== 
% img

% Get Dimension info
dimension=ones(1,9);
for m=1:numel(imgInfo.Dimensions)
    dimension(str2double(imgInfo.Dimensions(m).DimID))=str2double(imgInfo.Dimensions(m).NumberOfElements);
end

% Separate to each channel image
nCh=numel(imgInfo.Channels);
imgList=struct('Image',[],'Info',[]);
imgList.Image = cell(nCh,1);
if nCh > 1;
    % mem=mem(1:prod(dimension)*nCh);
    % Above is unnecessary but dimension does not match with memory size in some file
    imgData=reshape(imgData,...
        str2double(imgInfo.Channels(2).BytesInc)-str2double(imgInfo.Channels(1).BytesInc),[]);
    for m=1:nCh
        tmp=imgData(:,m:nCh:end);
        imgList.Image{m}= reshape(typecast(tmp(:),GetType(imgInfo.Channels(m))),dimension);
    end
else
    imgList.Image{1}=reshape(typecast(imgData,GetType(imgInfo.Channels)),dimension);
end
imgList.Info = imgInfo;
    

function chType=GetType(Channels)
switch str2double(Channels.DataType)
    case 0 % int case 
        switch str2double(Channels.Resolution);
            % currently, resolution is constant through the channels
            case 8;   chType='uint8';
            case 12;  chType='uint16';
            case 32;  chType='uint32';
            case 64;  chType='uint64';
            otherwise;error('Unsupporeted data bit. ')
        end
    case 1 % float case
        switch str2double(Channels.Resolution);
            % currently, resolution is constant through the channels
            case 32;  chType='single';
            case 64;  chType='double';
            otherwise;error('Unsupporeted data bit. ')
        end
end
% ================================================== 
% ================================================== 
function mems = GetImageDescriptionList(xmlList)
%  For the image data type the description of the memory layout is defined
%  in the image description XML node (<ImageDescription>).

% <ImageDescription>
imgIndex  =SearchTag(xmlList,'ImageDescription');
numImgs=numel(imgIndex);

% <Memory Size="21495808" MemoryBlockID="MemBlock_233"/>
memIndex  =SearchTag(xmlList,'Memory');
memSizes  =cellfun(@str2double,GetAttributeVal(xmlList,memIndex,'Size'));
memIndex=memIndex(memSizes~=0);
memSizes=memSizes(memSizes~=0);
if numImgs~=numel(memIndex);
    error('Number of ImageDescription and Memory did not match.')
end

% Matching ImageDescription with Memory
imgParentElmIndex =  zeros(numImgs,1);
for n=1:numImgs
    imgParentElmIndex(n) = SearchTagParent(xmlList,imgIndex(n),'Element');
end
memParentElmIndex =  zeros(numImgs,1);
for n=1:numImgs
    memParentElmIndex(n) = SearchTagParent(xmlList,memIndex(n),'Element');
end
[imgParentElmIndex, sortIndex]=sort(imgParentElmIndex); imgIndex=imgIndex(sortIndex); 
[memParentElmIndex, sortIndex]=sort(memParentElmIndex); memIndex=memIndex(sortIndex);memSizes=memSizes(sortIndex);
if ~all(imgParentElmIndex==memParentElmIndex)
    error('Matching ImageDescriptions with Memorys')
end

mems=struct('Name',[],'Channels',[],'Dimensions',[],'Memory',[]);
mems(numImgs).Memory.StartPosition=[];
for n=1:numImgs
    mems(n).Name = char(GetAttributeVal(xmlList, imgParentElmIndex(n),'Name'));
    [mems(n).Channels mems(n).Dimensions]= MakeImageStruct(xmlList,imgIndex(n)); 
    mems(n).Memory.Size=memSizes(n);
    mems(n).Memory.MemoryBlockID=char(GetAttributeVal(xmlList,memIndex(n),'MemoryBlockID'));
end


return

% ================================================== 
% ================================================== 
function [C D]=MakeImageStruct(xmlList,iid)
% ChannelDescription   DataType="0" ChannelTag="0" Resolution="8" 
%                      NameOfMeasuredQuantity="" Min="0.000000e+000" Max="2.550000e+002"
%                      Unit="" LUTName="Red" IsLUTInverted="0" BytesInc="0"
%                      BitInc="0"
% DimensionDescription DimID="1" NumberOfElements="512" Origin="4.336809e-020" 
%                      Length="4.558820e-004" Unit="m" BitInc="0"
%                      BytesInc="1"
% Memory 　　　　　　　  Size="21495808" MemoryBlockID="MemBlock_233"
iidChildren=xmlList{iid,5};
for n=1:numel(iidChildren)
    if strcmp(xmlList{iidChildren(n),2},'Channels')
        id=xmlList{iidChildren(n),5};
        p=xmlList(id,3);
        nid=numel(id);
        tmp=cell(11,nid);
        for m=1:nid
            tmp(:,m)=p{m}(:,2);
        end
        C=cell2struct(tmp,p{1}(:,1),1);
    elseif strcmp(xmlList{iidChildren(n),2},'Dimensions')
        id=xmlList{iidChildren(n),5};
        p=xmlList(id,3);
        nid=numel(id);
        tmp=cell(7,nid);
        for m=1:nid
            tmp(:,m)=p{m}(:,2);
        end
        D=cell2struct(tmp,p{1}(:,1),1);
    else
        error('Undefined Tag')
    end
end

% ================================================== 
% ================================================== 
function lifVersion = GetLifVersion(xmlList)
% return version of header
index  =SearchTag(xmlList,'LMSDataContainerHeader');
value  =GetAttributeVal(xmlList,index,'Version');
lifVersion = str2double(cell2mat(value(1)));
return

% ==================================================
% ================================================== 
function pindex=SearchTagParent(xmlList,index,tagName)
% return the row index of given tag name
pindex=xmlList{index,4};

while pindex~=0
    if strcmp(xmlList{pindex,2},tagName)
        return;
    else
        pindex=xmlList{pindex,4};
    end
end
error('Cannot Find the Parent Tag "%s"',tagName);
return;

% ================================================== 
% ================================================== 
function index=SearchTag(xmlList,tagName)
% return the row index of given tag name
listLen=size(xmlList,1);
index=[];
for n=1:listLen
    if strcmp(char(xmlList(n,2)),tagName)
        index=[index; n]; %#ok<AGROW>
    end
end

% ================================================== 
% ================================================== 
function value=GetAttributeVal(xmlList, index, attributeName)
% return cell array of attributes row index of given tag name
value={};
for n=1:length(index)
    currentCell=xmlList{index(n),3};
    for m=1:size(currentCell,1)
        if strcmp(char(currentCell(m,1)),attributeName)
            value=[value; currentCell(m,2)]; %#ok<AGROW>
        end
    end
end

% ================================================== 
% ================================================== 
function CheckTestValue(value,errorMsg)
switch class(value)
    case 'uint8';  trueVal=hex2dec('2A');
    case 'uint32'; trueVal=hex2dec('70');
    otherwise; 
        error('Unsupported Error Number: %d',value)
end
if value~=trueVal
    error(errorMsg); 
end
return;

% ================================================== 
% ================================================== 
function [fp, str, ketPos] = ReadXMLPart(fp)                    
                                               % Size(bytes) Total(bytes) description
CheckTestValue(fread(fp,1,'*uint32'),...        % 4  4 Test Value 0x70   
    'Invalid test value at Part: XML.');
xmlChunk = fread(fp, 1, 'uint32');              % 4  8 Binary Chunk length NC*2 + 1 + 4
CheckTestValue(fread(fp,1,'*uint8'),...         % 1  9 Test Value 0x2A
    'Invalid test value at XML Content.');
nc = fread(fp,1,'uint32');                      % 4 13 Number of UTF-16 Characters (NC)
if (nc*2 + 1 + 4)~=xmlChunk;  % 
    error('Chunk size mismatch at Part: XML.');
end
str= fread(fp,nc*2,'char');                     % 2*nc - XML Object Description

% UTF-16 -> UTF-8 (cut zeros)
str     = char(str(1:2:end)');
% Insert linefeed(char(10)) for facilitate visualization -----
% str=strrep(str,'><',['>' char(10) '<']);
ketPos =strfind(str,'>'); % find position of ">" for fast search of element
return;

% ================================================== 
% ================================================== 
function imgLists=ReadObjectMemoryBlocks(fp,lifVersion,imgLists)
% get end of file and return current point
cofp=    ftell(fp);
fseek(fp,0,'eof');
eofp=    ftell(fp);
fseek(fp,cofp,'bof');

nImgLists=length(imgLists);
memoryList=cell(nImgLists,4);
% ID(string), startPoint(uint64), sizeOfMemory, Index(double)
for n = 1:nImgLists
    memoryList{n,1}=imgLists(n).Memory.MemoryBlockID;
end

% read object memory blocks
while ftell(fp) < eofp;
    
    CheckTestValue(fread(fp,1,'*uint32'),...        % Test Value 0x70
        'Invalied test value at Object Memory Block');
    
    objMemBlkChunk = fread(fp, 1, '*uint32');%#ok<NASGU> % Size of Description
    
    CheckTestValue(fread(fp,1,'*uint8'),...         % Test Value 0x2A
        'Invalied test value at Object Memory Block');
    
    
    switch uint8(lifVersion)            % Size of Memory (version dependent)
        case 1; sizeOfMemory = double(fread(fp, 1, '*uint32'));
        case 2; sizeOfMemory = double(fread(fp, 1, '*uint64'));
        otherwise; error('Unsupported LIF version. Update this program');
    end
    
    CheckTestValue(fread(fp,1,'*uint8'),...         % Test Value 0x2A
        'Invalied test value at Object Memory Block');
    
    nc = fread(fp,1,'*uint32');                     % Number of MemoryID string
    
    str = fread(fp,nc*2,'*char')';                  % Number of MemoryID string (UTF-16)
    str = char(str(1:2:end));                       % convert UTF-16 to UTF-8
    
    if sizeOfMemory > 0
        for n=1:nImgLists
            if strcmp(char(memoryList{n,1}),str) % NEED CONSIDERATION !!!!!!
                if imgLists(n).Memory.Size ~= sizeOfMemory;
                    error('Memory Size Mismatch.');
                end
                imgLists(n).Memory.StartPosition=ftell(fp);
                fseek(fp,sizeOfMemory,'cof');
                break;
            end
        end
    end   
end


return;

function imgData=ReadAnImageData(imgInfo,fileName)
fp = fopen(fileName,'rb');
if fp<0; errordlg('Cannot open file: \n\t%s', fileName); end
fseek(fp,imgInfo.Memory.StartPosition,'bof');
imgData = fread(fp,imgInfo.Memory.Size,'*uint8'); 
fclose(fp);

% ================================================== 
% ================================================== 
function tagList=XMLtxt2cell(c)
% rank(double) name(string) attributes(cell(n,2)) parant(double) children(double array)

tags  =regexp(c,'<("[^"]*"|''[^'']*''|[^''>])*>','match')';
nTags=numel(tags);
tagList=cell(nTags,5);
tagRank=0;
tagCount=0;
for n=1:nTags
    currentTag=tags{n}(2:end-1);
    if currentTag(1)=='/'
        tagRank=tagRank-1;
        continue;
    end
    tagRank=tagRank+1;
    tagCount=tagCount+1;
    [tagName, attributes]=ParseTagString(currentTag);
    tagList{tagCount,1}=tagRank;
    tagList{tagCount,2}=tagName;
    tagList{tagCount,3}=attributes;
    % search parant
    if tagRank~=1
        if tagRank~=tagList{tagCount-1,1};
            tagRankList=cell2mat(tagList(1:tagCount,1));
            parent=find(tagRankList==tagRank-1,1,'last');
            tagList{tagCount,4}=parent;
        else
            tagList{tagCount,4}=tagList{tagCount-1,4};
        end
    else
        tagList{tagCount,4} = 0;
    end
    if currentTag(end)=='/'
        tagRank=tagRank-1;
    end
end

tagList   =tagList(1:tagCount,:);
parentList=cell2mat(tagList(:,4));
% Make Children List
for n=1:tagCount
    tagList{n,5}=find(parentList==n);
end

return;

% ================================================== 
% ================================================== 
function [name, attributes]=ParseTagString(tag)
[name tmpAttributes]=regexp(tag,'^\w+','match', 'split');
name=char(name);
attributesCell=regexp(char(tmpAttributes(end)),'\w+=".*?"','match');
if isempty(attributesCell)
    attributes={};
else
    nAttributes = numel(attributesCell);
    attributes=cell(nAttributes,2);
    for n=1:nAttributes
        currAttrib=char(attributesCell(n));
        dqpos=strfind(currAttrib,'"');
        attributes{n,1}=currAttrib(1:dqpos(1)-2);
        if dqpos(2)-dqpos(1)==1 % case attribute=""
            attributes{n,2}='';
        else
            attributes{n,2}=currAttrib(dqpos(1)+1:dqpos(2)-1);
        end
    end
end



