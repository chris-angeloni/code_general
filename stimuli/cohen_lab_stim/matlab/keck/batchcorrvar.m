%
%function []=batchcorrvar(BatchFile,Header,MRSpecFile,RNSpecFile,T1,T2,DF)
%
%	FILE NAME       : BATCH CORR VAR
%	DESCRIPTION     : Uses a batch file to compute the SI distribution
%			  for MR and RN. SI index histograms saved to file.
%
%	BatchFile	: Batch file containing corresponding STRFs for 
%			  moving ripple and ripple noise
%	Header		: Experiment Header 
%	MRSpecFile	: Moving ripple spectral profile filename
%	RNSpecFile	: Ripple noise spectral profile filename
%	T1,T2		: Evaluation delay interval for WSTRF(T,F)
%			  T E [- T1 , T2 ], Note that T1 and T2 > 0    
%	DF		: STRF down sampling factor. Necessary if STRF 
%			  was upsampled and has a larger sampling rate 
%			  than the 'spr' file
%
%Example Batch File
%
%MRFILE          SPIKES  RNFILE          SPIKES  SOUNDCH SPIKE   TYPE
%-----------------------------------------------------------------------
%t2_f36_ch2      0       t2_f39_ch2      ---     2       LARGE   F
%t2_f36_ch2      1       t2_f39_ch2      0       2       MED     L
%t3_f07_ch1      0       t3_f11_ch1      ---     1       LARGE   F
%t3_f17_ch1      0+2     t3_f18_ch1      0       1       LARGE   F
%t3_f17_ch1      1       t3_f18_ch1      0+1     1       LARGE   F
%
function []=batchcorrvar(BatchFile,Header,MRSpecFile,RNSpecFile,T1,T2,DF)

%Preliminaries
more off

%Getting Batch Data
ch=setstr(39);
fid=fopen(BatchFile);
List=fread(fid,inf,'uchar')';
List=[10 List 10];
returnindex=find(List==10);
DataList=zeros(length(returnindex)-1,100);
for k=1:length(returnindex)-1

	CurrentList=setstr(List(returnindex(k)+1:returnindex(k+1)-1));
	DataList(k,1:length(CurrentList))=CurrentList;

end

%Finding Corresponding Files and Computing Correlation Coefficients
Tab=setstr(9);
count=1;
LL=30;
MRList=setstr(32*ones(length(returnindex)-1,5*LL));
RNList=setstr(32*ones(length(returnindex)-1,5*LL));
for k=1:length(returnindex)-1

	if DataList(k,1)=='t';

		%Finding Tape Number, File Number, Unit Numbers, Sound Channel
		tabindex=findstr(DataList(k,:),Tab);
		TapeMR=DataList(k,1:tabindex(1)-1);
		TapeRN=DataList(k,tabindex(2)+1:tabindex(3)-1);
		UnitsMR=DataList(k,tabindex(1)+1:tabindex(2)-1);
		UnitsRN=DataList(k,tabindex(3)+1:tabindex(4)-1);
		Channel=DataList(k,tabindex(4)+1:tabindex(5)-1);

		%Finding STRFs for UnitMR
		for l=1:length(UnitsMR)

			if ~strcmp(UnitsMR(l),'+') & ~strcmp(UnitsMR(l),'-')

				%Possible STRF Files - Lin or dB
				fileMRLin=[Header TapeMR '_u' UnitsMR(l) '_Lin.mat'];
				fileMRdB=[Header TapeMR '_u' UnitsMR(l) '_dB.mat'];

				%Checking to see if sound is Lin or dB
				if exist(fileMRLin)

					%Loading spet, Trig and STRF Files
					f=['load ' fileMRLin];
					eval(f);
					disp(f);
					index=findstr('.',fileMRLin);
					f=['load ' fileMRLin(1:index-8)];
					eval(f)
					f=['load ' fileMRLin(1:index-12) '_Trig'];
					eval(f)
					f=['spet=spet' UnitsMR(l) ';'];
					eval(f)

					%Generating a random spet (20 minutes)
					spetr=poissongen(10*ones(1,1200),1,Fs);

					%Downsampling STRFs
					STRF1=STRF1s(:,1:DF:length(taxis));
					STRF2=STRF2s(:,1:DF:length(taxis));

[p1,p2,p1e,p2e,p1i,p2i,spindex1,spindex2]=rtwstrflinvar(STRF1,STRF2,MRSpecFile,T1,T2,spet,Trig,Fs,45,45,'MR',50,'float');
[p1r,p2r,p1er,p2er,p1ir,p2ir,spindex1r,spindex2r]=rtwstrflinvar(STRF1,STRF2,MRSpecFile,T1,T2,spetr,Trig,Fs,45,45,'MR',50,'float');

					%Saving Output File
					f=['save ' fileMRLin(1:index-1) 'Var p1 p2 p1e p2e p1i p2i spindex1 spindex2 p1r p2r p1er p2er p1ir p2ir'];
					if findstr('5.',version)
						f=[f ' -v4'];
					end
					disp(f) 
	 		 		eval(f)

				elseif exist(fileMRdB)

					%Loading spet, Trig and STRF Files
					f=['load ' fileMRdB];
					eval(f);
					disp(f)
					index=findstr('.',fileMRdB);
					f=['load ' fileMRdB(1:index-7)];
					eval(f)
					f=['load ' fileMRdB(1:index-11) '_Trig'];
					eval(f)	
					f=['spet=spet' UnitsMR(l) ';'];
					eval(f)

					%Generating a random spet (20 minutes)
					spetr=poissongen(10*ones(1,1200),1,Fs);

					%Downsampling STRFs
					STRF1=STRF1s(:,1:DF:length(taxis));
					STRF2=STRF2s(:,1:DF:length(taxis));

