%
%function []=rtfanaltool()
%
%       FILE NAME       : RTF ANAL TOOL
%       DESCRIPTION     : Ripple Transfer Function Analysis Tool
%			  Interactive utility used to derive parameters
%			  from Spectro-Temporal Receptive Field and 
%			  Ripple Transfer Function
%
function []=rtfanaltool(action);

%Global Variables
GlobalVar=' ModType ListNum RTFType Noise fighandle StrfType UType TempFiltType SpecFiltType Lst FileList BFm1 BFm2 BRD1 BRD2 BFm1RTFH BFm2RTFH BRD1RTFH BRD2RTFH BFm1RTF BFm2RTF BRD1RTF BRD2RTF STRFType TemporalType SpectralType UnitType BestFm1s BestFm1r BestFm1h BestFm2s BestFm2r BestFm2h BestRD1s BestRD1r BestRD1h BestRD2s BestRD2r BestRD2h invert ExpHeader Selectivity SELECTIVITY TempLowHndl TempBandHndl SpecLowHndl SpecBandHndl SingleHndl MultiHndl TSTRF ';
GLOBAL=['global ' GlobalVar];
eval(GLOBAL);

%Save Variables
SaveVar=' ModType ListNum Noise fighandle StrfType UType TempFiltType SpecFiltType FileList BFm1 BFm2 BRD1 BRD2 BFm1RTF BFm2RTF BRD1RTF BRD2RTFH  BFm1RTFH BFm2RTFH BRD1RTFH BRD2RTFH STRFType TemporalType SpectralType UnitType BestFm1s BestFm1r BestFm1h BestFm2s BestFm2r BestFm2h BestRD1s BestRD1r BestRD1h BestRD2s BestRD2r BestRD2h invert ExpHeader Selectivity SELECTIVITY ';

%Initializing
if nargin<1
	ModType='dB';
	action='Initialize';
	ListNum=1;
	Noise='n';
	RTFType='RTFH';
end

%Initializing Variables for all Choosen STRF
if nargin<1

	L=size(Lst,1);
	
	BFm1RTF=-9999*ones(L,2);	%Best Fm Channel 1 - from RTF
        BFm2RTF=-9999*ones(L,2);	%Best Fm Channel 2 - from RTF
        BRD1RTF=-9999*ones(L,2);	%Best RD Channel 1 - from RTF
        BRD2RTF=-9999*ones(L,2);	%Best RD Channel 2 - from RTF
        BFm1RTFH=-9999*ones(L,2);	%Best Fm Channel 1 - from RTFH
        BFm2RTFH=-9999*ones(L,2);	%Best Fm Channel 2 - from RTFH
        BRD1RTFH=-9999*ones(L,2);	%Best RD Channel 1 - from RTFH
        BRD2RTFH=-9999*ones(L,2);	%Best RD Channel 2 - from RTFH
        BFm1=-9999*ones(L,1);		%Best Fm Channel 1 - default from RTF
        BFm2=-9999*ones(L,1);		%Best Fm Channel 2 - default from RTF
        BRD1=-9999*ones(L,1);		%Best RD Channel 1 - default from RTF
        BRD2=-9999*ones(L,1);		%Best RD Channel 2 - default from RTF

	SELECTIVITY=-9999*ones(L,3);	%Neuron Selectivity - High, Medium, Low
	TemporalType=-9999*ones(L,3);	%Low Pass, Band Pass, Diffused
	SpectralType=-9999*ones(L,3);	%Low Pass, Band Pass, Diffused
	UnitType=-9999*ones(L,2);	%Single, Multi

	TSTRF=-9999;			%Temporal delay for plotting STRF - 
					% -9999 -> to use maximum delay in STRF

end

%Variables for Current STRF
if nargin<1
	TempFiltType=zeros(1,3);
	SpecFiltType=zeros(1,3);
	UType=zeros(1,2);
	StrfType=zeros(1,6);
	invert=1;		%Invert Spike Waveform
	Selectivity=[1 0 0];	%Neuron Selectivity

	BestFm1s=-9999;			%Flag Indicates Not Active - RTF
	BestFm2s=-9999;			%Flag Indicates Not Active - RTF
	BestRD1s=-9999;			%Flag Indicates Not Active - RTF
	BestRD2s=-9999;			%Flag Indicates Not Active - RTF
	BestFm1r=[-9999 -9999];		%Flag Indicates Not Active - RTF
	BestFm2r=[-9999 -9999];		%Flag Indicates Not Active - RTF
	BestRD1r=[-9999 -9999];		%Flag Indicates Not Active - RTF
	BestRD2r=[-9999 -9999];		%Flag Indicates Not Active - RTF
	BestFm1h=[-9999 -9999];		%Flag Indicates Not Active - RTFH
	BestFm2h=[-9999 -9999];		%Flag Indicates Not Active - RTFH
	BestRD1h=[-9999 -9999];		%Flag Indicates Not Active - RTFH
	BestRD2h=[-9999 -9999];		%Flag Indicates Not Active - RTFH
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
FileList=setstr(Lst);

