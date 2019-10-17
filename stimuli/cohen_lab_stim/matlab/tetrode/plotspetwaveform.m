function [waveform]=plotspetwaveform(spetfn,N,color)

if nargin<3
    color='b';
end    
if nargin<2
    N=100;
end    
id=findstr(spetfn,'u');
tetrodedatafn=[spetfn(1:id-1) '.dat'];
tetrodedataalignedfn=[spetfn(1:id-1) 'Aligned.dat'];
load(spetfn);
if exist(tetrodedatafn,'file')
   load (tetrodedatafn,'-mat');
   index=find(ismember(TetrodeData.SpetAligned,spet));
   waveform=TetrodeData.SnipAligned(index,:,:); 
elseif exist(tetrodedataalignedfn,'file')
   load (tetrodedataalignedfn,'-mat');
   index=find(ismember(TetrodeDataAligned.Spet,spet));
   waveform=TetrodeDataAligned.Snip(index,:,:); 
end   

plotwaveform(waveform,N,color)



