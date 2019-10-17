function [EXRAStt, EXRASspet]=onsetexpand(RAStt,FMAxis,N,Nex, Fsd)

EXRAStt.trial = [];
EXRAStt.time = [];
for k=1:length(FMAxis)
    for n=1:RAStt.N
      expandTime = [];  % raster for a specific FM
      spetTime = RAStt.time(find(RAStt.trial==(n+(k-1)*RAStt.N)));
      for ishift=0:Nex
        shiftTime = spetTime + ishift*1/FMAxis(k);
        expandTime = [expandTime shiftTime];
      end % of ishift
      EXRAStt.trial = [EXRAStt.trial (n+(k-1)*RAStt.N)*ones(1,length(expandTime))];
      EXRAStt.time = [EXRAStt.time expandTime];
    end  % of n
%     binW = 1/FMAxis(k)/binspercyc;  % width of bin in sec
%     PSTH(k).hist = histc(expandTime,[0:binW:max(expandTime)]);
%     
%     figure(100+k);
%     % bar((0:binspercyc)/binspercyc/FMAxis(k),CYCH(k).hist)
%     hist(expandTime,[0:binW:max(expandTime)]);
%     title(['Expand PSTH for' num2str(FMAxis(k)) ' Hz']);
%     xlabel('Time (s)');
    
 
%     if isempty(Tresp)
%         Tresp=TD
%     end
%     MTF.Rate(k)=length(rasterFM)/TD/N;
%     MTF.Spetnorm(k) = length(rasterFM)/N;
end  % of k

[EXRASspet] = rastertimetrial2spet(EXRAStt,Fsd)