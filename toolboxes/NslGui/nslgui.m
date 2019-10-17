function varargout = nslgui(varargin)
% NSLGUI Application M-file for nslgui.fig
%    FIG = NSLGUI launch nslgui GUI.
%    NSLGUI('callback_name', ...) invoke the named callback.

% Nima Mesgarani, 2004, NSL, mnima@glue.umd.edu
% Last Modified by GUIDE v2.5 04-May-2004 11:47:49


%To Do list:

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');
    movegui(fig,'north');    
	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
    global nsl;
    set(handles.radiobutton1,'Value',1);
    set(handles.radiobutton2,'Value',0);
    set(handles.radiobutton3,'Value',1);
    set(handles.radiobutton4,'Value',0);
    set(handles.radiobutton5,'Value',0);
    set(handles.radiobutton6,'Value',0);
    set(handles.radiobutton7,'Value',0);
    set(handles.radiobutton8,'Value',1);
    set(handles.radiobutton9,'Value',0);
    set(handles.radiobutton10,'Value',1);
    set(handles.radiobutton11,'Value',0);
    set(handles.radiobutton12,'Value',0);
    set(handles.radiobutton13,'Value',0);
    path(path,cd);
    
	if nargout > 0
		varargout{1} = fig;
	end

elseif ischar(varargin{1}) % INVOKE NAMED SUBFUNCTION OR CALLBACK

	try
		if (nargout)
			[varargout{1:nargout}] = feval(varargin{:}); % FEVAL switchyard
		else
			feval(varargin{:}); % FEVAL switchyard
		end
	catch
		disp(lasterr);
	end

end


%| ABOUT CALLBACKS:
%| GUIDE automatically appends subfunction prototypes to this file, and 
%| sets objects' callback properties to call them through the FEVAL 
%| switchyard above. This comment describes that mechanism.
%|
%| Each callback subfunction declaration has the following form:
%| <SUBFUNCTION_NAME>(H, EVENTDATA, HANDLES, VARARGIN)
%|
%| The subfunction name is composed using the object's Tag and the 
%| callback type separated by '_', e.g. 'slider2_Callback',
%| 'figure1_CloseRequestFcn', 'axis1_ButtondownFcn'.
%|
%| H is the callback object's handle (obtained using GCBO).
%|
%| EVENTDATA is empty, but reserved for future use.
%|
%| HANDLES is a structure containing handles of components in GUI using
%| tags as fieldnames, e.g. handles.figure1, handles.slider2. This
%| structure is created at GUI startup using GUIHANDLES and stored in
%| the figure's application data using GUIDATA. A copy of the structure
%| is passed to each callback.  You can store additional information in
%| this structure at GUI startup, and you can change the structure
%| during callbacks.  Call guidata(h, handles) after changing your
%| copy to replace the stored original so that subsequent callbacks see
%| the updates. Type "help guihandles" and "help guidata" for more
%| information.
%|
%| VARARGIN contains any extra arguments you have passed to the
%| callback. Specify the extra arguments by editing the callback
%| property in the inspector. By default, GUIDE sets the property to:
%| <MFILENAME>('<SUBFUNCTION_NAME>', gcbo, [], guidata(gcbo))
%| Add any extra arguments after the last argument, before the final
%| closing parenthesis.



% --------------------------------------------------------------------
function varargout = pushbutton1_Callback(h, eventdata, handles, varargin)
% Wav 2 Aud Button
global nsl;
load nslguisettings;
figure;loadload;close;
set(h,'String','Busy');
set(h,'ForegroundColor',[1 0 0]);
drawnow;
wavtemp=nsl.wav;
if stg.tw~=0
    wavtemp(floor(stg.tw*stg.fs):end)=[];
end
if stg.nf~=-2
    wavtemp=unitseq(wavtemp);
