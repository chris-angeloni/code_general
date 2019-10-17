function varargout = nslguiparam(varargin)
% NSLGUIPARAM Application M-file for nslguiparam.fig
%    FIG = NSLGUIPARAM launch nslguiparam GUI.
%    NSLGUIPARAM('callback_name', ...) invoke the named callback.

% Last Modified by GUIDE v2.5 04-May-2004 12:13:48

if nargin == 0  % LAUNCH GUI

	fig = openfig(mfilename,'reuse');
    movegui(fig,'center');

	% Use system color scheme for figure:
	set(fig,'Color',get(0,'defaultUicontrolBackgroundColor'));

	% Generate a structure of handles to pass to callbacks, and store it. 
	handles = guihandles(fig);
	guidata(fig, handles);
%Load Settings;
    load nslguisettings;
    set(handles.edit5,'String',num2str(stg.fs));
    set(handles.edit16,'String',num2str(stg.tw));
    set(handles.edit1,'String',num2str(stg.fl));
    set(handles.edit2,'String',num2str(stg.tc));
    set(handles.edit3,'String',num2str(stg.nf));
    set(handles.edit6,'String',num2str(stg.ft));
    set(handles.edit7,'String',num2str(stg.ff));
    set(handles.edit8,'String',num2str(stg.bp));
    set(handles.edit9,'String',num2str(stg.nm));
    rvs=num2str(stg.rv(1));
    for i=2:length(stg.rv)
        rvs=[rvs ', ' num2str(stg.rv(i)) ];
    end
    svs=num2str(stg.sv(1));
    for i=2:length(stg.sv)
        svs=[svs ', ' num2str(stg.sv(i))];
    end
    set(handles.edit10,'String',rvs);
    set(handles.edit11,'String',svs);
    set(handles.edit14,'String',num2str(stg.it));
    rvs=num2str(stg.rvdisp(1));
    for i=2:length(stg.rvdisp)
        rvs=[rvs ', ' num2str(stg.rvdisp(i))];
    end
    svs=num2str(stg.svdisp(1));
    for i=2:length(stg.svdisp)
        svs=[svs ', ' num2str(stg.svdisp(i))];
    end
    set(handles.edit12,'String',rvs);
    set(handles.edit13,'String',svs);
    set(handles.checkbox2,'Value',stg.sn);
    set(handles.checkbox3,'Value',stg.di);
    if stg.is==1
        set(handles.radiobutton1,'Value',1);
        set(handles.radiobutton2,'Value',0);
    else
        set(handles.radiobutton1,'Value',0);
        set(handles.radiobutton2,'Value',1);
    end
    

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
function varargout = edit1_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit2_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit3_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit4_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit5_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit6_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit7_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit8_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit9_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = checkbox1_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit10_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit11_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit12_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit13_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = edit14_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = pushbutton1_Callback(h, eventdata, handles, varargin)
%Default
load nslguidefault;
set(handles.edit5,'String',num2str(stg.fs));
set(handles.edit1,'String',num2str(stg.fl));
set(handles.edit2,'String',num2str(stg.tc));
set(handles.edit3,'String',num2str(stg.nf));
set(handles.edit6,'String',num2str(stg.ft));
set(handles.edit7,'String',num2str(stg.ff));
set(handles.edit8,'String',num2str(stg.bp));
set(handles.edit9,'String',num2str(stg.nm));
set(handles.edit16,'String',num2str(stg.tw));
rvs=num2str(stg.rv(1));
for i=2:length(stg.rv)
    rvs=[rvs ', ' num2str(stg.rv(i)) ];
end
svs=num2str(stg.sv(1));
for i=2:length(stg.sv)
    svs=[svs ', ' num2str(stg.sv(i))];
end
set(handles.edit10,'String',rvs);
set(handles.edit11,'String',svs);
set(handles.edit14,'String',num2str(stg.it));
rvs=num2str(stg.rvdisp(1));
for i=2:length(stg.rvdisp)
    rvs=[rvs ', ' num2str(stg.rvdisp(i))];
end
svs=num2str(stg.svdisp(1));
for i=2:length(stg.svdisp)
    svs=[svs ', ' num2str(stg.svdisp(i))];
end
set(handles.edit12,'String',rvs);
set(handles.edit13,'String',svs);
set(handles.checkbox2,'Value',stg.sn);
set(handles.checkbox3,'Value',stg.di);
if stg.is==1
    set(handles.radiobutton1,'Value',1);
    set(handles.radiobutton2,'Value',0);
else
    set(handles.radiobutton1,'Value',0);
    set(handles.radiobutton2,'Value',1);
end




% --------------------------------------------------------------------
function varargout = pushbutton2_Callback(h, eventdata, handles, varargin)
close (gcbf);




% --------------------------------------------------------------------
function varargout = pushbutton3_Callback(h, eventdata, handles, varargin)
%Ok
stg.fs=str2num(get(handles.edit5,'String'));
stg.fl=str2num(get(handles.edit1,'String'));
stg.tc=str2num(get(handles.edit2,'String'));
stg.nf=str2num(get(handles.edit3,'String'));
stg.tw=str2num(get(handles.edit16,'String'));

stg.ft=str2num(get(handles.edit6,'String'));
stg.ff=str2num(get(handles.edit7,'String'));

stg.bp=str2num(get(handles.edit8,'String'));
stg.nm=str2num(get(handles.edit9,'String'));
stg.rv=str2num(get(handles.edit10,'String'));
stg.sv=str2num(get(handles.edit11,'String'));
stg.it=str2num(get(handles.edit14,'String'));
stg.rvdisp=str2num(get(handles.edit12,'String'));
stg.svdisp=str2num(get(handles.edit13,'String'));
if get(handles.radiobutton1,'Value')==1
    stg.is=1;
else
    stg.is=2;
end
stg.sn=get(handles.checkbox2,'Value');
stg.di=get(handles.checkbox3,'Value');
savepath=which ('nslguisettings.mat');
save(savepath,'stg');
close(gcbf);




% --------------------------------------------------------------------
function varargout = edit15_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = radiobutton1_Callback(h, eventdata, handles, varargin)
if get(handles.radiobutton1,'Value')==1
    set(handles.radiobutton2,'Value',0);
end
% --------------------------------------------------------------------
function varargout = radiobutton2_Callback(h, eventdata, handles, varargin)
if get(handles.radiobutton2,'Value')==1
    set(handles.radiobutton1,'Value',0);
end



% --------------------------------------------------------------------
function varargout = checkbox2_Callback(h, eventdata, handles, varargin)




% --------------------------------------------------------------------
function varargout = checkbox3_Callback(h, eventdata, handles, varargin)


% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc
    set(hObject,'BackgroundColor','white');
else
    set(hObject,'BackgroundColor',get(0,'defaultUicontrolBackgroundColor'));
end



function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double


