%
%function  [Data]=ncsconcatenateblock(DataBlocked,Blockindex)
%
%DESCRIPTION: Concatenates data blocks from an NCS file
%
%   DataBlocked : Data structure containg blocked NCS data
%   Blockindex  : Blocks to concatenate
%
%RETURNED VARIABLE
%
%   Data        : Structure containing concatenated data
%
%Monty A. Escabi, Sept 2008
%
function  [Data]=ncsconcatenateblock(DataBlocked,Blockindex)

for chan=1:length(DataBlocked)           %Looping over different data channels
   
    %Initializing Variables
    clear Y1
    
    for block=Blockindex     %Looping over different Blocks

            %Extracting Data for each block
            Y=DataBlocked(chan).Block(block).X;
            Fs=DataBlocked(chan).Fs;

            %Generating Window
            W=window(4006,2,length(Y)/Fs*1000,100);
            N=floor(length(Y)/2);
            if length(Y)/2==floor(length(Y)/2)
                W=[W(1:N)  W(N:-1:1)];
            else
                   W=[W(1:N) W(N)  W(N:-1:1)];
            end
            index=max(find(W(1:N)<0.5));

            %Appending Windowed Data Segments                   
            if ~exist('Y1')
                Y1=W.*Y;
            else
                Y2=[ zeros(1,length(Y1)-index*2) W.*Y];     
                Y1=[Y1 zeros(1,length(W)-index*2)];
                Y1=Y1+Y2;
            end
        
    end
        
    %Appending Channel Data to Structure

        Data(chan).ADBitVolts=DataBlocked(chan).ADBitVolts;
        Data(chan).Fs=Fs;
        Data(chan).ADChannel=chan;
        Data(chan).X=Y1;
        
        %Notes for ADBitVolts:
        % This scaling factor is required to convert singal amplitudes to 
        % Volts. The actual amplitude values obtained using "NlxCscFile2WavAudioFileConverter_v200"
        % are incorect and require the above normalization. Once this is
        % done the singal amplitudes match those obtained using the
        % alternative WAV conversion READALLNCS as well as the graphical
        % display using "NlxCscFile2WavAudioFileConverter_v200"
        %
        % (Escabi/Jake May 2007)
        
end