end
nsl.aud=wav2aud(wavtemp', [stg.fl stg.tc stg.nf log2(stg.fs/16000)]);
set(h,'String','Wav 2 Aud');
set(h,'ForegroundColor',[0 0 0]);
if get(handles.radiobutton1,'Value')
    figure;
    aud_plot(nsl.aud,[stg.fl stg.tc stg.nf log2(stg.fs/16000)]);
end
if get(handles.radiobutton2,'Value')
    figure;
    imagesc(nsl.aud');axis xy;
end

% --------------------------------------------------------------------
function varargout = pushbutton2_Callback(h, eventdata, handles, varargin)
%Playback original sound
global nsl;
load nslguisettings;
if stg.tw==0
    soundsc(nsl.wav,stg.fs);
else
    soundsc(nsl.wav(1:min(length(nsl.wav),floor(stg.tw*stg.fs))),stg.fs);
end

% --------------------------------------------------------------------
function varargout = radiobutton1_Callback(h, eventdata, handles, varargin)
% Wav to Aud, Frequency-Time representation
global nsl;
if get(h,'Value');
    set(handles.radiobutton2,'Value',0);
    figure;
    load nslguisettings;
    aud_plot(nsl.aud,[stg.fl stg.tc stg.nf log2(stg.fs/16000)]);
end

% --------------------------------------------------------------------
function varargout = radiobutton2_Callback(h, eventdata, handles, varargin)
% Wav 2 Aud Channel-Frame representation
global nsl;
if get(h,'Value')
    set(handles.radiobutton1,'Value',0);
    figure;
    imagesc(nsl.aud');axis xy;
end


% --------------------------------------------------------------------
function varargout = pushbutton3_Callback(h, eventdata, handles, varargin)
% Aud2Cor push button
global nsl;
load nslguisettings;
set(h,'String','Busy');
set(h,'ForegroundColor',[1 0 0]);
drawnow;
nsl.cor=aud2cor(nsl.aud, [stg.fl stg.tc stg.nf log2(stg.fs/160000) stg.ft stg.ff stg.bp],stg.rv,stg.sv,'tmp');
set(h,'String','Aud 2 Cor');
set(h,'ForegroundColor',[0 0 0]);
if get(handles.radiobutton3,'Value')
    radiobutton3_Callback(h, eventdata, handles, varargin);
elseif get(handles.radiobutton4,'Value')
    radiobutton4_Callback(h, eventdata, handles, varargin);
elseif get(handles.radiobutton5,'Value')
    radiobutton5_Callback(h, eventdata, handles, varargin);
elseif get(handles.radiobutton6,'Value')
    radiobutton6_Callback(h, eventdata, handles, varargin);
elseif get(handles.radiobutton7,'Value')
    radiobutton7_Callback(h, eventdata, handles, varargin);
elseif get(handles.radiobutton12,'Value')
    radiobutton12_Callback(h, eventdata, handles, varargin);
elseif get(handles.radiobutton13,'Value')
    radiobutton13_Callback(h, eventdata, handles, varargin);
end
% --------------------------------------------------------------------
function varargout = radiobutton3_Callback(h, eventdata, handles, varargin)
% Aud to Cor, Rate-Frequency View
global nsl;
if get(h,'Value')
    set(handles.radiobutton4,'Value',0);
    set(handles.radiobutton5,'Value',0);
    set(handles.radiobutton6,'Value',0);
    set(handles.radiobutton7,'Value',0);
    set(handles.radiobutton12,'Value',0);
    set(handles.radiobutton13,'Value',0);
    load nslguisettings;
    figure;
    rst_view(squeeze(mean(abs(nsl.cor),3)),stg.rv,stg.sv,1);
end

% --------------------------------------------------------------------
function varargout = radiobutton4_Callback(h, eventdata, handles, varargin)
% Aud 2 Cor, Scale-Frequency View
global nsl;
if get(h,'Value')
    set(handles.radiobutton3,'Value',0);
    set(handles.radiobutton5,'Value',0);
    set(handles.radiobutton6,'Value',0);
    set(handles.radiobutton7,'Value',0);
    set(handles.radiobutton12,'Value',0);
    set(handles.radiobutton13,'Value',0);
    load nslguisettings;
    figure;
    rst_view(squeeze(mean(abs(nsl.cor),3)),stg.rv,stg.sv,2);
end

% --------------------------------------------------------------------
function varargout = radiobutton5_Callback(h, eventdata, handles, varargin)
% Aud to Cor, Rate-Scale View
global nsl;
if get(h,'Value')
    set(handles.radiobutton4,'Value',0);
    set(handles.radiobutton3,'Value',0);
    set(handles.radiobutton6,'Value',0);
    set(handles.radiobutton7,'Value',0);
    set(handles.radiobutton12,'Value',0);
    set(handles.radiobutton13,'Value',0);
    load nslguisettings;
    figure;
    rst_view(squeeze(mean(abs(nsl.cor),3)),stg.rv,stg.sv,3);
end

% --------------------------------------------------------------------
function varargout = radiobutton6_Callback(h, eventdata, handles, varargin)
% Aud to Cor, Rate-Scale-Time View
global nsl;
if get(h,'Value')
    set(handles.radiobutton4,'Value',0);
    set(handles.radiobutton5,'Value',0);
    set(handles.radiobutton3,'Value',0);
    set(handles.radiobutton7,'Value',0);
    set(handles.radiobutton12,'Value',0);
    set(handles.radiobutton13,'Value',0);
    load nslguisettings;
    f=figure;
    set(f,'DoubleBuffer','on');
    rst_view(squeeze(mean(abs(nsl.cor),4)),stg.rv,stg.sv,0);
end

% --------------------------------------------------------------------
function varargout = radiobutton7_Callback(h, eventdata, handles, varargin)
% Aud to Cor, Full View
global nsl;
if get(h,'Value')
    set(handles.radiobutton4,'Value',0);
    set(handles.radiobutton5,'Value',0);
    set(handles.radiobutton6,'Value',0);
    set(handles.radiobutton3,'Value',0);
    set(handles.radiobutton12,'Value',0);
    set(handles.radiobutton13,'Value',0);
    load nslguisettings;
    rvind=[];
    for i=1:length(stg.rvdisp)
        rvind=[rvind find(stg.rv==stg.rvdisp(i))];
    end
    svind=[];
    for i=1:length(stg.svdisp)
        svind=[svind find(stg.sv==stg.svdisp(i))];
    end
    figure;
    cr_plot (abs(nsl.cor(svind,[rvind rvind+length(stg.rv)],:,:)),[[stg.fl stg.tc stg.nf log2(stg.fs/16000)] 1 0], [-stg.rvdisp stg.rvdisp], stg.svdisp, max(max(max(max(abs(nsl.cor))))));    
end


% --------------------------------------------------------------------
function varargout = pushbutton4_Callback(h, eventdata, handles, varargin)
% Cor to Aud pushbutton
global nsl;
load nslguisettings;
set(h,'String','Busy');
set(h,'ForegroundColor',[1 0 0]);
drawnow;
nsl.raud = cor2aud('tmp', nsl.rcor,   [stg.nm, stg.ft, stg.ff, stg.bp], 0);
nsl.raud = aud_fix(nsl.raud);
set(h,'String','Cor 2 Aud');
set(h,'ForegroundColor',[0 0 0]);
if get(handles.radiobutton8,'Value')
    radiobutton8_Callback(h, eventdata, handles, varargin);
elseif get(handles.radiobutton9,'Value')
    radiobutton9_Callback(h, eventdata, handles, varargin);
end
    
    

% --------------------------------------------------------------------
function varargout = radiobutton8_Callback(h, eventdata, handles, varargin)
% Cor to Aud, Frequency-Time View
global nsl;
if get(h,'Value');
    set(handles.radiobutton9,'Value',0);
    load nslguisettings;

    figure;
    aud_plot(nsl.raud,[stg.fl stg.tc stg.nf log2(stg.fs/16000)]);
end


% --------------------------------------------------------------------
function varargout = radiobutton9_Callback(h, eventdata, handles, varargin)
% Cor to Aud, Channel-Frame View
global nsl;
if get(h,'Value')
    set(handles.radiobutton8,'Value',0);
    load nslguisettings;
    figure;
    imagesc(nsl.raud');axis xy;
end


% --------------------------------------------------------------------
function varargout = pushbutton5_Callback(h, eventdata, handles, varargin)
% Aud to Wave Push button

global nsl;
load nslguisettings;
set(h,'String','Busy');
set(h,'ForegroundColor',[1 0 0]);
figure;
drawnow;
if stg.is==1
    %start from original signal, nsl.wav
    nsl.rwav=aud2wav(nsl.raud,nsl.wav,[stg.fl stg.tc stg.nf log2(stg.fs/16000) stg.it stg.di stg.sn]);
else
    nsl.rwav=aud2wav(nsl.raud,[],[stg.fl stg.tc stg.nf log2(stg.fs/16000) stg.it stg.di stg.sn]);
end
set(h,'String','Aud 2 Wav');
set(h,'ForegroundColor',[0 0 0]);


% --------------------------------------------------------------------
function varargout = pushbutton6_Callback(h, eventdata, handles, varargin)
% Play recunstructed sound
load nslguisettings;
global nsl;
soundsc(nsl.rwav,stg.fs);

% --------------------------------------------------------------------
function varargout = radiobutton10_Callback(h, eventdata, handles, varargin)
% Aud to wave Frequency-Time View



% --------------------------------------------------------------------
function varargout = radiobutton11_Callback(h, eventdata, handles, varargin)
% Aud to wave Channel-Frame View



% --------------------------------------------------------------------
function varargout = pushbutton7_Callback(h, eventdata, handles, varargin)
% Edit Parameters window
nslguiparam;


% --------------------------------------------------------------------
function varargout = radiobutton12_Callback(h, eventdata, handles, varargin)
% Aud to Cor Rate-Time View
global nsl;
if get(h,'Value')
    set(handles.radiobutton4,'Value',0);
    set(handles.radiobutton5,'Value',0);
    set(handles.radiobutton3,'Value',0);
    set(handles.radiobutton7,'Value',0);
    set(handles.radiobutton3,'Value',0);
    set(handles.radiobutton13,'Value',0);
    load nslguisettings;
    figure;
    rst_view(squeeze(mean(abs(nsl.cor),4)),stg.rv,stg.sv,1);
end


% --------------------------------------------------------------------
function varargout = radiobutton13_Callback(h, eventdata, handles, varargin)
% Aud to Cor Scale-Time View
global nsl;
if get(h,'Value')
    set(handles.radiobutton4,'Value',0);
    set(handles.radiobutton5,'Value',0);
    set(handles.radiobutton3,'Value',0);
    set(handles.radiobutton7,'Value',0);
    set(handles.radiobutton12,'Value',0);
    set(handles.radiobutton3,'Value',0);
    load nslguisettings;
    figure;
    rst_view(squeeze(mean(abs(nsl.cor),4)),stg.rv,stg.sv,2);
end

% --------------------------------------------------------------------
function varargout = pushbutton8_Callback(h, eventdata, handles, varargin)
% Open help window
nslguihelp;



% --------------------------------------------------------------------
function varargout = pushbutton9_Callback(h, eventdata, handles, varargin)
% Exit GUI
close(gcbf);


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)


% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(h, eventdata, handles)
% Refresh button
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wavfiles=dir('*.wav');
for cnt=1:size(wavfiles,1)
    current{cnt}=wavfiles(cnt).name;
end
aufiles=dir('*.au');
for cnt=1:size(aufiles,1)
    current{cnt+size(aufiles,1)}=aufiles(cnt).name;
end
set(handles.popupmenu1,'String',current);
handles.soundpath=cd;
guidata(gcbf,handles);

% --- Executes on button press in pushbutton11.
function pushbutton11_Callback(h, eventdata, handles)
% Load button
% hObject    handle to pushbutton11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
load nslguisettings;
global nsl;
soundfile=get(handles.popupmenu1,'String');
soundfile=soundfile{get(handles.popupmenu1,'Value')};
if soundfile(end-2:end)=='wav'
    [nsl.wav,ofs]=wavread([handles.soundpath '/' soundfile]);
else
    [nsl.wav,ofs]=auread([handles.soundpath '/' soundfile]);
end
if ofs~=stg.fs
    nsl.wav=resample(nsl.wav,stg.fs,ofs);
end