%Checking Action
if strcmp(action,'Initialize')

	%Setting Plot Area
    	fighandle=figure('Name',...
	'Ripple Transfer Function Analysis Tool!   (c) 1998 Monty A. Escabi',...
	'NumberTitle','off');
	set(fighandle,'position',[10,400,700,700],'paperposition',[.25 1.5  8 8.5]);

	%Information for All Button
	labelColor=[0.8 0.8 0.8];
	yInitPos=0.90;
	menutop=0.97;
	btnTop = 0.6;
	top=0.75;
	left=0.785;
	btnWid=0.175;
	btnHt=0.03;
	textHeight=.03;
	textWidth = 0.06;
	% Spacing between the button and the next command's label
	spacing=0.005;

    %==================================
    % Set up the frequency response axes
    axes( ...
        'Units','normalized', ...
        'Position',[0.10 0.1 0.60 0.8], ...
        'XTick',[],'YTick',[], ...
        'Box','on');
    set(fighandle,'defaultaxesposition',[0.10 0.1 0.60 0.80])
    freqzHnd = subplot(1,1,1);
    set(gca, ...
        'Units','normalized', ...
        'Position',[0.10 0.1 0.60 0.8], ...
        'XTick',[],'YTick',[], ...
        'Box','on');

	% Setting Up The 1nd CONSOLE frame
	frmBorder1=0.019; frmBottom1=0.04; 
	frmHeight1 = 0.13; frmWidth1 = btnWid*2;
	yPos1=frmBottom1-frmBorder1;
	left1=.39
	frmPos1=[left1-frmBorder1 yPos1 frmWidth1+2*frmBorder1,...
		 frmHeight1+2*frmBorder1];
	h=uicontrol( ...
		'Style','frame', ...
		'Units','normalized', ...
		'Position',frmPos1, ...
		'BackgroundColor',[0.5 0.5 0.5]);

	% File Header Label
	labelLeft=.38;
	labelBottom=.05;
	labelWidth=.35;
	labelHeight=.05;
	labelPos = [labelLeft labelBottom labelWidth labelHeight];
	h = uicontrol( ...
		'Style','text', ...
		'Units','normalized', ...
		'Position',labelPos, ...
		'Horiz','left', ...
		'String','Experiment Header', ...
		'Interruptible','no', ...
		'BackgroundColor',[0.5 0.5 0.5], ...
		'ForegroundColor','white');

	%Header Text
	labelLeft=.38;
	labelBottom=.03;
	labelWidth=.2;
	labelHeight=.03;
    	textPos = [labelLeft labelBottom labelWidth labelHeight];
    	callbackStr = [GLOBAL ',rtfanaltool(''ChangeHeader'')'];
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

	%Invert Spike Label
	labelLeft=.595;
	labelBottom=.135;
	labelWidth=.16;
	labelHeight=.05;
	labelPos = [labelLeft labelBottom labelWidth labelHeight];
	h = uicontrol( ...
		'Style','text', ...
		'Units','normalized', ...
		'Position',labelPos, ...
		'Horiz','left', ...
		'String','Spike Waveform', ...
		'Interruptible','no', ...
		'BackgroundColor',[0.5 0.5 0.5], ...
		'ForegroundColor','white');

	%Invert Spike Button
	labelLeft=.595;
	labelBottom=.105;
	labelWidth=.15;
	labelHeight=.03;
	btnPos = [labelLeft labelBottom labelWidth labelHeight];
	labelStr='Invert';
	callbackStr=[GLOBAL ',rtfanaltool(''InvertSpike'')']; 
	InvertHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Load Button
	labelLeft=.595;
	labelBottom=.03;
	labelWidth=.15;
	labelHeight=.03;
	btnPos = [labelLeft labelBottom labelWidth labelHeight];
	labelStr='Load Data';
	callbackStr=[GLOBAL ',rtfanaltool(''LoadHeader'')']; 
	LoadHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%Save Button
	labelLeft=.595;
	labelBottom=.066;
	labelWidth=.15;
	labelHeight=.03;
	btnPos = [labelLeft labelBottom labelWidth labelHeight];
	labelStr='Save Data';
	callbackStr=[GLOBAL ',rtfanaltool(''SaveHeader'')']; 
	SaveHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%Best FM1 and RD1 Button - Parameters for channel 1
	labelLeft=.38;
	labelBottom=.15;
	labelWidth=.08;
	labelHeight=.03;
	btnPos = [labelLeft labelBottom labelWidth labelHeight];
	labelStr='Param1';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeBFMRD1'')']; 
	BestFMRD1Hndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%Best FM2 and RD2 Button - Parameters for channel 2
	labelLeft=.49;
	labelBottom=.15;
	labelWidth=.08;
	labelHeight=.03;
	btnPos = [labelLeft labelBottom labelWidth labelHeight];
	labelStr='Param2';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeBFMRD2'')']; 
	BestFMRD2Hndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%Best FM/RD Type Button - toggle between RTF and RTFH for choosing
	%Parameters
	labelLeft=.38;
	labelBottom=.1;
	labelWidth=.08;
	labelHeight=.03;
	btnPos = [labelLeft labelBottom labelWidth labelHeight];
	labelStr='RTFH|RTF';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeRTFType'')']; 
	ChngeRTFTypeHndl=uicontrol( ...
		'Style','popupmenu', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Interruptible','yes', ...
		'Callback',callbackStr);

	% Setting Up The 2st CONSOLE frame
	frmBorder=0.019; frmBottom=0.04; 
	frmHeight = 0.92; frmWidth = btnWid;
	yPos=frmBottom-frmBorder;
	frmPos=[left-frmBorder yPos frmWidth+2*frmBorder frmHeight+2*frmBorder];
	h=uicontrol( ...
		'Style','frame', ...
		'Units','normalized', ...
		'Position',frmPos, ...
		'BackgroundColor',[0.5 0.5 0.5]);

	%Button Counter
	count=0;

	%NOISE Cleaned Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='No Noise|Noise';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeNoise'')']; 
	NoiseHndl=uicontrol( ...
		'Style','popupmenu', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Interruptible','yes', ...
		'Callback',callbackStr);
    
	% ModType Label
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	top = yPos - btnHt - spacing;
	labelWidth = frmWidth-textWidth-.01;
	labelBottom=top-textHeight;
	labelLeft = left;
	labelPos = [labelLeft labelBottom labelWidth textHeight];
	h = uicontrol( ...
		'Style','text', ...
		'Units','normalized', ...
		'Position',labelPos, ...
		'Horiz','left', ...
		'String','Mod', ...
		'Interruptible','no', ...
		'BackgroundColor',[0.5 0.5 0.5], ...
		'ForegroundColor','white');

	%SModType Label
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	top = yPos - btnHt - spacing;
	labelWidth = frmWidth-textWidth-.01;
	labelBottom=top-textHeight;
	labelLeft = left;
	labelPos = [labelLeft labelBottom labelWidth textHeight];
	h = uicontrol( ...
	        'Style','text', ...
        	'Units','normalized', ...
        	'Position',labelPos, ...
        	'Horiz','left', ...
        	'String','SMod', ...
        	'Interruptible','no', ...
        	'BackgroundColor',[0.5 0.5 0.5], ...
        	'ForegroundColor','white');

    	%ModType and SModType Text Label
    	textPos = [labelLeft+labelWidth labelBottom-.02 textWidth 3*textHeight];
    	callbackStr = 'filtdemo(''setFreqs'')';
    	ModStr = sprintf(['dB' setstr(10) setstr(10) 'dB' setstr(10)]);
	ModType='dB';
	SModType='dB';
	mat=[200;100]
    	FreqsHndl = uicontrol( ...
		'Style','edit', ...
		'Units','normalized', ...
		'Position',textPos, ...
		'Max',2, ... % makes this a multiline edit object
		'Horiz','right', ...
		'Background','white', ...
		'Foreground','black', ...
		'String',ModStr,'Userdata',mat, ...
		'callback',callbackStr);

	%STRF Type Label
	count=count+2;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	labelWidth = 1.5*( frmWidth-textWidth );
	labelLeft = left;
	labelPos = [labelLeft yPos-btnHt labelWidth btnHt];
	h = uicontrol( ...
	        'Style','text', ...
        	'Units','normalized', ...
        	'Position',labelPos, ...
        	'Horiz','left', ...
        	'String','STRF Type', ...
        	'Interruptible','no', ...
        	'BackgroundColor',[0.5 0.5 0.5], ...
        	'ForegroundColor','white');

	%Simple STRF Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Simple';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeStrf1'')']; 
	SimpleHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Complex STRF Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Complex';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeStrf2'')']; 
	ComplexHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Broad STRF Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Broad';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeStrf3'')']; 
	BroadHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Oblique STRF Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Oblique';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeStrf4'')']; 
	ObliqueHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Multi Peak STRF Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Multi Peak';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeStrf5'')']; 
	MultiHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Other STRF Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Other';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeStrf6'')']; 
	OtherHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Selectivity Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='High|Medium|Low';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeSelectivity'')']; 
	SelectivityHndl=uicontrol( ...
		'Style','popupmenu', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Interruptible','yes', ...
		'Callback',callbackStr);

	%Temporal Type Type Label
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	labelWidth = 1.5*( frmWidth-textWidth );
	labelLeft = left;
	labelPos = [labelLeft yPos-btnHt labelWidth btnHt];
	h = uicontrol( ...
	        'Style','text', ...
        	'Units','normalized', ...
        	'Position',labelPos, ...
        	'Horiz','left', ...
        	'String','Temporal', ...
        	'Interruptible','no', ...
        	'BackgroundColor',[0.5 0.5 0.5], ...
        	'ForegroundColor','white');

	%Temporal Low-Pass Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Low Pass';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeTemporal1'')']; 
	TempLowHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Temporal Band-Pass Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Band Pass';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeTemporal2'')']; 
	TempBandHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Temporal Diffused Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Diffused';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeTemporal3'')']; 
	TempDiffHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Spectral Type Type Label
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	labelWidth = 1.5*( frmWidth-textWidth );
	labelLeft = left;
	labelPos = [labelLeft yPos-btnHt labelWidth btnHt];
	h = uicontrol( ...
	        'Style','text', ...
        	'Units','normalized', ...
        	'Position',labelPos, ...
        	'Horiz','left', ...
        	'String','Spectral', ...
        	'Interruptible','no', ...
        	'BackgroundColor',[0.5 0.5 0.5], ...
        	'ForegroundColor','white');

	%Spectral Low-Pass Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Low Pass';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeSpectral1'')']; 
	SpecLowHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Spectral Band-Pass Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Band Pass';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeSpectral2'')']; 
	SpecBandHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Spectral Diffused Button
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Difused';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeSpectral3'')']; 
	SpecDiffHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Unit Type Label
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	labelWidth = 1.5*( frmWidth-textWidth );
	labelLeft = left;
	labelPos = [labelLeft yPos-btnHt labelWidth btnHt];
	h = uicontrol( ...
	        'Style','text', ...
        	'Units','normalized', ...
        	'Position',labelPos, ...
        	'Horiz','left', ...
        	'String','Unit Type', ...
        	'Interruptible','no', ...
        	'BackgroundColor',[0.5 0.5 0.5], ...
        	'ForegroundColor','white');

	%Unit Type Button - Single
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Single';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeUnit1'')']; 
	SingleHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%Unit Type Button - Multi
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Multi';
	callbackStr=[GLOBAL ',rtfanaltool(''ChangeUnit2'')']; 
	MultiHndl=uicontrol( ...
		'Style','checkbox', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

	%The NEXT Buttton
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Next >>';
	callbackStr=[GLOBAL ',rtfanaltool(''Next'')'];
	NextHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%The PREV Buttton
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='<< Prev';
	callbackStr=[GLOBAL ',rtfanaltool(''Prev'')'];
	PrevHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%The  ACCEPT Buttton
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Accept';
	callbackStr=[GLOBAL ',rtfanaltool(''Accept'')'];
	AcceptHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%The  Quit Buttton
	count=count+1;
	btnNumber=count;
	yPos=menutop-(btnNumber-1)*(btnHt+spacing);
	btnPos=[left yPos-btnHt btnWid btnHt];
	labelStr='Quit';
	callbackStr=[GLOBAL ',rtfanaltool(''Quit'')'];
	QuitHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%Plotting First RF
	f=[GLOBAL ',rtfanaltool(''PlotAll'')'];
	eval(f);

elseif strcmp(action,'PlotAll'),

	%Setting Mouse Pointer to Watch
	set(gcf,'Pointer','watch');

	%Loading STRF Data
	index=findstr('.mat',Lst(ListNum,:));
	STRFFile=[ Lst(ListNum,1:index-1) '.mat'];
	if exist(STRFFile) 
		f=['load ' STRFFile];
		eval(f);
	end;

	%Loading RTF Data
	index=findstr(['dB.mat'],Lst(ListNum,:));
	if isempty(index)
		index=findstr(['Lin.mat'],Lst(ListNum,:));
	end
	RTFFile=[ Lst(ListNum,1:index-1) 'RTF.mat'];
	if exist(RTFFile)
		f=['load ' RTFFile];
		eval(f);
	end

	%Loading Spike Data
	index1=findstr('_u',Lst(ListNum,:));
	index2=findstr(['_dB.mat'],Lst(ListNum,:));
	if isempty(index2)
		index2=findstr(['_Lin.mat'],Lst(ListNum,:));
	end
	UnitNumber=setstr(str2num(setstr(Lst(ListNum,index1+2:index2-1))));
	SpikeFile=[ Lst(ListNum,1:index1-1) '.mat'];
	if exist(SpikeFile)
		f=['load ' SpikeFile];
		eval(f);
	end

	%Plotting Data
	if strcmp(Noise,'n')
		%Plotting STRF Data 
		if exist(STRFFile)
			subplot(3.5,2,1)
			pcolor(taxis,log2(faxis/faxis(1)),STRF1s*sqrt(PP)),...
			shading flat, colormap jet
			if TSTRF==-9999
				axis([min(taxis) max(taxis) 0 max(log2(faxis/faxis(1)))])
			else
				axis([min(taxis) min(taxis)+TSTRF 0 max(log2(faxis/faxis(1)))])
			end
			index=findstr(STRFFile,'_');
			filename=STRFFile;
			for k=1:length(index)
				filename(index(k))='-';
			end
			title(filename)

			subplot(3.5,2,2)
			pcolor(taxis,log2(faxis/faxis(1)),STRF2s*sqrt(PP)),...
			shading flat, colormap jet
			if TSTRF==-9999
				axis([min(taxis) max(taxis) 0 max(log2(faxis/faxis(1)))])
			else
				axis([min(taxis) min(taxis)+TSTRF 0 max(log2(faxis/faxis(1)))])
			end
			title(['Wo1 = ' num2str(Wo1) ' , No1 = ' num2str(No1,6)])
		end

		%Plotting RTF Data 
		if exist(RTFFile)
			subplot(3.5,2,3)
			pcolor(Fm,RD,RTF1s),shading flat, colormap jet, ...
			axis([min(Fm) max(Fm) 0 max(RD) ])
			hold on
			plot(BestFm1s,BestRD1s,'ko','linewidth',5)
			hold off
			title(['Sound = ' Sound ' , SModType = ' SModType])

			subplot(3.5,2,4)
			pcolor(Fm,RD,RTF2s),shading flat, colormap jet,...
			axis([min(Fm) max(Fm) 0 max(RD) ])
			hold on
			plot(BestFm2s,BestRD2s,'ko','linewidth',5)
			hold off
		end
	else
		%Plotting STRF Data 
		if exist(STRFFile)
			subplot(3.5,2,1)
			pcolor(taxis,log2(faxis/faxis(1)),STRF1*sqrt(PP)),...
			shading flat, colormap jet
			if TSTRF==-9999
				axis([min(taxis) max(taxis) 0 max(log2(faxis/faxis(1)))])
			else
				axis([min(taxis) min(taxis)+TSTRF 0 max(log2(faxis/faxis(1)))])
			end
			index=findstr(STRFFile,'_');
			filename=STRFFile;
			for k=1:length(index)
				filename(index(k))='-';
			end
			title(filename)

			subplot(3.5,2,2)
			pcolor(taxis,log2(faxis/faxis(1)),STRF2*sqrt(PP)),...
			shading flat, colormap jet
			if TSTRF==-9999
				axis([min(taxis) max(taxis) 0 max(log2(faxis/faxis(1)))])
			else
				axis([min(taxis) min(taxis)+TSTRF 0 max(log2(faxis/faxis(1)))])
			end
			title(['Wo1 = ' num2str(Wo1) ' , No1 = ' num2str(No1,6)])
		end

		%Plotting RTF Data 
		if exist(RTFFile)
			subplot(3.5,2,3)
			pcolor(Fm,RD,RTF1),shading flat, colormap jet,...
			axis([min(Fm) max(Fm) 0 max(RD) ])
			hold on
			plot(BestFm1,BestRD1,'ko','linewidth',5)
			hold off
			title(['Sound = ' Sound ' , SModType = ' SModType])

			subplot(3.5,2,4)
			pcolor(Fm,RD,RTF2),shading flat, colormap jet,...
			axis([min(Fm) max(Fm) 0 max(RD) ])
			hold on
			plot(BestFm2,BestRD2,'ko','linewidth',5)
			hold off
		end

	end

	%Loading RTF Hist Data
	index=findstr(['dB.mat'],Lst(ListNum,:));
	if isempty(index)
		index=findstr(['Lin.mat'],Lst(ListNum,:));
	end
	RTFHistFile=[ Lst(ListNum,1:index-1) 'RTFHist.mat'];
	if exist(RTFHistFile)
		f=['load ' RTFHistFile];
		eval(f);

		%Changing from stimulus parameter to transfer 
		%function space
		FM=-FM;
	end

	%Plotting RTF Hist Data
	if exist(RTFHistFile)

		subplot(3.5,2,5)
		[N1s,T1,T2]=rtfhstat(N1,0.01);
		[i,j]=find(round(N1s*100)==round(100*(T1+T2)/2));
		for k=1:length(i)
			N1s(i(k),j(k))=-inf;
		end
		pcolor(FM-(FM(2)-FM(1))/2,RD-(RD(2)-RD(1))/2,N1s)
		pcolor(FM,RD,N1s)
		axis([min(FM) max(FM) 0 max(RD) ])
		caxis([(T1+T2)-max(max(N1)) max(max(N1))])
		hold on
		plot(BestFm1s,BestRD1s,'ko','linewidth',5)
		hold off

		subplot(3.5,2,6)
		[N2s,T1,T2]=rtfhstat(N2,0.01);
		[i,j]=find(round(N2s*100)==round(100*(T1+T2)/2));
		for k=1:length(i)
			N2s(i(k),j(k))=-inf;
		end
		pcolor(FM-(FM(2)-FM(1))/2,RD-(RD(2)-RD(1))/2,N2s)
		pcolor(FM,RD,N2s)
		axis([min(FM) max(FM) 0 max(RD) ])
		caxis([(T1+T2)-max(max(N2)) max(max(N2))])
		hold on
		plot(BestFm2s,BestRD2s,'ko','linewidth',5)
		hold off

		%Colormap 
		color=jet(64);
		color(1,:)=[0 0 0];
		colormap(color)
	else

		subplot(3.5,2,5)
		cla
		set(gca,'Visible','off')
		subplot(3.5,2,6)
		cla
		set(gca,'Visible','off')
	end

	%Plotting Spike Data
	if exist(SpikeFile)
		f=['load ' SpikeFile];
		eval(f)

		%Checking to See if Spike Data Exist
		if exist(['ModelWave' int2str(UnitNumber)])
			subplot(7,2,13)
			f=['SpikeWave=SpikeWave' int2str(UnitNumber) ';'];
			eval(f)
			f=['ModelWave=ModelWave' int2str(UnitNumber) ';'];
			eval(f)

			N=floor(length(SpikeWave)/2);
			plot((-N:N)/Fs*1000,invert*SpikeWave/1024/32,'b');
			hold on
			plot(Time,ModelWave/1024/32,'r','linewidth',1)
			T1=min([Time -N/Fs*100]);
			T2=max([Time N/Fs*100]);
			axis([T1 T2 -1 1])
			xlabel('Time (msec)')
			hold off
		end
	end

	%Setting Mouse Pointer to Arrow
	set(gcf,'Pointer','arrow');

elseif strcmp(action,'ChangeHeader')

	ExpHeader=get(gco,'String');
	set(gco,'String',ExpHeader);
	set(gcf,'Pointer','watch');
	pause(1)
	set(gcf,'Pointer','arrow');

elseif strcmp(action,'InvertSpike')

	%Inverting
	v=get(gco,'value');
	if v==1
		invert=-1;
		rtfanaltool('PlotAll');
	elseif v==0
		invert=1;
		rtfanaltool('PlotAll');
	end

elseif strcmp(action,'LoadHeader')

	%Loading Data
	filename=[ExpHeader '_STATS.mat'];
	if exist(filename)

		%Load File
		f=['load ' filename];
		eval(f);
		
                %Plot Data
                f=[GLOBAL ',rtfanaltool(''PlotAll'')'];
                eval(f);

	else
		clc
		disp('Sorry: File Does Not Exist :-(');
	end

elseif strcmp(action,'SaveHeader')

	%Saving Data
	if strcmp(version,'4.2c')
		f=['save ' ExpHeader '_STATS.mat ' SaveVar];
		eval(f);	
	else
		f=['save ' ExpHeader '_STATS.mat ' SaveVar ' -v4'];
		eval(f);	
	end

elseif strcmp(action,'ChangeBFMRD1')

	%If choosing from RTF
	if strcmp(RTFType,'RTF')
		%Obtaining Input values from RTF1
		subplot(3.5,2,3)
		[BestFm,BestRD]=ginput(1);

		if BestFm>=0
			BestFm1r(2)=BestFm;
			BestRD1r(2)=BestRD;
		else
			BestFm1r(1)=BestFm;
			BestRD1r(1)=BestRD;
		end

	%If choosing from RTFH
	elseif strcmp(RTFType,'RTFH')
		%Obtaining Input values from RTFH1
		subplot(3.5,2,5)
		[BestFm,BestRD]=ginput(1);

		if BestFm>=0
			BestFm1h(2)=BestFm;
			BestRD1h(2)=BestRD;
		else
			BestFm1h(1)=BestFm;
			BestRD1h(1)=BestRD;
		end
	end

	%Plotting Best RD and FM
	subplot(3.5,2,3)
	hold on
	plot(BestFm,BestRD,'ko','linewidth',3)
	hold off
	subplot(3.5,2,5)
	hold on
	plot(BestFm,BestRD,'ko','linewidth',3)
	title(['BFM=' int2str(BestFm) '     BRD=' num2str(BestRD,2)])
	hold off

elseif strcmp(action,'ChangeBFMRD2')

	%If choosing from RTF
	if strcmp(RTFType,'RTF')
		%Obtaining Input values from RTF1
		subplot(3.5,2,4)
		[BestFm,BestRD]=ginput(1);

		if BestFm>=0
			BestFm2r(2)=BestFm;
			BestRD2r(2)=BestRD;
		else
			BestFm2r(1)=BestFm;
			BestRD2r(1)=BestRD;
		end

	%If choosing from RTFH
	elseif strcmp(RTFType,'RTFH')
		%Obtaining Input values from RTFH2
		subplot(3.5,2,6)
		[BestFm,BestRD]=ginput(1);

		if BestFm>=0
			BestFm2h(2)=BestFm;
			BestRD2h(2)=BestRD;
		else
			BestFm2h(1)=BestFm;
			BestRD2h(1)=BestRD;
		end
	end

	%Plotting Best RD and FM
	subplot(3.5,2,4)
	hold on
	plot(BestFm,BestRD,'ko','linewidth',3)
	hold off
	subplot(3.5,2,6)
	hold on
	plot(BestFm,BestRD,'ko','linewidth',3)
	title(['BFM=' int2str(BestFm) '     BRD=' num2str(BestRD,2)])
	hold off

elseif strcmp(action,'ChangeRTFType')

	v=get(gco,'value')
	if v==1
		RTFType='RTFH';
	else
		RTFType='RTF';
	end

elseif strcmp(action,'ChangeNoise')

	v=get(gco,'value')
	if v==1
		Noise='n';
	else
		Noise='y';
	end
	f=['rtfanaltool(''PlotAll'')'];
	eval(f)

elseif strcmp(action,'ChangeStrf1')

	%Simple Type
	v=get(gco,'value');
	if v==1
		StrfType(1)=1;
	elseif v==0
		StrfType(1)=0;
	end

elseif strcmp(action,'ChangeStrf2')

	%Complex Type
	v=get(gco,'value');
	if v==1
		StrfType(2)=1;
	elseif v==0
		StrfType(2)=0;
	end

elseif strcmp(action,'ChangeStrf3')

	%Broad Type
	v=get(gco,'value');
	if v==1
		StrfType(3)=1;
	elseif v==0
		StrfType(3)=0;
	end

elseif strcmp(action,'ChangeStrf4')

	%Oblique Type
	v=get(gco,'value');
	if v==1
		StrfType(4)=1;
	elseif v==0
		StrfType(4)=0;
	end

elseif strcmp(action,'ChangeStrf5')

	%Multi Type
	v=get(gco,'value');
	if v==1
		StrfType(5)=1;
	elseif v==0
		StrfType(5)=0;
	end

elseif strcmp(action,'ChangeStrf6')

	%Other Type
	v=get(gco,'value');
	if v==1
		StrfType(6)=1;
	elseif v==0
		StrfType(6)=0;
	end

elseif strcmp(action,'ChangeSelectivity')

	%Selectivity Type
	v=get(gco,'value');
	if v==1
		Selectivity=[1 0 0];
	elseif v==2
		Selectivity=[0 1 0];
	elseif v==3
		Selectivity=[0 0 1];
	end

elseif strcmp(action,'ChangeTemporal1')

	%Low-Pass
	v=get(gco,'value');
	if v==1
		TempFiltType(1)=1;
		TempFiltType(2)=0;
		set(TempBandHndl,'value',0);
	elseif v==0
		TempFiltType(1)=0;
		TempFiltType(2)=1;
		set(TempBandHndl,'value',1);
	end
	
elseif strcmp(action,'ChangeTemporal2')

	%Band-Pass
	v=get(gco,'value');
	if v==1
		TempFiltType(1)=0;
		TempFiltType(2)=1;
		set(TempLowHndl,'value',0);
	elseif v==0
		TempFiltType(1)=1;
		TempFiltType(2)=0;
		set(TempLowHndl,'value',1);
	end
	
elseif strcmp(action,'ChangeTemporal3')

	%Diffused
	v=get(gco,'value');
	if v==1
		TempFiltType(3)=1;
	elseif v==0
		TempFiltType(3)=0;
	end
	
elseif strcmp(action,'ChangeSpectral1')

	%Low Pass	
	v=get(gco,'value');
	if v==1
		SpecFiltType(1)=1;
		SpecFiltType(2)=0;
		set(SpecBandHndl,'value',0);
	elseif v==0
		SpecFiltType(1)=0;
		SpecFiltType(2)=1;
		set(SpecBandHndl,'value',1);
	end

elseif strcmp(action,'ChangeSpectral2')

	%Band Pass	
	v=get(gco,'value');
	if v==1
		SpecFiltType(1)=0;
		SpecFiltType(2)=1;
		set(SpecLowHndl,'value',0);
	elseif v==0
		SpecFiltType(1)=1;
		SpecFiltType(2)=0;
		set(SpecLowHndl,'value',1);
	end

elseif strcmp(action,'ChangeSpectral3')

	%Diffused
	v=get(gco,'value');
	if v==1
		SpecFiltType(3)=1;
	elseif v==0
		SpecFiltType(3)=0;
	end

elseif strcmp(action,'ChangeUnit1')

	%Single Unit
	v=get(gco,'value');
	if v==1
		UType(1)=1;
		UType(2)=0;
		set(MultiHndl,'value',0);
	elseif v==0
		UType(1)=0;
		UType(2)=1;
		set(MultiHndl,'value',1);
	end

elseif strcmp(action,'ChangeUnit2')

	%Multi Unit
	v=get(gco,'value');
	if v==1
		UType(1)=0;
		UType(2)=1;
		set(SingleHndl,'value',0);
	elseif v==0
		UType(1)=1;
		UType(2)=0;
		set(SingleHndl,'value',1);
	end

elseif strcmp(action,'Next')

	%Incrementing List Number
	ListNum=ListNum+1;

	%Reseting GINPUT Flags
	BestFm1r=[-9999 -9999];		%Flag Indicates Not Active
	BestFm2r=[-9999 -9999];		%Flag Indicates Not Active
	BestRD1r=[-9999 -9999];		%Flag Indicates Not Active
	BestRD2r=[-9999 -9999];		%Flag Indicates Not Active
	BestFm1h=[-9999 -9999];		%Flag Indicates Not Active
	BestFm2h=[-9999 -9999];		%Flag Indicates Not Active
	BestRD1h=[-9999 -9999];		%Flag Indicates Not Active
	BestRD2h=[-9999 -9999];		%Flag Indicates Not Active

	%Replotting
	f=['rtfanaltool(''PlotAll'')'];
	eval(f)

elseif strcmp(action,'Prev'),

	%Decrementing List Number
	ListNum=ListNum-1;

	%Reseting GINPUT Flags
	BestFm1r=[-9999 -9999];		%Flag Indicates Not Active
	BestFm2r=[-9999 -9999];		%Flag Indicates Not Active
	BestRD1r=[-9999 -9999];		%Flag Indicates Not Active
	BestRD2r=[-9999 -9999];		%Flag Indicates Not Active
	BestFm1h=[-9999 -9999];		%Flag Indicates Not Active
	BestFm2h=[-9999 -9999];		%Flag Indicates Not Active
	BestRD1h=[-9999 -9999];		%Flag Indicates Not Active
	BestRD2h=[-9999 -9999];		%Flag Indicates Not Active

	%Replotting
	f=['rtfanaltool(''PlotAll'')'];
	eval(f)

elseif strcmp(action,'Accept'),

	%Set All Parameters
	BFm1(ListNum)=tocomplex(BestFm1s);
	BRD1(ListNum)=tocomplex(BestRD1s);
	BFm1RTF(ListNum,:)=BestFm1r;
	BRD1RTF(ListNum,:)=BestRD1r;
	BFm1RTFH(ListNum,:)=BestFm1h;
	BRD1RTFH(ListNum,:)=BestRD1h;

	BFm2(ListNum)=tocomplex(BestFm2s);
	BRD2(ListNum)=tocomplex(BestRD2s);
	BFm2RTF(ListNum,:)=BestFm2r;
	BRD2RTF(ListNum,:)=BestRD2r;
	BFm2RTFH(ListNum,:)=BestFm2h;
	BRD2RTFH(ListNum,:)=BestRD2h;

	STRFType(ListNum,:)=StrfType;
	TemporalType(ListNum,:)=TempFiltType;
	SpectralType(ListNum,:)=SpecFiltType;
	UnitType(ListNum,:)=UType;
	SELECTIVITY(ListNum,:)=Selectivity;

	%Reseting GINPUT Flags
	BestFm1r=[-9999 -9999];		%Flag Indicates Not Active
	BestFm2r=[-9999 -9999];		%Flag Indicates Not Active
	BestRD1r=[-9999 -9999];		%Flag Indicates Not Active
	BestRD2r=[-9999 -9999];		%Flag Indicates Not Active
	BestFm1h=[-9999 -9999];		%Flag Indicates Not Active
	BestFm2h=[-9999 -9999];		%Flag Indicates Not Active
	BestRD1h=[-9999 -9999];		%Flag Indicates Not Active
	BestRD2h=[-9999 -9999];		%Flag Indicates Not Active

	%Go On To the Next Unit
	rtfanaltool('Next');
		
elseif strcmp(action,'Quit'),

	close
	clc
	disp('Goodbye !!!')

else
	disp(sprintf( ...
	'RTFANALTOOL: action string ''%s'' not recognized, no action taken.',action))
end

