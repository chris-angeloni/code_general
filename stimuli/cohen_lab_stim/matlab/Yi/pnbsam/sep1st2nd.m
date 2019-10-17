% DESCRIPTION   : Seperate onset and sustained components based on the
% distribution of 1st and 2nd spikes
% Bound(1,FMi) = min(bound1st, bound2nd);bound1st = max(sort1st);bound2nd =
% min(SPET2(FMi).nd(find(SPET2(FMi).nd>0)));

function [Bound,RASonset,RASsus]=sep1st2nd(SPET2,RASspet,FMAxis,Flag,stimmod,onset,num)

% SPET2     % 1st spet time and 2nd spet time, getting from
% firstvs2ndspet.m
N = length(RASspet)/length(FMAxis);
Bound=zeros(1,length(FMAxis));
for FMi = 1:length(FMAxis)
   sort1st = sort(SPET2(FMi).st);
   sort1st = sort1st(find(sort1st>0.005));
   isi1st = diff(sort1st);
   if max(isi1st)<0.002   % if isi is too small, can not seperate it
       bound1st = max(sort1st);
   else
      i = min(find(isi1st == max(isi1st)));  % if there are two max(isi1st),pick up the 1st
      bound1st = (sort1st(i)+sort1st(i+1))/2;
   end
   if isempty(SPET2(FMi).nd(find(SPET2(FMi).nd>0)))
       bound2nd = 0;
       if isempty(bound1st)
           Bound(1,FMi)=0.02;
       else
       Bound(1,FMi) = bound1st;
       end
   else
      bound2nd = min(SPET2(FMi).nd(find(SPET2(FMi).nd>0)));
      Bound(1,FMi) = min(bound1st, bound2nd);
      % Bound(1,FMi) = bound1st
   end
 end  % end of FMindex
% Bound(1,1:length(FMAxis))=0.022;
Bound(1,1:8)=0.022;
Bound(1,9:18)=0.017;
 BoundL(1,1:length(FMAxis))=0.014;
 BoundL(1,16:18)=0.0125;
% BoundL(1,1:10)=0.003
 % Bound < 25 ms
% Bound(find(Bound>0.025))=0.02

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
RAStt.time = [];
RAStt.trial = [];
for k=1:length(RASspet)
    RAStt.time = [RAStt.time RASspet(k).spet/RASspet(k).Fs];
    RAStt.trial = [RAStt.trial k*ones(size(RASspet(k).spet))];  
end
RAStt.N = length(RASspet)/length(FMAxis);

% [RAS1tt,RAS1spet,RAS2tt,RAS2spet]=raster1stspet(RAStt,RASspet,FMAxis,Flag,stimmod,onset,num)
% 
% for FMindex=1:length(FMAxis)
%    for k=(RAS1tt.N*(FMindex-1)+1):(RAS1tt.N*FMindex)
%     if RAS1spet(k).spet/RAS1spet(k).Fs < Bound(FMindex)
%        RASonset(k).spet = RAS1spet(k).spet;
%        RASsus(k).spet = RAS2spet(k).spet;
%     else
%        RASonset(k).spet = [];
%        RASsus(k).spet = [RAS1spet(k).spet RAS2spet(k).spet]
%     end  % end of if
%    end  % end of k
% 
% end  % end of FMindex

for FMindex=1:length(FMAxis)
   for k=(RAStt.N*(FMindex-1)+1):(RAStt.N*FMindex)
      indexO=find(RASspet(k).spet/RASspet(k).Fs<Bound(FMindex)& RASspet(k).spet/RASspet(k).Fs>BoundL(FMindex))
      RASonset(k).spet = RASspet(k).spet(indexO)
      indexS=find(RASspet(k).spet/RASspet(k).Fs<BoundL(FMindex)|RASspet(k).spet/RASspet(k).Fs>Bound(FMindex))
      RASsus(k).spet = RASspet(k).spet(indexS)
   end
end

RASonsettt.time =[]
RASonsettt.trial=[]
for k=1:length(RASonset)
    RASonset(k).Fs = RASspet(k).Fs;
    RASonset(k).T = 1/FMAxis(ceil(k/N));
    RASonsettt.time = [RASonsettt.time RASonset(k).spet/RASonset(k).Fs];
    RASonsettt.trial = [RASonsettt.trial k*ones(size(RASonset(k).spet))];  
end

RASsustt.time =[]
RASsustt.trial=[]
for k=1:length(RASsus)
    RASsus(k).Fs = RASspet(k).Fs;
    RASsus(k).T = 1/FMAxis(ceil(k/N));
    RASsustt.time = [RASsustt.time RASsus(k).spet/RASspet(k).Fs];
    RASsustt.trial = [RASsustt.trial k*ones(size(RASsus(k).spet))];  
end

Timebound = [];
    for k=1:length(FMAxis)
      Timebound = [Timebound Bound(k)*ones(1,100)];
    end
% plot(RAStt.time,RAStt.trial,'b.',Timebound,1:length(RASspet),'r');
figure(5)
plot(RASonsettt.time, RASonsettt.trial,'g.');
hold on
Timebound = [];
    for k=1:length(FMAxis)
      Timebound = [Timebound 1/FMAxis(k)*ones(1,RAStt.N)];
    end
plot(RASsustt.time, RASsustt.trial,'.r',Timebound,1:length(RASspet),'r');