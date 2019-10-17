%
%function  [Data]=wav2ncsdata(header)
%
%DESCRIPTION: Reads an NCS file and returns data as a data structure
%
%   header    : Experiment header / name
%
%Monty A. Escabi, April. 2005 (Edit May 2007)
%
function  [Data]=wav2ncsdata(header)

%Initialize Counter for Data Structure Index
count=1;

for chan=1:16           %Looping over different data channels
   
    %Initializing Variables
    clear Y1
    
    for block=65:90     %Looping over different Blocks
        
        %Naming File
        Filename=[header 'ch' int2str(chan) setstr(block) '.wav'];
        
            %Loading data and appending to data structure
            if exist(Filename)==2
        
                    %Reading Data
                     [Y,Fs]=wavread(Filename);
           
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
                            Y1=W.*Y';
                    else
                            Y2=[ zeros(1,length(Y1)-index*2) W.*Y'];     
                             Y1=[Y1 zeros(1,length(W)-index*2)];
                             Y1=Y1+Y2;
                     end
                
            end
      
        end
        
       %Appending Channel Data to Structure
        if  exist('Y1')
            Data(count).ADGain=1;
            Data(count).ADBitVolts=.00000097704*2048;
            Data(count).Fs=Fs;
            Data(count).ADChannel=chan;
            Data(count).X=Y1;
            count=count+1;
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





