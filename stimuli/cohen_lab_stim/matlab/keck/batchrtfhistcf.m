%
%function []=batchrtfhistcf(Header,Channel,paramfile,BatchFile,NFM,NRD,FMMax,RDMax,FileList,TT,XC)
%
%       FILE NAME       : BATCH RTF HIST CF
%       DESCRIPTION     : Btch Mode RTFHist for all Moving Ripple Units
%			  Uses CF Data obtained using the CFDATA tool to 
%			  compute the RTFH
%
%	Header		: File Header
%	Channel		: Array of Channel Numbers to Perform Analaysis
%	paramfile	: Moving Ripple Parameter File
%	BatchFile	: Contains Experiment Data for all Sounds
%	NFM		: Number of bins used for Fm axis
%	NRD		: Number of bins used for RD axis
%	FMMax		: Maximum Temporal Modulation (Default = 350)
%	RDMax		: Maximum Ripple Density (Default = 4)
%	FileList	: File List of files to comput RTFH
%	TT		: Array of Times Preceeding a Spike to Find RD
%			  and FM parameters - elements must correspond to 
%			  those in FileList.  If TT has two element rows 
%			  the values of T(1) corresponds to the delay for 
%			  STRFs obtained from sound channel 1 and T(2) likewise
%			  correponds to the delay for STRFs obtained from 
%			  sound channel 2
%
%	XC		: Array of Octave center frequencies used to remove RD 
%			  dependency on Fm - elements in a column must correspond to 
%			  those in FileList.  If XC has two elemnt rows 
%			  the values of XC(1) corresponds to those used to correct FM 
%			  for sound channel 1 and XC(2) corresponds to the elements
%			  used to correct FM for sound channel 2
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
function []=batchrtfhistcf(Header,Channel,paramfile,BatchFile,NFM,NRD,FMMax,RDMax,FileList,TT,XC)

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
	for k=1:length(returnindex)-1
		CurrentList=List(returnindex(k)+1:returnindex(k+1)-1);
		tabindex=find(CurrentList==9);
		Param=setstr(ones(7,5)*32);
		if length(tabindex)==6
			for l=1:7
				if l==1
					n=1:tabindex(l)-1;
					Param(l,n)=CurrentList(n);
				elseif l==7
					n=tabindex(l-1):length(CurrentList);
					Param(l,1:length(n))=CurrentList(n);
				else
					n=tabindex(l-1)+1:tabindex(l)-1;
					Param(l,1:length(n))=CurrentList(n);
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
				InFile=[Header 't' int2str(str2num(Param(1,:))) '_f' File '_ch' int2str(Channel(j))];
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

					%Finding XC and T from FileList
					Xc=-9999;
					T=-9999;
					for m=1:length(FileList)
	
						%Extracting Filename and unit number
						index=findstr(FileList(m,:),'_u');
						SpetFile=[FileList(m,1:index-1) ];
						unit=str2num(FileList(m,index+2));

						%Checking to see if match between SpetFile and Input File from BATCH
						if strcmp(SpetFile,InFile) & l==unit

							if length(XC(m,:))==1
								Xc=XC(m);
							else
								if XC(m,1)==-9999
									Xc=XC(m,2);
								elseif XC(m,2)==-9999
									Xc=XC(m,1);
								else
									Xc=XC(m,:);
								end
							end
							if length(TT(m,:))==1
								T=TT(m);
							else 
								if TT(m,1)==-9999
									T=TT(m,2);
								elseif TT(m,2)==-9999
									T=TT(m,1);
								else
									T=TT(m,:);
								end
							end

						end
					end
 
					%If not initialized use default values
					if Xc==-9999 | Xc==[-9999 -9999]
						Xc=log2(20E3/500)/2;
						T=.01;
					end

					%Evaluating RTFHist
					f=['[RD1,FM1,RD2,FM2,Time1,Time2]=rtfhist(' ch paramfile ch ',spet,Trig,Fs,T,Xc);'];
					eval(f);
	
					%Generating Histograms
					MFM=2*FMMax*((0:NFM-1)/NFM+1/NFM/2-.5);
					MRD=RDMax*((0:NFM-1)/NFM+1/NFM/2);
					[FM,RD,N1]=hist2(FM1,RD1,MFM,MRD);
					[FM,RD,N2]=hist2(FM2,RD2,MFM,MRD);
					[FM,FM,NFM12]=hist2(FM1,FM2,MFM,MFM);
					[RD,RD,NRD12]=hist2(RD1,RD2,MRD,MRD);
	
					%Save Command
					SaveCommand=[' RD1 FM1 RD2 FM2 Time1 Time2 RD FM N1 N2 NFM12 NRD12 T NRD NFM RDMax FMMax Xc' ];
	
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
