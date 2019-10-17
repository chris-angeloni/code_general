%
%function []=printbatch(Printer,BatchFile,Header,Chan,Lag,RDMax,FMMax,Display,ModType,invert)
%
%       FILE NAME       : PRINT STRF BATCH
%       DESCRIPTION     : Print all STRF Files in working Directory
%	
%	Printer		: Printer name or 'None' for no print output
%	BatchFile	: Contains Experiment Data for all Sounds
%	Header		: Data File Header
%	Chan		: Array of Channel Numbers to Plot Data 
%	Lag		: Lag for PSTH
%	RDMax		: Maximum Ripple Density
%	FMMax		: Maximum Temporal Modulation
%	Display		: Desired Display Type : Array
%			  1 : Display STRF
%			  2 : Display SpikeAnal
%			  3 : Display RTF
%			  4 : Display RTFHist
%			  5 : Display PRE
%			  6 : Display dB vs. SPL
%			  For Example : [1 2 5]
%			  Displays STRF, Spike Anal, and PRE data
%
%	ModType		: Kernel Modulation type : 'dB' or 'lin'
%			  Default: 'dB'
%	invert		: Invert the Spike Waveform (Default=='n')
%
%
%	Batch File should be tab delimited and arranged colum-wise 
%	with the Following information
%
%	tapenum	filenum	SPL	MdB	Sound	SModType  Experiment
%-----------------------------------------------------------------
%Eg.	3	23	60	30	RN	dB	    RF
%	4	12	50	30	MR	lin	    RF
%	2	23	40	40	MR		    PRE
%	5	12	55		RN		    ALL
%	4	15	50				    TC
%	4	17					    BAD
%
function []=printbatch(Printer,BatchFile,Header,Chan,Lag,RDMax,FMMax,Display,ModType,invert)

%Preliminaries
more off

%Checking Input Arguments
if nargin < 7
	Display=1;
	ModType='dB';
	invert='n';
elseif nargin < 8
	ModType='dB';
	invert='n';
elseif nargin < 9
	invert='n';
end

%Getting Batch Data
ch=setstr(39);
fid=fopen(BatchFile);
List=fread(fid,inf,'uchar')';
List=[10 List 10];
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

	%Plotting Desired Data
	for j=1:length(Chan)

		%Loading SPET Data
		Tape=num2str(str2num(setstr(Param(1,:))));
		FileNum=num2str(str2num(setstr(Param(2,:))));
		Channel=num2str(Chan(j));

		if str2num(FileNum)<10
			spetfile=[Header 't' Tape '_f0' FileNum '_ch' Channel];
		else
			spetfile=[Header 't' Tape '_f' FileNum '_ch' Channel];
		end

		if exist([spetfile '.mat']) 

			f=['load ' spetfile];
			eval(f);

			%Finding All Non-Outlier spet
			count=-1;
			while exist(['spet' int2str(count+1)])
				count=count+1;
			end
			Nspet=(count+1)/2;

			%Printing Data for all Units
			for k=0:Nspet-1
	
				%Printing STRF
				if sum(Display==1) & findstr(Param(7,:),'RF')
					filename=[spetfile '_u' num2str(k) '_' ModType '.mat'];
					if exist(filename)
						[fighandle]=plotstrf(filename,invert);
						if findstr(Printer,'None')
							pause
						else
							pause(0)
							print -dpsc /tmp/temp.ps
							f=['!lpr -P' Printer ' /tmp/temp.ps'];
							eval(f)
							!rm /tmp/temp.ps
						end
						f=['close(' int2str(fighandle) ')'];
                        	        	eval(f)
					end
				end

				%Printing SpkA
				if sum(Display==2) & findstr(Param(7,:),'RF')
					filename=[spetfile '_u' num2str(k) '_SpkA.mat'];
					if exist(filename)
						[fighandle]=plotspikeanal(filename,Lag,invert);
						if findstr(Printer,'None')
							pause
						else
							pause(0)
							print -dpsc /tmp/temp.ps
							f=['!lpr -P' Printer ' /tmp/temp.ps'];
							eval(f)
							!rm /tmp/temp.ps
						end
						f=['close(' int2str(fighandle) ')'];
                        	        	eval(f)
					end
				end
	
				%Printing RTF
				if sum(Display==3) & findstr(Param(7,:),'RF')
					filename=[spetfile '_u' num2str(k) '_RTF.mat'];
					if exist(filename)
						[fighandle]=plotrtf(filename);
						if findstr(Printer,'None')
							pause
						else	
							pause(0)
							print -dpsc /tmp/temp.ps
							f=['!lpr -P' Printer ' /tmp/temp.ps'];
							eval(f)
							!rm /tmp/temp.ps
						end
						f=['close(' int2str(fighandle) ')'];
                        	        	eval(f)
					end
				end

				%Printing RTF Histogram
				if sum(Display==4) & findstr(Param(5,:),'MR') & findstr(Param(7,:),'RF')
					filename=[spetfile '_u' num2str(k) '_RTFHist.mat'];
					if exist(filename  )
						[fighandle]=plotrtfhist(filename,RDMax,FMMax,invert);
						pause(0)
						if findstr(Printer,'None')
							pause
						else	
							print -dpsc /tmp/temp.ps
							f=['!lpr -P' Printer ' /tmp/temp.ps'];
							eval(f)
							!rm /tmp/temp.ps
						end
						f=['close(' int2str(fighandle) ')'];
                        	        	eval(f)
					end
				end

				%Printing PRE
				if sum(Display==5) & findstr(Param(7,:),'PRE')

				end

				%Printing dB vs. SPL
				if sum(Display==6) & findstr(Param(7,:),'ALL')
					filename=[spetfile '_u' num2str(k) '_dBSPL.mat'];
					if exist(filename)
						[fighandle]=plotdbspl(filename,invert);
						pause(0)
						if findstr(Printer,'None')
							pause
						else
							print -dpsc /tmp/temp.ps
							f=['!lpr -P' Printer ' /tmp/temp.ps'];
							eval(f)
							!rm /tmp/temp.ps
						end
						f=['close(' int2str(fighandle) ')'];
                        	        	eval(f)
					end
				end
			end
		end
	end


end
