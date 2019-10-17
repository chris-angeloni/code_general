function []=play(mv)

%Loading
clc;
disp(' ');
disp(' ');
disp(' Loading Movie Player...');
disp(' ');
disp(' ');

%Initializing The Figure
figNumber=figure('NumberTitle','off', ...
	'Name','Welcome to M-Player!    (c) 1996 Monty A. Escabi', ...
	'Resize','off');
set(gca,'position',[0 0 1 1]);

%Setting the axis
axis off
axHndl1=gca;
axHndl2=axes('Units','normalized','Position',[0 0 1 1],'Visible','off');
set(gcf,'Color',[0 .34 .6])
axis off
axHndl2=axes('Units','normalized','Position',[.1 .12 1 1],'Visible','off');
shading flat
colormap jet

% Create the PLAY button
playHndl=uicontrol('Style','pushbutton','Units','normalized', ...
	'Position',[.005 .005 .15 .1],'String','Play', ...
	'Enable','off','Callback','movie(mv,1,3)');
set(playHndl,'Enable','off');

% Create the FWD button
global n;
n=0;
callFwd=['if n>=length(mv(1,:)), n=0;,elseif n==[], end, n=n+1;,movie(mv(:,n))'];
fwdHndl=uicontrol('Style','pushbutton','Units','normalized', ...
	'Position',[.16 .005 .17 .1],'String','Fwd', ...
	'Enable','off','Callback',callFwd);
set(fwdHndl,'Enable','off');

% Create the BACK button
global n;
n=0;
callBack=['if n==1, n=length(mv(1,:));,elseif n==[], end, n=n-1;,movie(mv(:,n))'];
backHndl=uicontrol('Style','pushbutton','Units','normalized', ...
	'Position',[.335 .005 .18 .1],'String','Back', ...
	'Enable','off','Callback',callBack);
set(backHndl,'Enable','off');

%Enabeling Handles
set([playHndl fwdHndl backHndl],'Enable','on');

