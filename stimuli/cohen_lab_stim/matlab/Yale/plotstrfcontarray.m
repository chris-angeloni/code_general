%
%function []=plotstrfcontarray(STRFData,STRFSigData,FileToView,channel)
%
%   FILE NAME   : PLOT STRF CONT ARRAY
%   DESCRIPTION : Plots all strfs across the array dimensions
%   
%   STRFData    : Data Structure containing the following elements
%                 .taxis   - Time Axis
%                 .faxis   - Frequency Axis (Hz)
%                 .STRF1A  - STRF for channel 1 on trial A
%                 .STRF2A  - STRF for channel 2 on trial A
%                 .STRF1B  - STRF for channel 1 on trial B
%                 .STRF2B  - STRF for channel 2 on trial B
%                 .STRF1As - Phase Shuffled STRF for channel 1 on trial A
%                 .STRF2As - Phase Shuffled STRF for channel 2 on trial A
%                 .STRF1Bs - Phase Shuffled STRF for channel 1 on trial B
%                 .STRF2Bs - Phase Shuffled STRF for channel 2 on trial B
%                 .SPLN  - Sound Pressure Level per Frequency Band
%  STRFSigData : Data structure containing bootstrapped shuffled STRF for significance testing
%  FileToView  : Experiment file number (1, 2, or 3; correspond to July 27, 28, 29 respectively)
%  channel     : STRF channel, 1=contra, 2=ipsi
%
% (C) Monty A. Escabi, August 2010
%
function []=plotstrfcontarray(STRFData,STRFSigData,FileToView,channel)

switch FileToView
   case {1,2} 
        Channel2Location = [1   15      29      43      99      113     127     141     57      71      85      155     169     183
        2       16      30      44      100     114     128     142     58      72      86      156     170     184
        3       17      31      45      101     115     129     143     59      73      87      157     171     185
        4       18      32      46      102     116     130     144     60      74      88      158     172     186
        5       19      33      47      103     117     131     145     61      75      89      159     173     187
        6       20      34      48      104     118     132     146     62      76      90      160     174     188
        7       21      35      49      105     119     133     147     63      77      91      161     175     189
        8       22      36      50      106     120     134     148     64      78      92      162     176     190
        9       23      37      51      107     121     135     149     65      79      93      163     177     191
        10      24      38      52      108     122     136     150     66      80      94      164     178     192
        11      25      39      53      109     123     137     151     67      81      95      165     179     193
        12      26      40      54      110     124     138     152     68      82      96      166     180     194
        13      27      41      55      111     125     139     153     69      83      97      167     181     195
        14      28      42      56      112     126     140     154     70      84      98      168     182     196];
    case 3
        Channel2Location = reshape([1:1:196],14,14);        
    otherwise
        error(['bad option...tsk tsk'])
end
%Channel2Location=Channel2Location(1:2:14,1:2:14);
Channel2Location=flipud(Channel2Location);	%Flip to match maps
Nrow=size(Channel2Location,2);
Ncol=size(Channel2Location,1);

%Time and Frequency Axis
taxis=STRFData(1).taxis*1000;
faxis=STRFData(1).faxis;

%Plotting STRFs
Max=[-9999];
for n=1:196
           [l,k]=find(Channel2Location == n);

%            n=Channel2Location(k,l)
            if n<=length(STRFData)
                subplot(Ncol,Nrow,l+Nrow*(k-1))
                if channel==1 & isfield(STRFData,'STRF1B')
                    STRF=(mean(STRFData(n).STRF1A,3)+mean(STRFData(n).STRF1B,3))/2;
                elseif channel==1 & ~isfield(STRFData,'STRF1B')
                    STRF=mean(STRFData(n).STRF1A,3);
                elseif channel==2 & isfield(STRFData,'STRF2B')
                    STRF=(mean(STRFData(n).STRF2A,3)+mean(STRFData(n).STRF2B,3))/2;  
                elseif channel==2 & ~isfield(STRFData,'STRF2B')
                    STRF=mean(STRFData(n).STRF2A,3);
                end
		if channel==1
			sigma=STRFSigData(n).sigma1;
		else 
			sigma=STRFSigData(n).sigma2;
		end
		Max=max(max(max(abs(STRF/sigma))),Max);
                imagesc(taxis,log2(faxis/faxis(1)),STRF/sigma)
		xlim([-10 100])

		set(gca,'XTick',[])
		set(gca,'YTick',[])
		%set(gca,'Visible','off')
                set(gca,'YDir','normal')
            end
end
Max=10
for k=1:Nrow
	for l=1:Ncol
                subplot(Ncol,Nrow,l+Nrow*(k-1))
		caxis([-Max Max])
		Pos=get(gca,'pos')
		dx=0.013;
		dy=0.016;
		set(gca,'pos',[Pos(1)-dx*(l-1) Pos(2)+dy*(k-1) Pos(3) Pos(4)])
	end
end

Max
