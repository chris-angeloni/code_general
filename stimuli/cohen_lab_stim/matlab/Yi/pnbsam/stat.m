% --------------- Reliability and Jitter
% function [RJ,count]=stat(Data,RJ,count)
% [RASspet, RAStt, FMAxis] = rastergen(Data,0,'duration',1,4,0,10)
% [MTFJ,P,Sigma] = mtfjittergenerate(RASspet,FMAxis)
% RJ.p(count,1:length(FMAxis)) = P;
% RJ.sigma(count,1:length(FMAxis)) = Sigma;

% function [ONSET,SUS,count]=stat(Data,ONSET,SUS,count)
% [RASspet, RAStt, FMAxis] = rastergen(Data,2,'cyc',0,1,0,100)
% [SPET2] = firstvs2ndspet(RASspet,FMAxis)
% [Bound,RASonset,RASsus]=sep1st2nd(SPET2,RASspet,FMAxis,2,'cyc',0,1)

% [RASonset2]=cuttrials(RASonset,FMAxis,30)
% [MTFJo,Po,Sigmao] = mtfjittergenerate(RASonset2,FMAxis)
% ONSET.p(count,1:length(FMAxis)) = Po;
% ONSET.sigma(count,1:length(FMAxis)) = Sigmao;

% [RASsus2]=cuttrials(RASspet,FMAxis,50)
% [MTFJs,Ps,Sigmas] = mtfjittergenerate(RASsus2,FMAxis)
% SUS.p(count,1:length(FMAxis)) = Ps;
% SUS.sigma(count,1:length(FMAxis)) = Sigmas;

% ------------MTF SAM and PNB
% function [PNB,SAM,count]=stat(Data,PNB,SAM,count)
% [RASspet0, RAStt, FMAxis] = rastergen(Data,0,'duration',1,4,0,10)
% [MTF0]= mtfrtgenerate(RASspet0,FMAxis,0,'duration',1,4,10)
% SAM.RATE(count,1:length(FMAxis)) = MTF0.Rate;
% SAM.NORM(count,1:length(FMAxis)) = MTF0.Spetnorm;
% SAM.VS(count,1:length(FMAxis)) = MTF0.VS
% SAM.VSsig(count,1:length(FMAxis)) = MTF0.VSsig;
% 
% [RASspet1, RAStt, FMAxis] = rastergen(Data,1,'duration',1,4,0,10)
% [MTF1]= mtfrtgenerate(RASspet1,FMAxis,1,'duration',1,4,10)
% PNB.RATE(count,1:length(FMAxis)) = MTF1.Rate;
% PNB.NORM(count,1:length(FMAxis)) = MTF1.Spetnorm
% PNB.VS(count,1:length(FMAxis)) = MTF1.VS
% PNB.VSsig(count,1:length(FMAxis)) = MTF1.VSsig;

% -------------MTF  ONSET
% function [RASOnset,RASSus,ONSET,SUS,count]=stat(Data,RASOnset,RASSus,ONSET,SUS,count)
% 
% [RASspet, RAStt, FMAxis] = rastergen(Data,2,'cyc',0,1,0,100)
% [SPET2] = firstvs2ndspet(RASspet,FMAxis)
% [Bound,RASonset,RASsus]=sep1st2nd(SPET2,RASspet,FMAxis,2,'cyc',0,1)
% RASOnset(count,1:length(RASspet))=RASonset';
% RASSus(count,1:length(RASspet))=RASsus';
% 
% [MTFonset]= mtfrtgenerate(RASonset,FMAxis,2,'cyc',0,1,100)
% ONSET.RATE(count,1:length(FMAxis)) = MTFonset.Rate;
% ONSET.NORM(count,1:length(FMAxis)) = MTFonset.Spetnorm;
% ONSET.VS(count,1:length(FMAxis)) = MTFonset.VS;
% ONSET.VSsig(count,1:length(FMAxis)) = MTFonset.VSsig;
% 
% [MTFsus]= mtfrtgenerate(RASsus,FMAxis,2,'cyc',0,1,100)
% SUS.RATE(count,1:length(FMAxis)) = MTFsus.Rate;
% SUS.NORM(count,1:length(FMAxis)) = MTFsus.Spetnorm;
% SUS.VS(count,1:length(FMAxis)) = MTFsus.VS;
% SUS.VSsig(count,1:length(FMAxis)) = MTFsus.VSsig;

