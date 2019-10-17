function [Tetrode]=tdt2tetrode(TankFileName,BlockNumber,TetrodeNumber,ServerName)

%Input Args
if nargin<4
    ServerName='Local';
end

%Select Tetrode Channels
if length(TetrodeNumber)==1
    if TetrodeNumber==1
        ChannelNumber=[2 3 5 7];
    elseif TetrodeNumber==2
        ChannelNumber=[1 6 4 8];
    elseif TetrodeNumber==3
        ChannelNumber=[12 10 15 14];
    else
        ChannelNumber=[13 9 16 11];
    end
end


for k=1:4
    %Read Data Tank
    Data=readtankv66(TankFileName,BlockNumber,ChannelNumber(k),ServerName);
    Tetrode(k)=Data;
    %Clearing Temporary Variables
    clear Data
end

