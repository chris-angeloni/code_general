%
%function  [Data]=wav2ncsdatablocked(Header)
%
%   FILE NAME       : WAV 2 NCS DATA BLOCKED
%   DESCRIPTION     : Generates a NCS Data structure from individual WAV
%                     files. Data is organized into separate channels each
%                     containing various data blocks. Unlike WAV2NCSDATA
%                     the blocks are not concatenated together into a
%                     single data stream.
%
%   Header          : Experiment header
%
%OUTPUT SIGNAL
%
%   Data            : Data structure
%
% (C) Monty A. Escabi, December 2006 (Edit May 2007)
%
function  [Data]=wav2ncsdatablocked(Header)

%Initialize Counter for Data Structure Index
count=1;

for chan=1:16           %Looping over different data channels
    
    %Initializing Variables
    clear Y
    
    for block=65:90     %Looping over different Blocks
        
        %Naming File
        Filename=[Header 'ch' int2str(chan) setstr(block) '.wav'];
        
        %Loading data and appending to data structure
        if exist(Filename)==2
        
            %Reading Data
            [Y,Fs]=wavread(Filename);    
            
            %Appending Channel Data to Structure
            Data(count).Block(block-64).X=Y';
            Data(count).ADGain=1;
            Data(count).ADBitVolts=.00000097704*2048;
            Data(count).Fs=Fs;
            Data(count).ADChannel=chan;
                
        end
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
    
    %Incrementing Counter
    if exist('Y')
        count=count+1;
    end
    
end

