function varargout = TiffHeader(varargin)
% TIFFHEADER M-file for TiffHeader.fig
%      TIFFHEADER, by itself, creates a new TIFFHEADER or raises the existing
%      singleton*.
%
%      H = TIFFHEADER returns the handle to a new TIFFHEADER or the handle to
%      the existing singleton*.
%
%      TIFFHEADER('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TIFFHEADER.M with the given input arguments.
%
%      TIFFHEADER('Property','Value',...) creates a new TIFFHEADER or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before TiffHeader_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to TiffHeader_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help TiffHeader

% Last Modified by GUIDE v2.5 19-Oct-2009 14:19:25

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @TiffHeader_OpeningFcn, ...
                   'gui_OutputFcn',  @TiffHeader_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before TiffHeader is made visible.
function TiffHeader_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to TiffHeader (see VARARGIN)

% Choose default command line output for TiffHeader
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes TiffHeader wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = TiffHeader_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton1 - Browse
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[filename, path] = uigetfile('*.stk;*.STK;*.tif;*.TIF;','Select images for Viewing');

if (filename == 0)
    % no file selected - Cancel
    return;
end

file = [path filename];

set(handles.edit1,'String',file);



% --- Executes on button press in pushbutton2 - Extract Header
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

file = get(handles.edit1,'String');

info = OutputTiffHeader(file);

dims = size(info);

debugFlag = false;

if debugFlag
    for j = 1:dims(1)
        for i = 1:dims(2)
            if (isfield(info(j,i).mmInfo,'propid'))
                d = size(info(j,i).mmInfo.propid);
                for q = 1:d(2)
                    s1 = info(j,i).mmInfo.propid(q).id
                    s2 = info(j,i).mmInfo.propid(q).type
                    s3 = info(j,i).mmInfo.propid(q).value
                end
            end
            if (isfield(info(j,i).mmInfo,'cpropid'))
                d = size(info(j,i).mmInfo.cpropid);
                for q = 1:d(2)
                    s1 = info(j,i).mmInfo.cpropid(q).id
                    s2 = info(j,i).mmInfo.cpropid(q).type
                    s3 = info(j,i).mmInfo.cpropid(q).value
                end
            end
        end
    end
end

%set(handles.popupmenu1,'String',{'1','2','3','4'});
% for j=1:dims(2)
%     popString{j} = info(j).entryTag;
% end
% set(handles.popupmenu1,'String', popString);

p = 1;
r = 1;

for j = 1:dims(1)
    infoString{p+1} = '  ';
    infoString{p+1} = ['Image Number = ' num2str(j)];
    infoString{p+2} = info(j,1).filename;
    infoString{p+3} = info(j,1).byteOrder;
    infoString{p+4} = info(j,1).position;
    infoString{p+5} = info(j,1).numEntries;
    infoString{p+6} = info(j,1).bytesPerImage;
    if (isfield(info(j,1),'mmImage'))
        infoString{p+7} = info(j,1).mmImage;
    end
    p = p+7;
    for i = 1:dims(2)
        infoString{p+1} = info(j,i).entryTag;
        infoString{p+2} = info(j,i).filePosition;
        infoString{p+3} = info(j,i).string;
        infoString{p+4} = ' ';
        p = p+4;
        if (isfield(info(j,1),'mmInfo'))
            if (isfield(info(j,i).mmInfo,'Exposure'))
                if debugFlag
                    info(j,i).mmInfo.Exposure(1)
                    info(j,i).mmInfo.Binning(1)
                    info(j,i).mmInfo.Binning(2)
                    info(j,i).mmInfo.Region.Size(1)
                    info(j,i).mmInfo.Region.Size(2)
                    info(j,i).mmInfo.Region.Offset(1)
                    info(j,i).mmInfo.Region.Offset(2)
                    info(j,i).mmInfo.Subtract
                    info(j,i).mmInfo.Shading
                    info(j,i).mmInfo.Digitizer
                    info(j,i).mmInfo.Gain
                    info(j,i).mmInfo.CameraShutter
                    info(j,i).mmInfo.ClearCount
                    info(j,i).mmInfo.ClearMode
                    info(j,i).mmInfo.FramestoAverage
                    info(j,i).mmInfo.TriggerMode
                    info(j,i).mmInfo.Temperature
                end
                mmString{r} = ['Image number ' num2str(j)];
                mmString{r+1} = ['Exposure = ' num2str(info(j,i).mmInfo.Exposure(1))];
                mmString{r+2} = ['Binning = ' num2str(info(j,i).mmInfo.Binning(1)) ...
                    ','  num2str(info(j,i).mmInfo.Binning(2))];
                mmString{r+3} = ['Region size = ' num2str(info(j,i).mmInfo.Region.Size(1)) ...
                    'x' num2str(info(j,i).mmInfo.Region.Size(2))];
                mmString{r+4} = ['Region offset = ' num2str(info(j,i).mmInfo.Region.Offset(1)) ...
                    ',' num2str(info(j,i).mmInfo.Region.Offset(2))];
                mmString{r+5} = ['Subtract = ' num2str(info(j,i).mmInfo.Subtract)];
                mmString{r+6} = ['Shading = ' num2str(info(j,i).mmInfo.Shading)];
                mmString{r+7} = ['Digitizer = ' num2str(info(j,i).mmInfo.Digitizer) ' MHz'];
                mmString{r+8} = ['Gain = ' num2str(info(j,i).mmInfo.Gain)];
                mmString{r+9} = ['Camera shutter = ' info(j,i).mmInfo.CameraShutter];
                mmString{r+10} = ['Clear count = ' num2str(info(j,i).mmInfo.ClearCount)];
                mmString{r+11} = ['Clear mode = ' info(j,i).mmInfo.ClearMode];
                mmString{r+12} = ['Frames to average = ' num2str(info(j,i).mmInfo.FramestoAverage)];
                mmString{r+13} = ['Tirgger mode = ' info(j,i).mmInfo.TriggerMode];
                mmString{r+14} = ['Temerature = ' num2str(info(j,i).mmInfo.Temperature)];
                mmString{r+15} = '  ';
                r = r+16;
                set(handles.listbox3, 'String', mmString);
            end
        end
        if (isfield(info(i),'mmImage'))
            if (isfield(info(i).mmImage,'planeNo'))
                for mmI = 1:dims(2)
                    infoString{p+1} = info(j,i).mmImage(mmI).planeNo;
                    infoString{p+2} = info(j,i).mmImage(mmI).fieldOffset;
                    infoString{p+3} = info(j,i).mmImage(mmI).wavelength;
                    p = p + 3;
                end
            end
        end
    end
end

set(handles.listbox1, 'String', infoString);


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1


% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1

p = get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%set(hObject,'String',{'a','b','c','d'});


% --- Executes on selection change in listbox2.
function listbox2_Callback(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox2


% --- Executes during object creation, after setting all properties.
function listbox2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in listbox3.
function listbox3_Callback(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns listbox3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox3


% --- Executes during object creation, after setting all properties.
function listbox3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton4 - Save to File
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

dialogstring = strcat('Select text file for saving information:');
[filename,pathname] = uiputfile('*.txt',dialogstring);

% check for valid name
if (isequal(filename,0) || isequal(pathname,0))
   % no file selected - do nothing
   return;
end

ofile = strcat(pathname, filename);

fid = fopen(ofile,'w+');
if (fid < 1)
    helpdlg('Unable to open file');
else
    % get tif filename
    file = get(handles.edit1,'String');
    
    % get header info
    info = OutputTiffHeader(file);
    
    dims = size(info);
    
    for j = 1:dims(1)
        
        fprintf(fid,'--------------------------------------------------\n');
        fprintf(fid,'Image Number %d\n',j);
        fprintf(fid,'\n');
        
        fprintf(fid,'%s\n',info(j,1).filename);
        fprintf(fid,'%s\n',info(j,1).byteOrder);
        fprintf(fid,'%s\n',info(j,1).position);
        fprintf(fid,'%s\n',info(j,1).numEntries);
        fprintf(fid,'%s\n',info(j,1).bytesPerImage);
        fprintf(fid,'\n');
        
        for i = 1:dims(2)
            fprintf(fid,'%s\n',info(j,i).entryTag);
            fprintf(fid,'%s\n',info(j,i).filePosition);
            fprintf(fid,'%s\n',info(j,i).string);
            fprintf(fid,'%s\n',info(j,1).bytesPerImage);
            fprintf(fid,'\n');
            
            if (isfield(info(j,1),'mmInfo'))
                if (isfield(info(j,i).mmInfo,'Exposure'))
                    fprintf(fid,'METAMORPH DATA\n');
                    fprintf(fid,'Exposure = %d\n',info(j,i).mmInfo.Exposure(1));
                    fprintf(fid,'Binning = %d,%d\n',info(j,i).mmInfo.Binning(1) ...
                        ,info(j,i).mmInfo.Binning(2));
                    fprintf(fid,'Region Size = %dx%d\n',info(j,i).mmInfo.Region.Size(1) ...
                        ,info(j,i).mmInfo.Region.Size(2));
                    fprintf(fid,'Region Offset = %d,%d\n',info(j,i).mmInfo.Region.Offset(1) ...
                        ,info(j,i).mmInfo.Region.Offset(2));
                    fprintf(fid,'Subtract = %d\n',info(j,i).mmInfo.Subtract);
                    fprintf(fid,'Shading = %d\n',info(j,i).mmInfo.Shading);
                    fprintf(fid,'Digitizer = %d MHz\n',info(j,i).mmInfo.Digitizer);
                    fprintf(fid,'Gain = %d\n',info(j,i).mmInfo.Gain);
                    fprintf(fid,'Camera Shutter = %s\n',info(j,i).mmInfo.CameraShutter);
                    fprintf(fid,'Clear Count = %d\n',info(j,i).mmInfo.ClearCount);
                    fprintf(fid,'Clear Mode = %s\n',info(j,i).mmInfo.ClearMode);
                    fprintf(fid,'Frames to Average = %d\n',info(j,i).mmInfo.FramestoAverage);
                    fprintf(fid,'Trigger Mode = %s\n',info(j,i).mmInfo.TriggerMode);
                    fprintf(fid,'Temperature = %d\n',info(j,i).mmInfo.Temperature);
                end
            end
            
            fprintf(fid,'\n');
            
            if (isfield(info(j,i),'mmImage'))
                if (isfield(info(j,i).mmImage,'planeNo'))
                    mmdims = size(info(j,i).mmImage);
                    fprintf(fid,'METAMORPH PLANE DATA\n');
                    for q = 1:mmdims(2)
                        fprintf(fid,'Plane No(%d) = %d\n',i,info(j,i).mmImage(q).planeNo);
                        fprintf(fid,'Field Offset(%d) = %d\n',i,info(j,i).mmImage(q).fieldOffset);
                        fprintf(fid,'Wavelength(%d) = %d\n',i,info(j,i).mmImage(q).wavelength);
                    end
                    fprintf(fid,'\n');
                end
                if (isfield(info(j,i).mmInfo,'propid'))
                    d = size(info(j,i).mmInfo.propid);
                    fprintf(fid,'METAMORPH PROP DATA\n');
                    for q = 1:d(2)
                        fprintf(fid,'MM Prop Id(%d) = %d\n',i,info(j,i).mmInfo.propid(q).id);
                        fprintf(fid,'MM Property Type(%d) = %d\n',i,info(j,i).mmInfo.propid(q).type);
                        fprintf(fid,'MM Property Value(%d) = %d\n',i,info(j,i).mmInfo.propid(q).value);
                    end
                    fprintf(fid,'\n');
                end
                if (isfield(info(j,i).mmInfo,'cpropid'))
                    d = size(info(j,i).mmInfo.cpropid);
                    fprintf(fid,'METAMORPH CPROP DATA\n');
                    for q = 1:d(2)
                        fprintf(fid,'MM Cproperty Id(%d) = %d\n',i,info(j,i).mmInfo.cpropid(q).id);
                        fprintf(fid,'MM Cproperty Type(%d) = %d\n',i,info(j,i).mmInfo.cpropid(q).type);
                        fprintf(fid,'MM Cproperty Value(%d) = %d\n',i,info(j,i).mmInfo.cpropid(q).value);
                    end
                    fprintf(fid,'\n');
                end
            end
        end
    end
    fprintf(fid,'\n');
    
    status = fclose(fid);
end



% --- Executes on button press in pushbutton3 - Exit
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
close(TiffHeader);



