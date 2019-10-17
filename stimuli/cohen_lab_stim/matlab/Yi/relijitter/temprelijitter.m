function [rjPNB]=temprelijitter(rjPNB,RASTER,FMAxis,j)

for i=1:180
RASspet2(i).Fs=RASTER(i).Fs;
RASspet2(i).T=0.2;
in=find(RASTER(i).spet/12207<0.01);
if ~isempty(in)
RASspet2(i).spet=RASTER(i).spet(in);
end
end
[MTFJ]=mtfrelijitter(RASspet2,FMAxis,'abs')
rjPNB(j,:)=MTFJ;

% for i=127:127
% RASspet=RASTER(i,:);
% %  for j=1:1800
% %      RASspet(j).T=0.2;
% %  end
% [MTFJ]=mtfrelijitter(RASspet,FMAxis,'abs')
% rjPNB(i,:)=MTFJ;
% end

% ------- 1st spike latency per trial and per cycle ---------
% function [LatePNB,LateSAM]=temprelijitter(LatePNB,LateSAM,Data,i)
% 
% [RASspet, RAStt, FMAxis] = rastergen(Data,1,'duration',0,1,0,10);
% [SPET]=stlatepertrial(RASspet,FMAxis);
% 
% [RASspet, RAStt, FMAxis] = rastergen(Data,1,'duration',1,4,0,10);
% [SPET2]=stlatepercyc(RASspet,FMAxis);
% 
% LatePNB(i).stevent=SPET;
% LatePNB(i).perevent=SPET2;
% 
% [RASspet, RAStt, FMAxis] = rastergen(Data,0,'duration',0,1,0,10);
% [SPET3]=stlatepertrial(RASspet,FMAxis);
% 
% [RASspet, RAStt, FMAxis] = rastergen(Data,0,'duration',1,4,0,10);
% [SPET4]=stlatepercyc(RASspet,FMAxis);
% 
% semilogx(FMAxis,[SPET2.m],'r');
% hold on;
% semilogx(FMAxis,[SPET.m],'r');
% hold on;
% semilogx(FMAxis,[SPET3.m],'b');
% hold on;
% semilogx(FMAxis,[SPET4.m],'b');
% 
% LateSAM(i).stevent=SPET3;
% LateSAM(i).perevent=SPET4;


% ---------- Latency to RASspet ----------
% function [RASspet]=temprelijitter(FMAxis,LATE)
% 
% for FMi=1:18
%   for n=1:10
%     RASspet((FMi-1)*10+n).Fs=12207;
%     RASspet((FMi-1)*10+n).T=0.2;
%     temp=[LATE.stevent(FMi).fst].*12207;
%     RASspet((FMi-1)*10+n).spet=temp(n);
%   end
% end

% ------- reliability and jitter of 1-st spike per trial ---------
% function [rjPNB1st,rjSAM1st]=temprelijitter(rjPNB1st,rjSAM1st,FMAxis,LatePNB,LateSAM)
% 
% for i=16:24
%  [RASspets]=lat2ras(FMAxis,LateSAM(i));
%  [MTFJs]=mtfrelijitter(RASspets,FMAxis,'abs');
%  rjSAM1st(i,:)=MTFJs;
%  [RASspetp]=lat2ras(FMAxis,LatePNB(i));
%  [MTFJp]=mtfrelijitter(RASspetp,FMAxis,'abs');
%  rjPNB1st(i,:)=MTFJp;
% end





