function [LATE]=latency(RASTER,FMAxis,N,startC,numC,binspercyc,FMi)

Time = [];
Trial = [];
for k = 1:length(RASTER)
    Time = [Time RASTER(k).spet/RASTER(k).Fs];
    Trial = [Trial k*ones(size(RASTER(k).spet))];
end

latencyall = [];
for FMindex = 1:length(FMAxis)
    latencyFM = [];
    FM = FMAxis(FMindex);
    for n=(N*FMindex-N+1):(N*FMindex)
      TrialFM = find(Trial==n);
      SpikeTime = Time(TrialFM);
      for c = startC:(startC+numC)
          index = find((SpikeTime>c/FM)&(SpikeTime<(c+1)/FM));
          if isempty(index)
             latency1 = 0
          else
             latency1 = min(SpikeTime(index));
          end
         latencyFM = [latencyFM mod(latency1,1/FM)];
      end
      if FMindex == FMi
          figure(9);
          hist(latencyFM,binspercyc);
          title('1st latency hist');
      end
    end
    latencyall = [latencyall, latencyFM];
    LATE.latency1(FMindex) = mean(latencyFM);
end

figure(10)
semilogx(FMAxis, LATE.latency1,'g');
ylabel('latency (s)');

figure(1);
% plot(MTF.rasterTime,MTF.rasterTrial,'r.');
plot(latencyall,1:1500,'r.');
title('1st spike Raster');
axis([0 0.2 1 1500]);

    
