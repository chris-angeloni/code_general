function [Datal,Datah]=sortbythes(Data,thre)

inlow = find(max(Data.Snips(:,:))<=thre);

% in=[]; 
% for i=1:size(Data.Snips,2)
%  if find(Data.Snips(:,i)==max(Data.Snips(:,i)))>=thre
%      in = [in i];
%  end
% end

Datal.Fs=Data.Fs;
Datal.SnipTimeStamp=Data.SnipTimeStamp(inlow);
Datal.Trig=Data.Trig;
Datal.SortCode=Data.SortCode(inlow);
Datal.Snips=Data.Snips(:,inlow);

inhigh = find(max(Data.Snips(:,:))>thre);

% in=[]; 
% for i=1:size(Data.Snips,2)
%  if find(Data.Snips(:,i)==max(Data.Snips(:,i)))>=thre
%      in = [in i];
%  end
% end

Datah.Fs=Data.Fs;
Datah.SnipTimeStamp=Data.SnipTimeStamp(inhigh);
Datah.Trig=Data.Trig;
Datah.SortCode=Data.SortCode(inhigh);
Datah.Snips=Data.Snips(:,inhigh);