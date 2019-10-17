%
%function []=findcftool()
%	
%	FILE NAME 	: FIND CF TOOL
%	DESCRIPTION 	: Interactive Program to find the contra and ipsi 
%			  CF of a Neuron directly from the STRF 
%
%
function []=findcftool(action)

%Global Variables
GlobalVar=' ListNum Lst Type Excite1Hndl Excite2Hndl Inhib1Hndl Inhib2Hndl Nores1Hndl Nores2Hndl dT1 Xc1 dT2 Xc2 STRFMax1 STRFMax2 CFData FileList ExpHeader Strength1 Strength2 MaxT ';
GLOBAL=['global ' GlobalVar];
eval(GLOBAL);

%Variables to save
SaveVar=' ListNum Lst CFData FileList ';

%Checking Input Arguments
if nargin<1
	action='initialize';
	ListNum=1;
end

%Generating a File List
f='ls *dB.mat *Lin.mat';
[s,List]=unix(f);
List=[setstr(10) List setstr(10)];
returnindex=findstr(List,setstr(10));
for l=1:length(returnindex)-1
	for k=1:40
		if k+returnindex(l)<returnindex(l+1)
			Lst(l,k)=List(returnindex(l)+k);
		else
			Lst(l,k)=setstr(32);
		end
	end
end

%Initializing Variables for all Choosen STRF
if nargin<1
	Xc1=[];
	dT1=[];
	Xc2=[];
	dT2=[];
	Strength1=1;
	Strength2=1;
	Type=zeros(1,6);,Type(1)=1;,Type(4)=1;
	CFData=zeros(1,12);
	CFData=-9999*ones(size(Lst,1),12);
	FileList=Lst;
	MaxT=0.1;
end

