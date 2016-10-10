function [dr,ns] = transceive102(d2s,ft,txGain,rxGain,centerFreqTx,centerFreqRx,intFactor,decFactor,swapFreqFlag)
persistent hrx htx; 
dr = complex(zeros(1408,1));
ns = uint32(0);
if isempty(htx)
    htx = comm.SDRuTransmitter('CenterFrequency',centerFreqTx,'Gain',txGain, ...
        'InterpolationFactor',intFactor,'IPAddress','192.168.10.2', ...
        'LocalOscillatorOffset',0);
end
if isempty(hrx)
    hrx = comm.SDRuReceiver('CenterFrequency',centerFreqRx, ...
        'DecimationFactor',decFactor,'FrameLength',1408,'Gain',rxGain, ...
        'IPAddress','192.168.10.2','OutputDataType','double', ...
        'SampleRate',2e5);
end

%listening mode:
if abs(centerFreqTx-centerFreqRx)>0
    %if Rx and Tx is different, switch for Listening mode
    if swapFreqFlag
        hrx.CenterFrequency = centerFreqTx;
    else
        hrx.CenterFrequency = centerFreqRx;
    end
end

if (ft)
    release(hrx);
    release(htx);
else
    step(htx,d2s);
    while (ns < uint32(1))
        [dr,ns] = step(hrx); 
    end    
end
return;
end