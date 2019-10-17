[Data1]=sortbythes(Data,thre)

index=find(max(Data.Snips(:,:))>=thre)
Data1.Fs=Data.Fs;
Data1.SnipTimeStamp=Data.SnipTimeStamp(in);
Data1.Trig=Data.Trig;