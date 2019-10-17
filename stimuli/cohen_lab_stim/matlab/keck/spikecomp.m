%
%function []=spikecomp(SpikeFile1,SpikeFile2,T1,T2,L,inverts,invertm)
%
%       FILE NAME       : SPIKE COMP
%       DESCRIPTION     : Compares all of the Spike Waveforms by computing 
%			  the mean corrcoeff across all waveforms
%	
%	SpikeFile1	: Spike File 1
%	SpikeFile2	: Spike File 2
%	T1, T2		: Delay used to compute corrcoef -> [T1 T2] (msec)
%	L		: Number of spike waveforms to use for corrcoef
%	inverts		: Inverts the Spike Waveform
%			  'y' or 'n', Default='n'
%	invertm		: Inverts the Model Waveform
%			  'y' or 'n', Default='n'
%
function []=spikecomp(SpikeFile1,SpikeFile2,T1,T2,L,inverts,invertm)

%Input Arguments
if nargin==1
	action=SpikeFile1;
else
	%Cleaaring Global Variables
	clear global;

	%Finding Header
	index=findstr('_f',SpikeFile1);
	Header=SpikeFile1(1:index-3);
end
if nargin<6
	inverts='n';
end
if nargin<7
	invertm='n';
end

%Setting Global Variables
GLOBAL='global B File1 File2 Header;';
eval(GLOBAL);

