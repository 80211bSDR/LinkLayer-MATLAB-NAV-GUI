%% 802.11b PHY Initialization
% setting global variables
global spreadFactor numPayloadBits numMpduBits numUsrpBits numMacHdrBits usrpFrameLength ...
    halfUsrpFrameLength doubleUsrpFrameLength numBits80211b ...
    halfSamples80211b samplingRate crosscorr_thresh choice numSuperFrameBits ...
    numSuperBits numFcsBits numPhyHdrBits upFactor numSuperSamples80211b ...
    halfSuperSamples80211b numAckBits DIFS tFreeze cMin energyThreshold intFactor ...
    txGain rxGain centerFreqTx centerFreqRx decFactor vm vcsChoice

% vm: Verbose Mode: Displays additional text describing DRx actions
if choice == 1
    vm  = logical(true(1));
else
    vm  = logical(false(1));
end


%Set flag for Virtual Carrier Sensing
vcsChoice  = logical(true(1));

% adcRate: ADC Rate
adcRate = 100e6; 
% intFactor: USRP Interpolation Rate  				
intFactor = 500;   
% decFactor: Decimation Factor
decFactor = 500;
% txGain: Tranmitter Gain used in transceive()
txGain = 15;
% rxGain: Receiver Gain used in transceive()
rxGain = 20;
% Tx Center Frequency
centerFreqTx = 1.284e9;
% Rx Center Frequency
centerFreqRx = 1.284e9;
% upFactor: RCF Upsampling Factor				
upFactor = 2;
% spreadFactor: DSSS Spreading Factor     				
spreadFactor = 11;
% cfeFreqResolution: CFE Frequency Resolution				
cfeFreqResolution = 100;			

% numPhyHdrBits: number of bits in PHY Header
numPhyHdrBits = 192;
% numSyncBits: number of SYNC bits
numSyncBits = 128;
% numSfdHeaderBits: number of SFD+header bits (64PHY + 64 MAC)				
numSfdHeaderBits = 128;
% numFcsBits: number of FCS bits			
numFcsBits = 32;
% numPayloadBits: number of payload bits			
numPayloadBits = 16096;
% numUsrpBits: number of USRP bits				
numUsrpBits = 64;
% numFrameCtlBits: number frame control bits
numFrameCtlBits = 16;
% numDurationIdBits: number of duration id bits
numDurationIdBits = 16;
% numAddress1Bits: number address1 bits
numAddress1Bits = 48;
% numAddress2Bits: number of address 2 bits
numAddress2Bits = 48;
% numAddress3Bits: number of address 3 bits
numAddress3Bits = 48;
% numSequenceCtlBits: number of sequence control bits
numSequenceCtlBits = 16;
% numAddress4Bits: number of address 4 bits
numAddress4Bits = 48;
% numMacHdrBits: Number of bits in MAC Header
numMacHdrBits = numFrameCtlBits+numDurationIdBits+numAddress1Bits+numAddress2Bits+numAddress3Bits+numSequenceCtlBits+numAddress4Bits;
% numMpduBits: MAC Hdr+Payload+FCS
numMpduBits = numMacHdrBits + numPayloadBits + numFcsBits;
% numBits80211b: bits per 802.11b frame = #preamble bits + #header bits + #Payload bits + #FCS bits						
numBits80211b = numPhyHdrBits+numMpduBits;
% numSuperBits: value of bits to append to total 80211b frams, to meet req
numSuperBits = 16;
% numSuperFrameBits: append 16 zeros to satisfy USRP frame 'multiples of 64bit' requirement
numSuperFrameBits = numBits80211b+numSuperBits;
% numOctets80211b: Octets in our 802.11b frame
numOctets80211b = numBits80211b/8; 
% numOctetsSuperFrame: Octets in our Superframe
numOctetsSuperFrame = numSuperFrameBits/8; 

% ACK size
% numAckBits: number of bits in the ACK
numAckBits = 176;

%% Derived PHY Parameters
% samplingRate: samplnig rate ADC Rate/ USRP Interpolation Rate
samplingRate = adcRate/intFactor;
% fftSize: Sampling Rate/ CFEFrequencyResolution	
fftSize = samplingRate/cfeFreqResolution;
% usrpFrameLength: samples per USRP frame rate. Each bit is mapped to 22 samples 
usrpFrameLength = numUsrpBits*upFactor*spreadFactor;
% halfUsrpFrameLength: usrpFrameLength/2
halfUsrpFrameLength = usrpFrameLength/2;
% doubleUsrpFrameLength: usrpFrameLength*2
doubleUsrpFrameLength = usrpFrameLength*2;	

%% MAC Parameters
%DIFS = 5 millisec for each Frame
DIFS = 5e-3;
%Freeze Time
tFreeze = 2e-3;
%cmin: minimum contention window size
cMin = 5e-3;
%Energy Threshold to be set using AGC's output
%Fixed for now
energyThreshold=100;


%% Derive System Parameters
%USRP/802.11b frame
% numSamples80211b: samples per 802.11b frame
numSamples80211b = numBits80211b*upFactor*spreadFactor;
% halfSamples80211b: numSamples80211b/2
halfSamples80211b = numSamples80211b/2;
% numSamplesUsrp: samples per USRP frame = USRP frame rate
numSamplesUsrp = usrpFrameLength;	

%Derivations for Super80211bFrame (80211b bits padded with 16 bits)
% numSamples80211b: samples per 802.11b frame
numSuperSamples80211b = numSuperFrameBits*upFactor*spreadFactor;
% halfSamples80211b: numSamples80211b/2
halfSuperSamples80211b = numSuperSamples80211b/2;

%Slot Time
% slotTime: milisecond value of USRP Frame Length
slotTime = usrpFrameLength/samplingRate;	

%Preamble Detection
% crosscorr_thresh: cross correlation threshold value
crosscorr_thresh = 0.25;

%Time Out
% to:  Timeout: The #iterations of the main loop to wait before exiting.
to  = uint32(8000);
% toa: Timeout ACK: #iterations to wait for an ACK before resending DATA
toa = uint32(4000);