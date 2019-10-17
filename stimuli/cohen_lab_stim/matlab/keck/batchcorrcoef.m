%
%function [R,stdMR,stdRN,WoMR,WoRN,diffMR,diffRN,MRList,RNList,SPL,SNRMR,SNRRN,stdMRe,stdMRi]=batchcorrcoef(BatchFile,Header)
%
%	FILE NAME       : BATCH CORR COEF
%	DESCRIPTION     : Uses a batch file to compute the correlation 
%			  coefficient and the mean spike rate ratio 
%			  for STRFs computed using RN and MR
%
%	BatchFile	: Batch file containing corresponding STRFs for 
%			  moving ripple and ripple noise
%	Header		: Experiment Header 
%
%RETURNED VARIABLES
%
%	R		: STRF correlation coefficient array
%	stdMR		: Energy array ( standard deviation ) in MR STRF
%	stdRN		: Energy array in RN STRF 
%	WoMR		: MR mean spike rate array
%	WoRN		: RN mean spike rate array
%	diffMR		: MR max(max(STRF)-min(min(STRF))
%	diffRN		: RN max(max(STRF)-min(min(STRF))
%	MRList		: MR File List
%	RNList		: RN File List
%	SPL		: SPL Array
%	SNRMR		: MR STRF signal to noise ratio
%	SNRRN		: RN STRF signal to noise ratio
%	stdMRe		: MR STRF Excitatory Energy 
%	stdMRi		: MR STRF Inhibitory Energy
%
%Example Batch File
%
%MRFILE          SPIKES  RNFILE          SPIKES  SOUNDCH SPIKE   TYPE
%-----------------------------------------------------------------------
%
%t2_f36_ch2      0       t2_f39_ch2      ---     2       LARGE   F
%t2_f36_ch2      1       t2_f39_ch2      0       2       MED     L
%t3_f07_ch1      0       t3_f11_ch1      ---     1       LARGE   F
%t3_f17_ch1      0+2     t3_f18_ch1      0       1       LARGE   F
%t3_f17_ch1      1       t3_f18_ch1      0+1     1       LARGE   F
%
function [R,stdMR,stdRN,WoMR,WoRN,diffMR,diffRN,MRList,RNList,SPL,SNRMR,SNRRN,stdMRe,stdMRi]=batchcorrcoef(BatchFile,Header)

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
DataList=setstr(DataList);

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

					%Loading File for Lin Sound
					f=['load ' fileMRLin];
					eval(f);
					disp(f);

					%Adding to MR List
					MRList(count,(l-1)*LL+(1:length(fileMRLin)))=fileMRLin;

					%Initializing if necessary
					if l==1
						STRFMR1=zeros(size(STRF1s));
						STRFMR2=zeros(size(STRF1s));
						WoMR(count)=0;
						NoMR(count)=0;
					end

					%Finding Compound STRF and mean spike rate
					STRFMR1=STRFMR1+STRF1s;
					STRFMR2=STRFMR2+STRF2s;
					WoMR(count)=WoMR(count)+Wo1;
					NoMR(count)=NoMR(count)+No1;
					PPMR=PP;
					Fst=1/(taxis(2)-taxis(1));


				elseif exist(fileMRdB)

					%Loading File for dB Sound
					f=['load ' fileMRdB];
					eval(f);
					disp(f)

					%Adding to MR List
					MRList(count,(l-1)*LL+(1:length(fileMRdB)))=fileMRdB;

					%Initializing if necessary
					if l==1
						STRFMR1=zeros(size(STRF1s));
						STRFMR2=zeros(size(STRF1s));
						WoMR(count)=0;
						NoMR(count)=0;
					end

					%Finding Compound STRF and mean spike rate
					STRFMR1=STRFMR1+STRF1s;
					STRFMR2=STRFMR2+STRF2s;
					WoMR(count)=WoMR(count)+Wo1;
					NoMR(count)=NoMR(count)+No1;
					PPMR=PP;
					Fst=1/(taxis(2)-taxis(1));
				end

				%Finding Stimulus Parameters
				MdBMR=MdB;
				ModTypeMR=ModType;
				SModTypeMR=SModType;
	

			elseif strcmp(UnitsMR(l),'-')

				%Setting STRF to -9999 - flag for no STRF
				STRFMR1=-9999;
				STRFMR2=-9999;

				%Adding to MR List
				MRList(count,1:3)='---';
				PPMR=0;

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

					%Loading File for Lin Sound
					f=['load ' fileRNLin];
					eval(f);
					disp(f);
					disp(setstr(10));

					%Adding to RN List
					RNList(count,(l-1)*LL+(1:length(fileRNLin)))=fileRNLin;
	
					%Initializing if necessary
					if l==1
						STRFRN1=zeros(size(STRF1s));
						STRFRN2=zeros(size(STRF1s));
						WoRN(count)=0;
						NoRN(count)=0;
					end

					%Finding Compound STRF and mean spike rate
					STRFRN1=STRFRN1+STRF1s;
					STRFRN2=STRFRN2+STRF2s;
					WoRN(count)=WoRN(count)+Wo1;
					NoRN(count)=NoRN(count)+No1;
					PPRN=PP;
					Fst=1/(taxis(2)-taxis(1));

				elseif exist(fileRNdB)

					%Loading File for Lin Sound
					f=['load ' fileRNdB];
					eval(f);
					disp(f);
					disp(setstr(10));

					%Adding to RN List
					RNList(count,(l-1)*LL+(1:length(fileRNdB)))=fileRNdB;

					%Initializing if necessary
					if l==1
						STRFRN1=zeros(size(STRF1s));
						STRFRN2=zeros(size(STRF1s));
						WoRN(count)=0;
						NoRN(count)=0;
					end

					%Finding Compound STRF
					STRFRN1=STRFRN1+STRF1s;
					STRFRN2=STRFRN2+STRF2s;
					WoRN(count)=WoRN(count)+Wo1;
					NoRN(count)=NoRN(count)+No1;
					PPRN=PP;
					Fst=1/(taxis(2)-taxis(1));
				end

				%Finding Stimulus Parameters
				MdBRN=MdB;
				ModTypeRN=ModType;
				SModTypeRN=SModType;

			elseif strcmp(UnitsRN(l),'-')

				%Setting STRF to -9999
				STRFRN1=-9999;
				STRFRN2=-9999;

				%Adding to RN List
				RNList(count,1:3)='---';
				PPRN=0;

			end
		end

		%Generating compound STRF if necessary - for RN and MR
		if STRFMR1~=-9999 & STRFRN1~=-9999
			if length(Channel)>1
				STRFMR=[STRFMR1 STRFMR2];
				STRFRN=[STRFRN1 STRFRN2];
			elseif str2num(Channel)==1
				STRFMR=STRFMR1;
				STRFRN=STRFRN1;
			elseif str2num(Channel)==2
				STRFMR=STRFMR2;
				STRFRN=STRFRN2;
			end
		elseif STRFMR1==-9999
			if length(Channel)>1
				STRFRN=[STRFRN1 STRFRN2];
			elseif str2num(Channel)==1
				STRFRN=STRFRN1;
			elseif str2num(Channel)==2
				STRFRN=STRFRN2;
			end
			STRFMR=zeros(size(STRFRN));
			STRFMR(1,1)=1E-20;
			WoMR(count)=0;
			NoMR(count)=0;
		elseif STRFRN1==-9999
			if length(Channel)>1
				STRFMR=[STRFMR1 STRFMR2];
			elseif str2num(Channel)==1
				STRFMR=STRFMR1;
			elseif str2num(Channel)==2
				STRFMR=STRFMR2;
			end
			STRFRN=zeros(size(STRFMR));
			STRFRN(1,1)=1E-20;
			WoRN(count)=0;
			NoRN(count)=0;
		end

		%Computing STRF Corr Coef
		R(count)=strfcorrcoef(STRFMR,STRFRN);
		diffMR(count)=(max(max(STRFMR))-min(min(STRFMR)))*sqrt(PPMR);	
		diffRN(count)=(max(max(STRFRN))-min(min(STRFRN)))*sqrt(PPRN);	
		stdMR(count)=strfstd(STRFMR1,STRFMR2,PPMR,Fst);
		stdRN(count)=strfstd(STRFRN1,STRFRN2,PPRN,Fst);
		SPL(count)=SPLN;
%		stdRN(count)=strfnorm(STRFRN1,STRFRN2,PPRN);
%		stdMR(count)=strfnorm(STRFMR1,STRFMR2,PPRN);

		%Finding Inhibitory and Excitatory Energy
		i=find(STRFMR1>0);
		STRFMR1i=STRFMR1;
		STRFMR1i(i)=zeros(size(i));	
		i=find(STRFMR2>0);
		STRFMR2i=STRFMR2;
		STRFMR2i(i)=zeros(size(i));	
		stdMRi(count)=strfstd(STRFMR1i,STRFMR2i,PPMR,Fst);

		i=find(STRFMR1<0);
		STRFMR1e=STRFMR1;
		STRFMR1e(i)=zeros(size(i));	
		i=find(STRFMR2<0);
		STRFMR2e=STRFMR2;
		STRFMR2e(i)=zeros(size(i));	
		stdMRe(count)=strfstd(STRFMR1e,STRFMR2e,PPMR,Fst);

		%Finding STRF Signal To Noise Ratio
		No=NoMR(count);
		Wo=WoMR(count);
		[STRFp,Tresh]=wstrfstat(STRFMR,0.001,100,Wo,PPMR,MdBMR,...
			ModTypeMR,'MR',SModTypeMR); 
		index=find(STRFp~=0);
		SNRMR(count,:)=[max(max(STRFp)) mean(abs(STRFp(index)))]/Tresh;

		No=NoRN(count);
		Wo=WoRN(count);
		[STRFp,Tresh]=wstrfstat(STRFRN,0.001,100,Wo,PPRN,MdBRN,...
			ModTypeRN,'RN',SModTypeRN); 
		index=find(STRFp~=0);
		SNRRN(count,:)=[max(max(STRFp)) mean(abs(STRFp(index)))]/Tresh;


%subplot(211)
%pcolor(STRFMR),shading flat, colormap jet, colorbar
%subplot(212)
%pcolor(STRFRN),shading flat, colormap jet, colorbar
[R(count) WoMR(count) WoRN(count) stdMR(count) stdRN(count)]
%pause

		%Clearing Some Variables
		clear STRFMR STRFRN STRFRN1 STRFRN2 STRFMR1 STRFMR2

		%Incrementing Counter
		count=count+1;

	end
end

%Truncating the MRList and RNList
RNList=RNList(1:count-1,:);
MRList=MRList(1:count-1,:);