[p1,p2,p1e,p2e,p1i,p2i,spindex1,spindex2]=rtwstrfdbvar(STRF1,STRF2,MRSpecFile,T1,T2,spet,Trig,Fs,45,45,'MR',50,'float');
[p1r,p2r,p1er,p2er,p1ir,p2ir,spindex1r,spindex2r]=rtwstrfdbvar(STRF1,STRF2,MRSpecFile,T1,T2,spetr,Trig,Fs,45,45,'MR',50,'float');
		
					%Saving Output File
					f=['save ' fileMRdB(1:index-1) 'Var p1 p2 p1e p2e p1i p2i spindex1 spindex2 p1r p2r p1er p2er p1ir p2ir'];
					if ~findstr('5.',version)
						f=[f ' -v4'];
					end
					disp(f)
					eval(f)

				end

			end
		end

		%Finding STRFs for UnitRN
		for l=1:length(UnitsRN)

			if ~strcmp(UnitsRN(l),'+') & ~strcmp(UnitsRN(l),'-')

				%Possible STRF Files - Lin or dB
				fileRNLin=[Header TapeRN '_u' UnitsRN(l) '_Lin.mat'];
				fileRNdB=[Header TapeRN '_u' UnitsRN(l) '_dB.mat'];

				%Checking to see if sound is Lin or dB
				if exist(fileRNLin)

					%Loading spet, Trig and STRF Files
					f=['load ' fileRNLin];
					eval(f);
					disp(f);
					disp(setstr(10));
					index=findstr('.',fileRNLin);
					f=['load ' fileRNLin(1:index-8)];
					eval(f)
					f=['load ' fileRNLin(1:index-12) '_Trig'];
					eval(f)	
					f=['spet=spet' UnitsRN(l) ';'];
					eval(f)

					%Generating a random spet (20 minutes)
					spetr=poissongen(10*ones(1,1200),1,Fs);

					%Downsampling STRFs
					STRF1=STRF1s(:,1:DF:length(taxis));
					STRF2=STRF2s(:,1:DF:length(taxis));

[p1,p2,p1e,p2e,p1i,p2i,spindex1,spindex2]=rtwstrflinvar(STRF1,STRF2,RNSpecFile,T1,T2,spet,Trig,Fs,45,45,'RN',50,'float');
[p1r,p2r,p1er,p2er,p1ir,p2ir,spindex1r,spindex2r]=rtwstrflinvar(STRF1,STRF2,RNSpecFile,T1,T2,spetr,Trig,Fs,45,45,'RN',50,'float');

					%Saving Output File
					f=['save ' fileRNLin(1:index-1) 'Var p1 p2 p1e p2e p1i p2i spindex1 spindex2 p1r p2r p1er p2er p1ir p2ir'];
					if findstr('5.',version)
						f=[f ' -v4'];
					end
					disp(f)
					eval(f)

				elseif exist(fileRNdB)

					%Loading spet, Trig and STRF Files
					f=['load ' fileRNdB];
					eval(f);
					disp(f);
					disp(setstr(10));
					index=findstr('.',fileRNdB);
					f=['load ' fileRNdB(1:index-7)];
					eval(f)
					f=['load ' fileRNdB(1:index-11) '_Trig'];
					eval(f)	
					f=['spet=spet' UnitsRN(l) ';'];
					eval(f)

					%Generating a random spet (20 minutes)
					spetr=poissongen(10*ones(1,1200),1,Fs);

					%Downsampling STRFs
					STRF1=STRF1s(:,1:DF:length(taxis));
					STRF2=STRF2s(:,1:DF:length(taxis));

[p1,p2,p1e,p2e,p1i,p2i,spindex1,spindex2]=rtwstrfdbvar(STRF1,STRF2,RNSpecFile,T1,T2,spet0,Trig,Fs,45,45,'RN',50,'float');
[p1r,p2r,p1er,p2er,p1ir,p2ir,spindex1r,spindex2r]=rtwstrfdbvar(STRF1,STRF2,RNSpecFile,T1,T2,spetr,Trig,Fs,45,45,'RN',50,'float');

					%Saving Output File
					f=['save ' fileRNdB(1:index-1) 'Var p1 p2 p1e p2e p1i p2i spindex1 spindex2 p1r p2r p1er p2er p1ir p2ir'];
					if findstr('5.',version)
						f=[f ' -v4'];
					end
					disp(f)
					eval(f)

				end
			end
		end

		%Incrementing Counter
		count=count+1;

	end
end

