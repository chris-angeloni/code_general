function moviePopup

INCLUDE_DEFS;

global tcMovie latencies fMin nOctaves extAtten

hobj = gcbo;

hdur = findobj('tag','DurationSlider');
duration = get(hdur,'value');
hstart = findobj('tag','StartSlider');
hsc = findobj('tag','ScalePopup');
hst = findobj('tag','ScaleText');
hmenu = findobj('tag','DisplayMenu');
hoptions = get(hmenu,'children');
dispType = get(hoptions(strcmp('on',get(hoptions,'Checked'))),'Tag');

hax = findobj('tag', 'TuningCurveAxes');
axes(hax);

labelpos = axis;
labelxpos = 10^(log10(labelpos(1)) + ... 
                 (log10(labelpos(2)) - ...
                  log10(labelpos(1)) ...
                  )*0.05 ...
                );
labelypos = labelpos(3)+(labelpos(4)-labelpos(3))*0.05;
labelpos = [labelxpos labelypos];

if (get(hobj,'value') == 1),   % film the movie
    nframes = ceil(100/(duration/2));
    lastScale = get(hsc,'value');
    lastFixedVal = get(hst, 'string');
    if lastScale == 2,     % (then in float mode)
        maxSpikes = -Inf;
        for ii=1:nframes,
          tstart = (ii-1)*(duration/2);
          dataMat = makeDataMat(latencies, tstart, tstart+duration/2);
          switch dispType
            case {'ColorOption','SurfaceOption'},
                 [displayMat, dispFreqs, dispAmps] = ...
                 makeDisplayMat(dataMat, extAtten, fMin, nOctaves);
            case {'LinesOption','Lines2Option','ContourOption'},
                 displayMat = dataMat;
            otherwise,
            end  %(switch)
          maxSpikes = max(maxSpikes, max(displayMat(:)));
          end
	      set(hsc,'value',1);
	      set(hst,'string',num2str(maxSpikes));
      else               % (in fixed mode, so don't need to figure out scaling)
      end % (if)
      
    switch dispType
      case {'ColorOption','SurfaceOption','ContourOption'},
           textColor = 'white';
      case {'LinesOption','Lines2Option'},
           textColor = 'black';
      otherwise,
      end  %(switch)
      
    tcMovie = moviein(nframes);
    for ii=1:nframes,
      tstart = (ii-1)*(duration/2);
      set(hstart,'value', tstart);
      updateFromSliders;
      refreshDisplay;
      axes(hax);
      text(labelpos(1), labelpos(2), num2str(tstart),'color',textColor); 
      tcMovie(:,ii) = getframe;
      end
    set(hstart,'value', 0);
    updateFromSliders;
    refreshDisplay;

    set(hsc,'value', lastScale);
    set(hst,'string',lastFixedVal);
      
  else                        % play the movie
    movie(tcMovie,1,2);
  end
  
return


