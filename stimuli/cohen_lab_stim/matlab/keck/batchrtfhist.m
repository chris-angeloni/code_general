%
%function []=batchrtfhist(Header,Channel,paramfile,BatchFile,NFM,NRD,FMMax,RDMax,T,Xc)
%
%       FILE NAME       : BATCH RTF HIST
%       DESCRIPTION     : Btch Mode RTFHist for all Moving Ripple Units
%
%	Header		: File Header
%	Channel		: Array of Channel Numbers to Perform Analaysis
%	paramfile	: Moving Ripple Parameter File
%	BatchFile	: Contains Experiment Data for all Sounds
%	NFM		: Number of bins used for Fm axis
%	NRD		: Number of bins used for RD axis
%	FMMax		: Maximum Temporal Modulation (Default = 350)
%	RDMax		: Maximum Ripple Density (Default = 4)
%	T		: Time Preceeding a Spike to Find RD
%			  and FM parameters
%			  Optional : Default : T=0
%			  Does not seem to make a difference !!!
%	Xc		: Octave center frequency used to remove RD dependendy
%			  on Fm
%			  Optional : Default = log2(MaxRD/MinRD)/2
%			  ( at center of spectro-temporal envelope to
%			  minimize RMS error )
%
%			  Note that: FM = RD' * Xc + FMd
%			  Where FMd is the desired FM profile and Xc is
%			  presumably the CF of the neuron in octaves
%
%	Batch File should be tab delimited and arranged colum-wise 
%	with the Following information
%
%	tapenum	filenum	SPL	MdB	Sound	SModType  Experiment
%-----------------------------------------------------------------
%Eg.	3	23	60	30	RN	dB	    RF
%	4	12	50	30	MR	lin	    RF
%	2	23	40	40	MR		    PRE
%	4	15	50				    TC
%	4	17					    BAD
%
function []=batchrtfhist(Header,Channel,paramfile,BatchFile,NFM,NRD,FMMax,RDMax,T,Xc)

%Input Arguments
if nargin<7
	FMMax=350;
end
if nargin<8
	RDMax=4;
end
if nargin<9
	T=0;
end
if nargin<10
	Xc=log2(20/.5)/2;
end

%Preliminaries
more off
clc

%Getting Batch Data
ch=setstr(39);
fid=fopen(BatchFile);
List=fread(fid,inf,'uchar')';
List=[10 List 10];
returnindex=find(List==10);
for j=1:length(Channel)
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
		Param=setstr(Param);
	
		if length(tabindex)==6 & ~isempty(findstr('RF',Param(7,:))) & findstr(Param(5,:),'MR')
	
				%File Number
				if str2num(Param(2,:))<10
					File=['0' int2str(str2num(Param(2,:)))];
				else
					File=[int2str(str2num(Param(2,:)))];
				end
	
				%Tape Number
				if str2num(Param(2,:))<10
					Tape=['0' int2str(str2num(Param(1,:)))];
				else
					Tape=[int2str(str2num(Param(1,:)))];
				end
	
				%Loading SPET File
				f=['load '  Header 't' int2str(str2num(Param(1,:))) '_f' File '_ch' int2str(Channel(j))];
				eval(f);
	
				%Loading TRIG File
				f=['load '  Header 't' int2str(str2num(Param(1,:))) '_f' File '_Trig'];
				eval(f);
	
				%Finding All Non-Outlier spet
				count=-1;
				while exist(['spet' int2str(count+1)])
					count=count+1;
				end
				Nspet=(count+1)/2;
	
				%Running RTFHist on all SPET Files
				SaveCommand=[];
				ch=setstr(39);
				for l=0:Nspet-1
					%Renaming SPET
					f=['spet=spet' int2str(l) ';'];
					eval(f)
	
					%Display
					clc
					disp(['Evaluating RTF Histogram: Tape ' Tape ' File ' File ' Channel ',...
					int2str(Channel(j)) ' Unit ' int2str(l)])
	
					%Evaluating RTFHist
					if nargin<10
						f=['[RD1,FM1,RD2,FM2,Time1,Time2]=rtfhist(' ch paramfile ch ',spet,Trig,Fs,T);'];
					else
						f=['[RD1,FM1,RD2,FM2,Time1,Time2]=rtfhist(' ch paramfile ch ',spet,Trig,Fs,T,Xc);'];
					end				
					eval(f);
	
					%Generating Histograms
					MFM=2*FMMax*((0:NFM-1)/NFM+1/NFM/2-.5);
					MRD=RDMax*((0:NFM-1)/NFM+1/NFM/2);
					[FM,RD,N1]=hist2(FM1,RD1,MFM,MRD);
					[FM,RD,N2]=hist2(FM2,RD2,MFM,MRD);
					[FM,FM,NFM12]=hist2(FM1,FM2,MFM,MFM);
					[RD,RD,NRD12]=hist2(RD1,RD2,MRD,MRD);
	
					%Save Command
					SaveCommand=[' RD1 FM1 RD2 FM2 Time1 Time2 RD FM N1 N2 NFM12 NRD12 T NRD NFM RDMax FMMax' ];
					if nargin==10
						SaveCommand=[SaveCommand ' Xc'];
					end	
	
					%Saving File
					if strcmp(version,'4.2c')
						f=['save ' Header 't' int2str(str2num(Param(1,:))) ,...
						'_f' File '_ch' int2str(Channel(j)) '_u' int2str(l) '_RTFHist' SaveCommand ];
					else
						f=['save ' Header 't' int2str(str2num(Param(1,:))) , ...
						'_f' File '_ch' int2str(Channel(j)) '_u' int2str(l) '_RTFHist' SaveCommand ' -v4'];
					end	
					eval(f);
	
				end
	
				%Removing All Spet Variables
				count=-1;
				while exist(['spet' int2str(count+1)])
					f=['clear spet' int2str(count+1)];
					eval(f)
					count=count+1;
				end
	
		end
	
	end
end
