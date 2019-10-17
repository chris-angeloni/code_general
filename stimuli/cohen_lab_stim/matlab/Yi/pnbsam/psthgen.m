% function [PSTH]= psthgen(RASspet,Flag,FMAxis,Onset,num,N)

%  DESCRIPTION      : Generate PSTH (same duration)
% Yi Zheng, Jan 2007
function [PSTH]= psthgen(RASspet,Flag,FMAxis,Onset,num,N)

for k = 1:length(FMAxis)
   spet = [];
   % binW = 1/FMAxis(k)/binspercyc;  % width of bin in sec
   binW = 0.1/25;
   for n=1:N
     spet = [spet RASspet((k-1)*N+n).spet];
   end
   Tspet = spet./RASspet(k).Fs;  % spet time
   
   if (Flag == 0 | Flag ==1)
     Time=Tspet(find( (Tspet>=Onset)&(Tspet<=(Onset+num)) ));
   else (Flag==2)
     Time = Tspet; 
   end  % end of if
   
   if isempty(Time)
       PSTH =0;
   else
     PSTH = histc(Time,[Onset:binW:(Onset+num)]);
     PSTH = PSTH/N;   
     figure(20+k);
    bar((Onset/binW:(Onset+num)/binW)*binW,PSTH);
    title(['PSTH for' num2str(FMAxis(k)) ' Hz']);
    axis([0 Onset+num 0 1])
    xlabel('Time (s)');
    ylabel('spike counts')
   end  % end of isempty(Time)
end  % end of k

for k=1:length(FMAxis)
 
end
