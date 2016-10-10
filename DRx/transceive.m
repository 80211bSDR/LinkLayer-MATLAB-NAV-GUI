function [dr,ns] = transceive(d2s,ft,IpAddr,txGain, rxGain, centerFreqTx, centerFreqRx, intFactor, decFactor)
persistent hrx htx; 
dr = complex(zeros(1408,1));
ns = uint32(0);
if isempty(htx)
    htx = comm.SDRuTransmitter('CenterFrequency',centerFreqTx,'Gain',txGain, ...
        'InterpolationFactor',intFactor,'IPAddress',IpAddr, ...
        'LocalOscillatorOffset',0);
end
if isempty(hrx)
    hrx = comm.SDRuReceiver('CenterFrequency',centerFreqRx, ...
        'DecimationFactor',decFactor,'FrameLength',1408,'Gain',rxGain, ...
        'IPAddress',IpAddr,'OutputDataType','double', ...
        'SampleRate',2e5);
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