function []=ntcplot(fileroot,minlat,maxlat)

%plots tuning curves along the diagonal, to correspond with an autocorrelogram figure diagonal.
% fileroot is the ntc.mat filenames, up to the datfile number, e.g. 'c811_t1f22'.  All ntc.mat 
% files for those datfiles will be plotted.   
%
%		[]=ntcplot(fileroot,minlat,maxlat);


%minlat=6;
%maxlat=20;
NFREQS = 45;                            % # of frequencies in tuning curve
NAMPS = 15;                             % # of amplitudes in tuning curve

chnls = [];
for ii = 1:8				% determine which dat channels were recorded
   filestring = [fileroot '_ch' num2str(ii) '_u1_ntc.mat'];
   if exist(filestring) == 2
      chnls(length(chnls)+1) = ii;
   end
end %for ii


% Make a list of all ntc files for the datfile specified in fileroot input argument.
filenames = {};
unit_names = {};
for k = 1:length(chnls)		%count the total number of plots to make
      unitcounter = 1;
      queryfile = [fileroot '_ch' num2str(chnls(k)) '_u1_ntc.mat'];
      while exist(queryfile) == 2
         unit_names{length(unit_names)+1} = ['ch' num2str(chnls(k)) 'u' num2str(unitcounter)];
%         filenames{length(filenames)+1} = queryfile;
         eval(['load ' queryfile]);
         [dummyMat] = makeDisplayMatLee(latencies,minlat,maxlat,NFREQS,NAMPS);		%from latencies, prepare tc display array
         eval(['displayMat_' unit_names{length(unit_names)} '_' unit_names{(length(unit_names))} ' = dummyMat;']);
         unitcounter = unitcounter +1;
         clear latencies;
         queryfile = [fileroot '_ch' num2str(chnls(k)) '_u' num2str(unitcounter) '_ntc.mat'];
      end
end
side = length(unit_names);


%create all ch#u# filename combinations to be displayed
for ii=1:length(unit_names)
   for jj= ii:length(unit_names)
       if ii~=jj	%i.e. if it's not an individual tc, then calculate the disparity tc
          eval(['tc1 = displayMat_' unit_names{ii} '_' unit_names{ii} ';']);
          eval(['tc2 = displayMat_' unit_names{jj} '_' unit_names{jj} ';']); 
          tcout = tc_disparity(tc1,tc2);		%calculate disparity tc, and then rename it properly
          eval(['displayMat_' unit_names{ii} '_' unit_names{jj} ' = tcout;']);
          clear tc1 tc2 tcout;
       end %if ii
   end %for jj
end %for ii   



% if there are too many plots, break them up into three figures
if side > 8
   m = floor(side/2);
   n = side - m;  
   numfigs = 3;
   index_array = [1   n    1   n;		%the x and y indices for subplots
   		  m+1 side m+1   side;    	% in each of the three figures
   		  m+1 side 1   n    ];

else
   numfigs = 1;
   index_array = [1 side 1 side];       %the x and y indices for subplots (one figure)
end %if side
%end condition of too many plots


displayMat=[];

for k = 1:numfigs		%load up files and plot each, along the diagonal
   istart = index_array(k,1);
   iend   = index_array(k,2);
   jstart = index_array(k,3);
   jend   = index_array(k,4);
   plots_wide = iend - istart + 1;
   figure;set(gcf,'Position',[10 150 1200 700]);

   for i = istart:iend
      for j = jstart:jend
         displayMatName = ['displayMat_' unit_names{j} '_' unit_names{i}];
         if exist(displayMatName) == 1			 %if this is one of the tc's we have created
            eval(['displayMat = ' displayMatName ';']);		%rename generically
	    subplot(plots_wide,plots_wide,((i-istart+1)-1)*plots_wide+(j-jstart+1));

	    DISP_DEFAULT_AMPS = 2.5+((0:15)-0.5)*5; % (5 dB steps);
	    fmmax = fMin*(2^((nOctaves*(NFREQS-0.5))/(NFREQS-1)));
	    fmmin = fMin*(2^(nOctaves*(-0.5)/(NFREQS-1)));
	    dispFreqs = logspace(log10(fmmin), log10(fmmax),NFREQS+1);
	    dispAmps = DISP_DEFAULT_AMPS;

	    view([0 90]);

	    pcolor(dispFreqs,dispAmps,displayMat');
	    
	    shading flat;

	    set(gca,'xscale','log');
	    set(gca,'yscale','linear');
	    set(gca,'tickdir','out');
	    set(gca,'ytickmode','auto');
	    set(gca,'yticklabelmode','auto');
	    tickRange = 10.^(floor(log10(dispFreqs(1))):floor(log10(dispFreqs(end))));
	    xTickPos = [1 2 5]'*tickRange;
	    xTickPos = [xTickPos(:); 10*tickRange(end)];
	    ii = find(xTickPos>dispFreqs(1) & xTickPos<dispFreqs(end));
	    xTickPos = xTickPos(ii);
	    set(gca,'xtick', xTickPos);
            colorbar('vert');
            h=colorbar;set(h,'Fontsize',8);

            if ~strcmp(unit_names{j},unit_names{i})	%reset scaling for off-diagonal (disparity) plots
               scalemax = max((max(max(abs(displayMat)))),.01);
               caxis([-scalemax scalemax]);
               negDisparity = round(sum(sum(displayMat(find(displayMat<0))))/2);	%divided by 2 so it's comparable to pos
               posDisparity = round(sum(sum(displayMat(find(displayMat>0)))));
               h=colorbar;set(h,'Visible','off');		%don't display colorbar numbers.
               %title([num2str(negDisparity) '  ' num2str(posDisparity)]);
            else					%if diagonal plot, print title ch#u#
               title([unit_names{i}]);
            end %if strcmp

	    if i==iend				%label only the bottom row
               xlabel(unit_names{j});
	    end
	    if j==jstart			%label only the left column
               ylabel(unit_names{i});
	    end

            set(gca,'Fontsize',8);            
            clear displayMat;
         end %if exist
      end %for j
   end %for i

   g=uicontrol(gcf,'Style','text','Units','Normalized', ...
      'Position',[.65 .95 .3 .03], ...
      'FontSize',16,...
      'String',[fileroot '    ' num2str(minlat) '-' num2str(maxlat) 'ms    Fig.' ...
                  num2str(k) ' of ' num2str(numfigs)]);
    g=uicontrol(gcf,'Style','text','Units','Normalized', ...
      'Position',[.01 .48 .03 .055], ...                    
      'FontSize',14,...
      'String',['Int. (dB)']);               

    g=uicontrol(gcf,'Style','text','Units','Normalized', ...
      'Position',[.41 .01 .08 .03], ...                    
      'FontSize',14,...
      'String',['Freq. (kHz)']);               



end %for k


