function colHeaders = mkColHeaders

INCLUDE_DEFS;

colHeaders = cell(NUMATTRIBUTES,1);

colHeaders{FILENAME} = 'filename';
colHeaders{CF} = 'CF';
colHeaders{THRESHOLD} = 'threshold';
colHeaders{SPONT_EST} = 'spontaneous est';  % in spikes per second
colHeaders{SPONT_STD} = 'spontaneous std';  % in spikes per second

colHeaders{LATENCY} = 'latency';
colHeaders{MAXRATE} = 'max rate';
colHeaders{MAXRATECF} = 'max rate @ CF';
colHeaders{MAXRATECFAMP} = 'max rate @ CF amp';
colHeaders{RATESLOPE1} = 'rate slope 1';
colHeaders{RATESLOPE2} = 'rate slope 2';
colHeaders{NONMONOTONIC} = 'non-monotonic';
colHeaders{AMPATTRANS} = 'amp @ trans pt';

colHeaders{PK1PK} = 'peak 1st peak';
colHeaders{PK1END} = 'end 1st peak';
colHeaders{PK2START} = 'start 2nd peak';
colHeaders{PK2END} = 'end 2nd peak';
colHeaders{DEPTH} = 'depth';
colHeaders{ATTENC} = 'contra atten';
colHeaders{ATTENI} = 'ipsi atten';
colHeaders{UNITNUM} = 'penetration no';
colHeaders{FILEDATE} = 'creation time';

colHeaders{RATETHRESH} = 'thresh (fr rate)';
colHeaders{RATEATTRANS} = 'rate @ trans pt';
colHeaders{AMPATFADE} = 'amp @ fade';

INFOS = [INFO10 INFO20 INFO30 INFO40];
for ii=1:length(INFOS),
    colHeaders{INFOS(ii)+OFFSETQ} =    ['Q @ ' num2str(10*ii) ' dB'];
    colHeaders{INFOS(ii)+OFFSETA} =    ['lo bdedge @ ' num2str(10*ii) ' dB'];
    colHeaders{INFOS(ii)+OFFSETB} =    ['hi bdedge @ ' num2str(10*ii) ' dB'];
    colHeaders{INFOS(ii)+OFFSETBW} =   ['bandwidth @ ' num2str(10*ii) ' dB'];
    colHeaders{INFOS(ii)+OFFSETASYM} = ['psbd asym @ ' num2str(10*ii) ' dB'];
  end;
  
return

