%
%function []=trigbatchall(Header,BatchFile,Fs,TCChan,SoundChan,NdoubleMR,NtrigMR,NdoubleRN,NtrigRN)
%
%       FILE NAME       : TRIG BATCH ALL
%       DESCRIPTION     : Batch file to obtain triggers for all analysis types
%
%	Header		: Input RAW file Header
%	BatchFile	: Contains Experiment Data for all Sounds
%			  Presentations
%	Fs		: Sampling Rate for Trigger RAW File
%	TCChan		: Tunning Curve Trigger Channel
%	SoundChan	: Trigger Channel for all other sounds
%			  MR, RN, PRE, ALL ...
%	NdoubleMR	: Number of blocks between double triggers for MR
%	NTrigMR		: Number of triggers for MR
%	NdoubleRN	: Number of blocks between double triggers for RN
%	NTrigRN		: Number of triggers for RN
%
%	Batch File should be tab delimited and arranged colum-wise 
%	with the Following information
%
%	tapenum	filenum	SPL	MdB	Sound	SModType  Experiment
%-----------------------------------------------------------------
%Eg.	3	23	60	30	RN	dB	    RF
%	4	12	50	30	MR	lin	    RF
%	4	15	50	30	MR	lin	    RF2
%	2	23	40	40	MR		    PRE
%	5	12	55		RN		    ALL
%	4	15	50				    TC
%	4	17					    BAD
%	5	23					    SPO
%
function []=trigbatchall(Header,BatchFile,Fs,TCChan,SoundChan,NdoubleMR,NtrigMR,NdoubleRN,NtrigRN)

%Preliminaries
more off

%Matlab Version
if findstr(version,'4.2c')
	VERSION=' ';
else
	VERSION=' -v4 ';
end

%Getting Batch Data
ch=setstr(39);
fid=fopen(BatchFile);
List=fread(fid,inf,'uchar')';
List=[10 List 10];
List=setstr(List);
returnindex=find(List==10);
for l=1:length(returnindex)-1
	CurrentList=List(returnindex(l)+1:returnindex(l+1)-1);
	tabindex=find(CurrentList==9);
	Param=setstr(ones(7,5)*32);
	if length(tabindex)==6
		for k=1:7
			if k==1
				n=1:tabindex(k)-1;
				Param(k,n)=CurrentList(n);
			elseif k==7
				n=tabindex(k-1):length(CurrentList);
				Param(k,1:length(n))=CurrentList(n);
			else
				n=tabindex(k-1)+1:tabindex(k)-1;
				Param(k,1:length(n))=CurrentList(n);
			end
		end
	end

	%Generating Input Filename
	TapeNum=str2num(Param(1,:));
	FileNum=str2num(Param(2,:));
	if findstr('TC',Param(7,:))
		Chan=num2str(TCChan);
	else
		Chan=num2str(SoundChan);
	end
	if FileNum<10
		filename=[Header 't' int2str(TapeNum) '_f0' int2str(FileNum) '_ch' Chan '_b1.raw' ];
	else
		filename=[Header 't' int2str(TapeNum) '_f' int2str(FileNum) '_ch' Chan '_b1.raw' ];
	end

	%Finding and Fixing Triggers - if Param(7,:) == 'SPO' 
	%file will not exist and it won't Find Triggers
	if exist(filename) & isempty(findstr(Param(7,:),'BAD'))

		%Displaying Output
		clc
		disp(['Extracting Trigeers for : ' filename])
	
		%Finding Triggers for MR and RN STRFs
		if ~isempty(findstr('RF',Param(7,:))) & isempty(findstr('RF2',Param(7,:)))
			TrigTimes=trigfind(filename,Fs);
			if findstr(Param(5,:),'MR')
				Trig=trigfixstrf(TrigTimes,NdoubleMR,NtrigMR);
			else
				Trig=trigfixstrf(TrigTimes,NdoubleRN,NtrigRN);
			end
		end

		%Finding Triggers for double presentation of MR and RN STRFs
		if ~isempty(findstr('RF2',Param(7,:)))
			TrigTimes=trigfind(filename,Fs);
			if findstr(Param(5,:),'MR')
				[TrigA,TrigB]=trigfixstrf2(TrigTimes,NdoubleMR,NtrigMR);
			else
				[TrigA,TrigB]=trigfixstrf2(TrigTimes,NdoubleRN,NtrigRN);
			end
		end

		%Finding Triggers for Prediction
		if ~isempty(findstr('PRE',Param(7,:)))
			TrigTimes=trigfind(filename,Fs);
			Trig=trigpsth(TrigTimes,Fs,.4);
		end
	
		%Finding Triggers for dB vs. SPL
		if ~isempty(findstr('ALL',Param(7,:)))
			TrigTimes=trigfind(filename,Fs);
			[Trig2,Trig3]=trigfixdbvsspl(TrigTimes,Fs);
		end

		%Finding Triggersn for TC
		if ~isempty(findstr('TC',Param(7,:)))
			TrigTimes=trigfind(filename,Fs);
			Trig=TrigTimes;
		end

		%Saving Data
		index=findstr(filename,'_ch');
		trigfile=[filename(1:index-1) '_Trig'];
		if ~isempty(findstr('ALL',Param(7,:)))
			f=['save ' trigfile ' Trig2 Trig3 TrigTimes Fs ' VERSION];
		elseif ~isempty(findstr('RF2',Param(7,:)))
			f=['save ' trigfile ' TrigA TrigB TrigTimes Fs ' VERSION];

		else
			f=['save ' trigfile ' Trig TrigTimes Fs ' VERSION];
		end 
		eval(f);
		disp(f);
	end
end