% % -------------- MTF PNB&SAM shuffled-correlation-----------
% function [MTFsamshuf,count]=stat(MTFsamshuf,RASsam,FMAxis,count)
% [MTF0] = mtfcorrgenerate(RASsam,1,FMAxis,10,100);
% %MTFsamshuf(count,1:length(FMAxis))=MTF0;
% MTFsamshuf(count,1:length(FMAxis))=MTF0(1:length(FMAxis));
% % 
% [RASspet1, RAStt, FMAxis] = rastergen(Data,1,'duration',1,4,0,10);
% [MTF1] = mtfcorrgenerate(RASspet1,0,FMAxis,10,100);
% MTFpnbshuf(count,1:length(FMAxis))=MTF1(1:length(FMAxis));
% MTFpnbshuf(count,13:length(FMAxis))=MTF1(13:length(FMAxis));

% -------------- ONSET shuffled-correlation-----------
% function [MTFonsetshuf,MTFsusshuf,count]=stat(RASonset,RASsus,FMAxis,MTFonsetshuf,MTFsusshuf,count)
% [RASspet, RAStt, FMAxis] = rastergen(Data,2,'cyc',0,1,0,100)
% [SPET2] = firstvs2ndspet(RASspet,FMAxis)
% [Bound,RASonset,RASsus]=sep1st2nd(SPET2,RASspet,FMAxis,2,'cyc',0,1)

% [MTF0] = mtfcorrgenerate(RASsus,0,FMAxis,50,100);
% MTFsusshuf(count,1:length(FMAxis))=MTF0;
% 
% [MTF1] = mtfcorrgenerate(RASonset,0,FMAxis,50,100);
% MTFonsetshuf(count,1:length(FMAxis))=MTF1;

% --------------- ONSET shuffled circular correlation ---------
% function [Suscirshuf,count]=stat(Suscirshuf,RASSus,FMAxis,count)
% 
% [RASwrap]=cirwrapras(RASSus,FMAxis);
% [MTF] = mtfcorrgenerate(RASwrap,0,FMAxis,10,100);
% % dont forget change
% % "RAS=rasterexpand(RASTER((k-1)*NTrial+1:k*NTrial),Fsd,1/FMAxis(k),0);"
% % in mtfcorrgenerate
% % and cxcorr in rastercorr
% Suscirshuf(count,1:length(FMAxis))=MTF;

% -------------- CYCH SAM -----------------------
% function [SAMhist,count]=stat(Data,SAMhist,count)
% [RASspet0, RAStt, FMAxis] = rastergen(Data,1,'duration',1,4,0,10);
% [CYCH]= cychgen(RASspet0,Flag,FMAxis,50,'duration',1,4,10)
% [MTF] = mtfhistgen(CYCH,FMAxis,50);
% SAMhist(count,1:length(FMAxis))=MTF;

% function [RASpnb,RASsam,count]=stat(Data,RASpnb,RASsam,count)
% % str1='E:\projects\AM\data\Feb07\unit';
% % str2='sampnb.mat';
% % str=[str1 num2str(count-58) str2];
% % load(str);
% close all
% [RASspet0, RAStt, FMAxis] = rastergen(Data,0,'duration',1,4,0,10);
% [RASspet1, RAStt, FMAxis] = rastergen(Data,1,'duration',1,4,0,10);
% RASsam(count,1:length(RASspet0))=RASspet0;
% RASpnb(count,1:length(RASspet1))=RASspet1;

% -----------------
% function [FMmax,count]=stat(Shuf,FMAxis,count)
% FMmax=zeros(1,93);
% while count<93
%     if isempty([Shuf(count,:).Aboot])
%         count=count+1;
%     else
% [SIG,Fmmax] = maxFMvsBF(Shuf(count,:),FMAxis);
% FMmax(1,count)=Fmmax;
% count = count+1;
%     end
% end

% ---------- mean and sd of latency ---------
function [lateM,lateSD]=stat(lateM,lateSD,RASTER,FMAxis,Flag,Dtran,count)
while count<128
RASspet = RASTER(count,:);
if ~isempty(RASspet)
[CYCH]=cychgen(RASspet,2,FMAxis,25,'cyc',0,1,100);
[SpetMean,SpetSD,Lbound,Hbound]=meansdgen(RASspet,FMAxis,Flag,CYCH,Dtran);
lateM(count,:)=SpetMean;
lateSD(count,:)=SpetSD;
end
count = count+1;
end