%Setting Up and Plotting Correlation Matrix and Spikes
if nargin>1

	%Loading 1st Input Files
	f=['load ' SpikeFile1];
	eval(f);

	%Finding All Non-Outlier Spet Variables
	count=-1;
	while exist(['spet' int2str(count+1)])
	count=count+1;
	end
	Nspet1=(count+1)/2;

	%Loading 2nd Input Files
	for k=0:2*Nspet1-1
		f=['clear spet' int2str(k) ';'];
		eval(f)
	end
	f=['load ' SpikeFile2];
	eval(f);

	%Finding All Non-Outlier Spet Variables
	count=-1;
	while exist(['spet' int2str(count+1)])
		count=count+1;
	end
	Nspet2=(count+1)/2;

	%Finding Correlation Matrix
	R=zeros(Nspet1,Nspet2);
	P=zeros(Nspet1,Nspet2);
	for j=0:Nspet1-1
		for k=0:Nspet2-1
			if exist('L')
				[R(j+1,k+1),P(j+1,k+1)]=...
				spikecorrcoef(SpikeFile1,SpikeFile2,j,k,T1,T2,L);
			else
				[R(j+1,k+1),P(j+1,k+1)]=...
				spikecorrcoef(SpikeFile1,SpikeFile2,j,k,T1,T2);
			end
		end
	end

	%Setting Figure and PaperPosition
	fighandle=figure('Name',...
	        'Correlation of Spikes ',...
	        'NumberTitle','off');
	set(fighandle,'position',[600,20,300,280],'paperposition',...
	        [.25 1.5 8 8.5]);

	%Plotting Correlation Data
	imagesc(0:Nspet2-1,0:Nspet1-1,round(R*100)),colormap jet
	xlabel(SpikeFile2)
	ylabel(SpikeFile1)
	set(gca,'XTick',[0:Nspet2-1])
	set(gca,'YTick',[0:Nspet1-1])
	set(gca,'Ydir','normal');

	%Writing Numerical Values
	for j=1:Nspet1
		for k=1:Nspet2
			text(k-1+.1,j-1+.3,int2str(round(R(j,k)*100)));
			text(k-1+.1,j-1-.3,int2str(round(P(j,k)*100)));
		end
	end

	%Plotting Buttons
	NB1=size(R,1);
	NB2=size(R,2);
	B=zeros(NB1,NB2);
	dN1=(.93-.12)/Nspet1;
	dN2=(.9-.13)/Nspet2;
	for j=0:Nspet1-1
		for k=0:Nspet2-1

		btnPos=[.13+dN2*k .11+dN1*j .05 .05];
		labelStr='';
		callbackStr=[GLOBAL ',',...
		'if ~exist(' '''B''' '), B=zeros(' int2str(NB1),...
		',' int2str(NB2) ');, end, v=get(gco,' '''value''' ');,',...
		'if v==1, B(' int2str(j+1) ',' int2str(k+1) ')=1;, else, ',...
		'B(' int2str(j+1) ',' int2str(k+1) ')=0;, end,',...
		'File1=' ''''  SpikeFile1 '''' ';, File2=',...
		 '''' SpikeFile2 '''' ';'];

		uicontrol( ...
		'Style','checkbox', ...
		'Units','Normalized',...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Value',0, ...
		'Callback',callbackStr);

		end
	end

	%The Accept Buttton
	btnPos=[.01 .01 .2 .05];
	labelStr='Accept';
	callbackStr=['spikecomp(' '''accept''' ')'];
	AcceptHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%The Delete Buttton
	btnPos=[.8 .01 .2 .05];
	labelStr='Delete';
	callbackStr=['spikecomp(' '''delete''' ')'];
	DeleteHndl=uicontrol( ...
		'Style','pushbutton', ...
		'Units','normalized', ...
		'Position',btnPos, ...
		'String',labelStr, ...
		'Callback',callbackStr);

	%Plotting Spike Waveforms
	[fighandel1]=plotspikes(SpikeFile1,[T1 T2],inverts,invertm);
	[fighandel2]=plotspikes(SpikeFile2,[T1 T2],inverts,invertm);
	set(fighandel1,'Name',SpikeFile1,'position',[0 334 512 384])
	set(fighandel2,'Name',SpikeFile2)
end

%Accepting the Data
if strcmp(action,'accept')
	
	OutFile=[Header '_SpikeComp.mat'];
	if exist(OutFile)

		%Loading the Output File
		f=['load ' OutFile];
		eval(f);

		%Decoding B Matrix for Corresponding Units
		Units=[];
		for j=1:size(B,1)

			%Initializing Units for File2 and File1
			Unit2=find(B(j,:)==1);
			Unit1=[];

			%For first Row in B only
			if sum(Unit2)>0 & j==1
				Unit1=j;
				for k=j+1:size(B(:,1))

					%Finding Units for File1
					if mean(B(j,:)==B(k,:))==1
						Unit1=[Unit1 k];
					end

				end

			%All other Rows in B
			elseif sum(Unit2)>0 & sum(B(1:j-1,:)*B(j,:)')==0
				Unit1=j;
				for k=j+1:size(B(:,1))

					%Finding Units for File1
					if mean(B(j,:)==B(k,:))==1
						Unit1=[Unit1 k];
					end
				end
			end
		
			%These are the corresponding Units	
			if length(Unit1)>0

				%Units for File1
				for m=1:length(Unit1)
				Units=[Units 'u' int2str(Unit1(m)-1) '+'];
				end
				Units=[Units(1:length(Units)-1) '='];

				%Units for File2
				for m=1:length(Unit2)
				Units=[Units 'u' int2str(Unit2(m)-1) '+'];
				end

				%Putting Marker ;
				Units=[Units(1:length(Units)-1) ';'];

			end

		end

		%Appending Blank Spaces to Units Variable
		Units=...
		[Units zeros(1,150-length(Units))];

		%Appending Data
		File1=[File1 zeros(1,50-length(File1))];
		File2=[File2 zeros(1,50-length(File2))];
		FileList1=[FileList1;File1];
		FileList2=[FileList2;File2];
		UnitList=[UnitList;Units];

		%Saving the Data 
		disp(['Stored Units: ' Units])
		f=['save ' OutFile ' FileList1 FileList2 UnitList '];
		if ~strcmp(version,'4.2c')
			f=[f ' -v4'];
		end
		eval(f);

	else

		%Decoding B Matrix for Corresponding Units
		Units=[];
		for j=1:size(B,1)

			%Initializing Units for File2 and File1
			Unit2=find(B(j,:)==1);
			Unit1=[];

			%For first Row in B only
			if sum(Unit2)>0 & j==1
				Unit1=j;
				for k=j+1:size(B(:,1))

					%Finding Units for File1
					if mean(B(j,:)==B(k,:))==1
						Unit1=[Unit1 k];
					end

				end

			%All other Rows in B
			elseif sum(Unit2)>0 & sum(B(1:j-1,:)*B(j,:)')==0
				Unit1=j;
				for k=j+1:size(B(:,1))

					%Finding Units for File1
					if mean(B(j,:)==B(k,:))==1
						Unit1=[Unit1 k];
					end
				end
			end
		
			%These are the corresponding Units	
			if length(Unit1)>0

				%Units for File1
				for m=1:length(Unit1)
				Units=[Units 'u' int2str(Unit1(m)-1) '+'];
				end
				Units=[Units(1:length(Units)-1) '='];

				%Units for File2
				for m=1:length(Unit2)
				Units=[Units 'u' int2str(Unit2(m)-1) '+'];
				end

				%Putting Marker ;
				Units=[Units(1:length(Units)-1) ';'];

			end

		end

		%Appending Blank Spaces to Units Variable
		Units=...
		[Units zeros(1,150-length(Units))];

		%Appending Data
		FileList1=zeros(1,50);
		FileList2=zeros(1,50);
		FileList1(1:length(File1))=File1;
		FileList2(1:length(File2))=File2;
		UnitList=Units;

		%Saving the Data 
		disp(['Stored Units: ' Units])
		f=['save ' OutFile ' FileList1 FileList2 UnitList '];
		if ~strcmp(version,'4.2c')
			f=[f ' -v4'];
		end
		eval(f);
		
	end

end

%Deleting the Last Data Element added to OutFile
if strcmp(action,'delete')

	%Loading Output File
	OutFile=[Header '_SpikeComp.mat'];
	f=['load ' OutFile ];
	eval(f);

	%Deleting Last Elements Added
	FileList1=FileList1(1:size(FileList1,1)-1,:);
	FileList2=FileList2(1:size(FileList2,1)-1,:);
	UnitList=UnitList(1:size(UnitList,1)-1,:);

	%Saving File
	f=['save ' OutFile ' FileList1 FileList2 UnitList '];
	if ~strcmp(version,'4.2c')
		f=[f ' -v4'];
	end
	eval(f);
end