%Checking Action for 'Initialize'
if strcmp(action,'initialize')

	%Setting Plot Area
	fighandle=figure('Name',...
	'Find STRF CF Tool!   (c) 1999 Monty A. Escabi',...
	'NumberTitle','off');
	set(fighandle,'position',[400,200,600,500],'paperposition',...
	[.25 1.5  8 8.5]);

	% Setting Up The 1st CONSOLE frame
	left=.85;
	btnWid=0.125;
	btnHeight=.04;
	btnSpace=0.01;
	frmBorder=0.019; frmBottom=0.04;
	frmHeight = 0.92; frmWidth = btnWid;
	yPos=frmBottom-frmBorder;
	frmPos=[left-frmBorder yPos frmWidth+2*frmBorder frmHeight+2*frmBorder];
	h=uicontrol( ...
		'Style','frame', ...
		'Units','normalized', ...
		'Position',frmPos, ...
		'BackgroundColor',[0.5 0.5 0.5]);

	% Setting Up The 2nd CONSOLE frame
	frmPos=[.1 .021 .6 .1];
	h=uicontrol( ...
		'Style','frame', ...
		'Units','normalized', ...
		'Position',frmPos, ...
		'BackgroundColor',[0.5 0.5 0.5]);

	%Set up Plot Area
	axes( ...
		'Units','normalized', ...
		'Position',[0.10 0.1 0.60 0.8], ...
		'XTick',[],'YTick',[], ...
		'Box','on');
	set(fighandle,'defaultaxesposition',[0.10 0.2 0.6 0.7])
	freqzHnd = subplot(1,1,1);
	set(gca, ...
		'Units','normalized', ...
		'Position',[0.10 0.2 0.6 0.7], ...
		'XTick',[],'YTick',[], ...
		'Box','on');

	%The Quit Buttton
	count=0;
	btnNumber=count;
	btnPos=[left .05 btnWid btnHeight];
	labelStr='Quit';
	callbackStr=[GLOBAL ',findcftool(''quit'')'];
	QuitHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%The Delete Buttton
	count=count+1;
	btnNumber=count;
	btnPos=[left .05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='Delete';
	callbackStr=[GLOBAL ',findcftool(''delete'')'];
	AcceptHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%The Accept Buttton
	count=count+1;
	btnNumber=count;
	btnPos=[left .05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='Accept';
	callbackStr=[GLOBAL ',findcftool(''accept'')'];
	AcceptHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%The Prev Buttton
	count=count+1;
	btnNumber=count;
	btnPos=[left .05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='<< Prev';
	callbackStr=[GLOBAL ',findcftool(''prev'')'];
	PrevHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%The Next Buttton
	count=count+1;
	btnNumber=count;
	btnPos=[left .05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='Next >>';
	callbackStr=[GLOBAL ',findcftool(''next'')'];
	NextHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%No Resp 2 Button
	gap=.05;
	count=count+1;
	btnNumber=count;
	btnPos=[left gap+.05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='No Res';
	callbackStr=[GLOBAL ',findcftool(''nores2'')'];
	Nores2Hndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Strength 2 Button
	count=count+1;
	btnNumber=count;
	btnPos=[left gap+.05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='Strength';
	callbackStr=[GLOBAL ',findcftool(''strength2'')'];
	Strength2Hndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',1, ...
		'Callback',callbackStr);

	%Inhib 2 Button
	count=count+1;
	btnNumber=count;
	btnPos=[left gap+.05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='Inhib';
	callbackStr=[GLOBAL ',findcftool(''inhib2'')'];
	Inhib2Hndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Excitatory 2 Button
	count=count+1;
	btnNumber=count;
	btnPos=[left gap+.05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='Excite';
	callbackStr=[GLOBAL ',findcftool(''excite2'')'];
	Excite2Hndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',1, ...
		'Callback',callbackStr);

	%The Change 2 Buttton
	count=count+1;
	btnNumber=count;
	btnPos=[left gap+.05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='Change 2';
	callbackStr=[GLOBAL ',findcftool(''changecfdt2'')'];
	Change2Hndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%No Res 1 Button
	gap=gap*2;
	count=count+1;
	btnNumber=count;
	btnPos=[left gap+.05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='No Res';
	callbackStr=[GLOBAL ',findcftool(''nores1'')'];
	Nores1Hndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Strength 1 Button
	count=count+1;
	btnNumber=count;
	btnPos=[left gap+.05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='Strength';
	callbackStr=[GLOBAL ',findcftool(''strength1'')'];
	Strength1Hndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',1, ...
		'Callback',callbackStr);

	%Inhibit 1 Button
	count=count+1;
	btnNumber=count;
	btnPos=[left gap+.05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='Inhib';
	callbackStr=[GLOBAL ',findcftool(''inhib1'')'];
	Inhib1Hndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Excitatory 1 Button
	count=count+1;
	btnNumber=count;
	btnPos=[left gap+.05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='Excite';
	callbackStr=[GLOBAL ',findcftool(''excite1'')'];
	Excite1Hndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',1, ...
		'Callback',callbackStr);

	%The Change 1 Buttton
	count=count+1;
	btnNumber=count;
	btnPos=[left gap+.05+count*(btnHeight+btnSpace) btnWid btnHeight];
	labelStr='Change 1';
	callbackStr=[GLOBAL ',findcftool(''changecfdt1'')'];
	Change1Hndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%Save Button
	labelLeft=.085;
	labelBottom=.021;
	labelWidth=.1;
	btnPos = [labelLeft+0.025 labelBottom+0.025 labelWidth btnHeight];
	labelStr='Save';
	callbackStr=[GLOBAL ',findcftool(''SaveHeader'')'];
	SaveHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%Load Button
	labelLeft=.085+.125;
	labelBottom=.021;
	labelWidth=.1;
	btnPos = [labelLeft+0.025 labelBottom+0.025 labelWidth btnHeight];
	labelStr='Load';
	callbackStr=[GLOBAL ',findcftool(''LoadHeader'')'];
	LoadHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%Header Text
	labelLeft=.375;
	labelWidth=.3;
	labelHeight=.05;
	textPos = [labelLeft labelBottom+.025 labelWidth labelHeight];
	callbackStr = [GLOBAL ',findcftool(''ChangeHeader'')'];
	ExpHeader=['Header'];
	HeaderHndl = uicontrol( ...
		'Style','edit', ...
		'Units','normalized', ...
		'Position',textPos, ...
		'Horiz','right', ...
		'Background','white', ...
		'Foreground','black', ...
		'String',ExpHeader, ...
		'callback',callbackStr);

	%Plot Data
	f=[GLOBAL ',findcftool(''plotall'')'];
	eval(f);

elseif strcmp(action,'plotall')

	%Plot All Data
	f=[GLOBAL ',findcftool(''plotstrf'')'];
	eval(f);
	f=[GLOBAL ',findcftool(''plotdtxc'')'];
	eval(f);

elseif strcmp(action,'plotstrf')

	%Plotting STRF1s and STRF2s	
	f=[GLOBAL ',findcftool(''plotstrf1'')'];
	eval(f);
	f=[GLOBAL ',findcftool(''plotstrf2'')'];
	eval(f);

elseif strcmp(action,'plotstrf1')

	%Loading File
	f=['load ' Lst(ListNum,:) ];
	eval(f);

	%Plotting STRF1s 
	Max=max(max(abs([STRF1s STRF2s]*sqrt(PP))));
	subplot(211)
	imagesc(taxis,log2(faxis/faxis(1)),STRF1s*sqrt(PP)),...
	shading flat,colormap jet,set(gca,'YDir','normal') 
	Max=max(max(abs([STRF1s STRF2s]*sqrt(PP))));
	axis( [ min(taxis) min(taxis)+MaxT 0 max(log2(faxis/faxis(1))) ]  ) 
	caxis([-Max Max]);
	title([Lst(ListNum,:) ', Wo=' num2str(Wo1,3) ', STRFMax=' num2str(Max,3) ])

elseif strcmp(action,'plotstrf2')

	%Loading File
	f=['load ' Lst(ListNum,:) ];
	eval(f);

	%Plotting STRF2s 
	Max=max(max(abs([STRF1s STRF2s]*sqrt(PP))));
	subplot(212)
	imagesc(taxis,log2(faxis/faxis(1)),STRF2s*sqrt(PP)),...
	shading flat,colormap jet,set(gca,'YDir','normal')
	Max=max(max(abs([STRF1s STRF2s]*sqrt(PP))));
	axis( [ min(taxis) min(taxis)+MaxT 0 max(log2(faxis/faxis(1))) ]  ) 
	caxis([-Max Max]);

elseif strcmp(action,'plotdtxc')

	%Loading File
	f=['load ' Lst(ListNum,:) ];
	eval(f);

	%Finding Maximum Peak for STRF1s and Plotting
	subplot(211)
	[i,j]=find(abs(STRF1s)==max(max(abs(STRF1s))));
	Xc1=log2(faxis(i)/faxis(1));
	dT1=taxis(j);
	STRFMax1=STRF1s(i,j)*sqrt(PP);
	hold on
	plot(dT1,Xc1,'ko','linewidth',2)
	hold off

	%Finding Maximum Peak for STRF2s
	subplot(212)
	[i,j]=find(abs(STRF2s)==max(max(abs(STRF2s))));
	Xc2=log2(faxis(i)/faxis(1));
	dT2=taxis(j);
	STRFMax2=STRF2s(i,j)*sqrt(PP);
	hold on
	plot(dT2,Xc2,'ko','linewidth',2)
	hold off

elseif strcmp(action,'changecfdt1')

	%Loading File
	f=['load ' Lst(ListNum,:) ];
	eval(f);

	%Getting Input
	subplot(211)
	[dT1,Xc1]=ginput(1)
	i=find(dT1<taxis+taxis(3)-taxis(2));
	j=find(Xc1<log2(faxis/faxis(1))+log2(faxis(2)/faxis(1)));
	STRFMax1=STRF1s(j(1),i(1))*sqrt(PP);
	hold on

	%Reploting STRF1s
	f=[GLOBAL ',findcftool(''plotstrf1'')'];
	eval(f);

	%Plotting Dots
	subplot(211)
	hold on
	plot(dT1,Xc1,'ko','linewidth',2)
	hold off

elseif strcmp(action,'changecfdt2')

	%Loading File
	f=['load ' Lst(ListNum,:) ];
	eval(f);

	%Getting Input
	subplot(212)
	[dT2,Xc2]=ginput(1);
	i=find(dT2<taxis+taxis(3)-taxis(2));
	j=find(Xc2<log2(faxis/faxis(1))+log2(faxis(2)/faxis(1)));
	STRFMax2=STRF2s(j(1),i(1))*sqrt(PP);

	%Reploting STRF2s
	f=[GLOBAL ',findcftool(''plotstrf2'')'];
	eval(f);

	%Plotting Dots
	subplot(212)
	hold on
	plot(dT2,Xc2,'ko','linewidth',2)
	hold off

elseif strcmp(action,'excite1')

	%Binaural Type
        v=get(gco,'value');
        if v==1
                Type(1)=1;
                Type(2)=0;
                Type(3)=0;
		set(Excite1Hndl,'value',Type(1));
		set(Inhib1Hndl,'value',Type(2));
		set(Nores1Hndl,'value',Type(3));
        elseif v==0
                Type(1)=0;
        end

elseif strcmp(action,'inhib1')

	%Binaural Type
        v=get(gco,'value');
        if v==1
                Type(1)=0;
                Type(2)=1;
                Type(3)=0;
		set(Excite1Hndl,'value',Type(1));
		set(Inhib1Hndl,'value',Type(2));
		set(Nores1Hndl,'value',Type(3));
        elseif v==0
                Type(2)=0;
        end

elseif strcmp(action,'strength1')

	%STRF Strength
        v=get(gco,'value');
        if v==1
		Strength1=1;	%Strong
        elseif v==0
                Strength1=0;	%Weak
        end

elseif strcmp(action,'nores1')

	%Binaural Type
        v=get(gco,'value');
        if v==1
                Type(1)=0;
                Type(2)=0;
                Type(3)=1;
		set(Excite1Hndl,'value',Type(1));
		set(Inhib1Hndl,'value',Type(2));
		set(Nores1Hndl,'value',Type(3));
        elseif v==0
                Type(3)=0;
        end

elseif strcmp(action,'excite2')

	%Binaural Type
        v=get(gco,'value');
        if v==1
                Type(4)=1;
                Type(5)=0;
                Type(6)=0;
		set(Excite2Hndl,'value',Type(4));
		set(Inhib2Hndl,'value',Type(5));
		set(Nores2Hndl,'value',Type(6));
        elseif v==0
                Type(4)=0;
        end

elseif strcmp(action,'inhib2')

	%Binaural Type
        v=get(gco,'value');
        if v==1
                Type(4)=0;
                Type(5)=1;
                Type(6)=0;
		set(Excite2Hndl,'value',Type(4));
		set(Inhib2Hndl,'value',Type(5));
		set(Nores2Hndl,'value',Type(6));
        elseif v==0
                Type(5)=0;
        end

elseif strcmp(action,'strength2')

	%STRF Strength
        v=get(gco,'value');
        if v==1
		Strength2=1;	%Strong
        elseif v==0
                Strength2=0;	%Weak
        end


elseif strcmp(action,'nores2')

	%Binaural Type
        v=get(gco,'value');
        if v==1
                Type(4)=0;
                Type(5)=0;
                Type(6)=1;
		set(Excite2Hndl,'value',Type(4));
		set(Inhib2Hndl,'value',Type(5));
		set(Nores2Hndl,'value',Type(6));
        elseif v==0
                Type(6)=0;
        end

elseif strcmp(action,'ChangeHeader')

	ExpHeader=get(gco,'String');
	set(gco,'String',ExpHeader);
	set(gcf,'Pointer','watch');
	pause(1)
	set(gcf,'Pointer','arrow');

elseif strcmp(action,'SaveHeader')

	%Saving Data
	if strcmp(version,'4.2c')
		f=['save ' ExpHeader '_CFstats.mat ' SaveVar];
		eval(f);
	else
		f=['save ' ExpHeader '_CFstats.mat ' SaveVar ' -v4'];
		eval(f);
	end

elseif strcmp(action,'LoadHeader')

	%Loading Data
	filename=[ExpHeader '_CFstats.mat'];
	if exist(filename)

		%Loading File
		f=['load ' filename];
		eval(f);

		%Plot Data
		f=[GLOBAL ',findcftool(''plotall'')'];
		eval(f);
		
	else
		clc
		disp('Sorry: File Does Not Exist :-(');
	end

elseif strcmp(action,'next')

	%Incrementing List Number
	ListNum=ListNum+1;

	%Replotting
	f=[GLOBAL,',findcftool(''plotall'')'];
	eval(f);
	
elseif strcmp(action,'prev')

	%Decrementing List Number
	ListNum=ListNum-1;

	%Replotting
	f=[GLOBAL,',findcftool(''plotall'')'];
	eval(f);

elseif strcmp(action,'delete')

	%Deleting Most Current Entry From Stack
	CFData(ListNum,:)=-9999*ones(1,12);

elseif strcmp(action,'accept')

	%Storing Data to CFData
	if Type(3)==1
		CFData(ListNum,:)=[Type -9999 -9999 Xc2 dT2 Strength1 Strength2 ];
	elseif Type(6)==1
		CFData(ListNum,:)=[Type Xc1 dT1 -9999 -9999 Strength1 Strength2 ];
	elseif Type(6)==1 & Type(3)==1
		CFData(ListNum,:)=[Type -9999 -9999 -9999 -9999 Strength1 Strength2];
	else
		CFData(ListNum,:)=[Type Xc1 dT1 Xc2 dT2 Strength1 Strength2];
	end

	%Go On To the Next Unit
        findcftool('next');

elseif strcmp(action,'quit'),

        close
        clc
        disp('Goodbye !!!')

else

        disp(sprintf( ...
        'findcftool: action string ''%s'' not recognized, no action taken.',action))

end

