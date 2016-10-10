function drxPHYLayerVisual()

% This code is licensed under the LGPLv3 license. Please feel free to use the code in your research and development works. 
% We would appreciate a citation to the paper below when this code is helpful in obtaining results in your future publications.

% Publication for citation:
% Ramanathan Subramanian, Benjamin Drozdenko, Eric Doyle, Rameez Ahmed, Miriam Leeser, and Kaushik Chowdhury, 
% "High-Level System Design of IEEE 802.11b Standard-Compliant Link Layer for MATLAB-based SDR", accepted on March 3rd, 2016 
% for publication in IEEE Access Journal.

global vm aip addressIndex choice

%choice for data selection
% choice: 1 for random binary data of length l, 2 for image selection
choice = 2;

DRxInitParameters;

% Designated Receiver Parameter Structure
%prm = init_v35();
% aip: IP Address for USRP attached to this machine as a 3-Digit uint8
%      (as of 2/19/15, valid values for N210's in Lab are 102, 103, or 202)

aip = getipa();
% db: Data Blank (CONSTANT): To put on Tx Buffer while in a Rx major state
db  = complex(zeros(usrpFrameLength,1));
% c8f: Count of 802.11b Frames Recovered
c8f = uint16(0);
% cev: Count of Events: Counts #events in the Event Log, evl
cev = uint16(0);
% cni: Count #No-Action Iterations: Counts #iter in which no DATA Rx/ACK Tx
cni = uint16(0);
% cti: Count Total #Iterations: Counts #iterations of main WHILE loop
cti = uint16(0);
% df:  This USRP Data frame: The most-recently-received frame from USRP Rx Buffer
df  = complex(zeros(usrpFrameLength,1));
% dfl: Data Flagged: uint16 to accompany data, set when status flag is true
dfl = uint16(0); %#ok<NASGU>
% d2s: Data To Send: To put on Transmit Buffer while in a Tx Major State
d2s = complex(zeros(usrpFrameLength,1)); %#ok<NASGU>
% evl: Event Log: Records the cit and flg values when any flag is true
%      A matrix of size CEVx3, where each row represents a separate event
%      Col 1: Timestamp; Col 2: Flags Event Type; Col 3: Associated Data
evl = uint16(zeros(65535,3,'uint16'));
% fe: Flag End: Signals end-of-transmission; timeout or full image recovery
fe  = logical(false(1));
% ff: Flag Frame Check Sequence (FCS) Failure: if MPDU data fails CRC check
ff  = logical(false(1)); %#ok<NASGU>
% flg: Status Flags: a 4x1 logical aray, carrying the following flags:
% (1): fdf: Flag Detected Preamble: Set true if PLCP Preamble (SYNC) found
% (2): fph: Flag PLCP Header Found: Init false, set true if PHY Header rx'd
% (3): fec: Flag Error CRC: Init false, set true if PHY Header CRC in error
% (4): fmh: Flag MAC Header Found: Init false, set true if MAC Header rx'd
% (5): fpf: Flag All Payload Found: Init false, set true if all payload rxd
flg = logical(false(1,5)); %#ok<NASGU>
% ft: Terminal Flag to release System objects
ft  = logical(false(1));
% hfd: Handle to MAC FCS Detector
hfd = comm.CRCDetector('ChecksumsPerFrame',1,'FinalXOR',1, ...
    'InitialConditions',1,'Polynomial', ...
    [32,26,23,22,16,12,11,10,8,7,5,4,2,1,0]);
% it:  Iterator (Generic), used to iterate through FOR loop of <=65535 elem
it  = uint16(0); %#ok<NASGU>
% neb: #Expected MPDU Bits: Recovered from PLCP Header (LENGTH, bits 33-48, def. numMpduBits)
neb = uint16(0);
% nib: Total #Recovered Image Bits: Length of Data in rib, range 0-103,864
nib = {uint64(0),uint64(0)};
% nmb: Total #Recovered MPDU Bits: Length of Data in rfs, range 0-16,192
nmb = {uint16(0),uint16(0)};
% npb: Total #Recovered Payload Bits: nmb-len(hdr)-len(FCS), range 0-numPayloadBits
npb = {uint16(0),uint16(0)}; %#ok<NASGU>
% nsq: Number in Sequence: Recovered from MAC Header Info (bits 49-64)
nsq = uint16(0);
% nrb: Number of Recovered USRP MAC Bits: Length of Data in rbs, range 0-64
nrb = uint16(0); %#ok<NASGU>
% nti: Number of Timeout Iterations: #no-action iterations before exiting
nti = uint16(10000);
% rbs: Recovered Binary Sequence: Recovered from MPDU (MAC Data) (64 bits)
rbs_temp = zeros(64,1);
rbs = zeros(64,1); %#ok<PREALL>
% rms: Recovered MPDU Sequence for one 802.11b Frame: Combined from rbs's (16,192 bits)
rms = {zeros(numMpduBits+numSuperBits,1),zeros(numMpduBits+numSuperBits,1)};
% ri1: Recovered Image Height, or Number of Rows (expected 110)
ri1 = uint64(110); %prm.ImageExpectedHeight
% ri2: Recovered Image Width, or Number of Columns (expected 118)
ri2 = uint64(118); %prm.ImageExpectedWidth
% ri3: Recovered Image 3rd Dimension Size (expected 1 for grayscale image)
ri3 = uint64(1);   %prm.ImageExpectedDepth
% ril: Recovered Image Length: the Total Number of Bits Expected (103,864 bits)
ril = {uint64((ri1*ri2*ri3*uint64(8))+uint64(24)),uint64((ri1*ri2*ri3*uint64(8))+uint64(24))};
% rib: Recovered Full Binary Image Sequence: Concatenated from rfs's,
%      802.11b Frame Payloads, contains entire image data (103,864 bits)
rib = {zeros(ril{1},1),zeros(ril{1},1)};
% rid: Recovered Image Data (expected size is 110x118x1)
rid = {uint8(zeros(ri1,ri2,ri3)),uint8(zeros(ri1,ri2,ri3))}; %#ok<NASGU>
% sr:  State for Designated Receiver (DRx): 3 Digits, 1st Digit is 2 for DRx
% 2nd Digit is 1 for Receive Data, 2 for Transmit ACK, or 3 for Wait DIFS
sr  = uint8(211); %prm.DRxStateStart
% sm: DRx Major State: Most Significant 2 Digits of Full DRx State
sm  = uint8(0); %#ok<NASGU>
% hft: Function Handle to transceive() function for this IP Address
trx = eval(sprintf('@transceive%3d_mex',aip));

%initialize figures for visual demo
f1 = figure(102);
f2 = figure(103);
set(f1,'Position',[500,500,300,250]);
set(f2,'Position',[500,100,300,250]);


if (vm), fprintf(1,'Start DTx now.\n'); end
while (~fe)
    sm = sr/uint8(10);
    if (sm==uint8(21)) %prm.DRxStateRxDATA
        df = trx(db,ft,txGain, rxGain, centerFreqTx, centerFreqRx, intFactor, decFactor);
        [dfl,flg,nrb,rbs,sr] = drx_1ReceiveDATA(df,ft,sr);
        if (flg(1) || flg(2) || flg(3) || flg(4) || flg(5) || flg(6) || flg(7))
            cni = uint16(0); % Reset no-action counter
            % Record any flags in event log
            cev = cev+uint16(1);
            evl(cev,1) = cti;
            evl(cev,2) = uint16(bi2de(flg));
            evl(cev,3) = dfl(1);
            if flg(2) %PLCP header info found
                % Store expected #MPDU bits (LENGTH) for this 802.11 frame
                neb = dfl;
            elseif flg(4) % MAC header info found
                % Store which 802.11 frame# in Sequence (nsq) is being rx'd
                nsq = dfl;
                %store rbs in temp to transfer after IP is known
                rbs_temp = rbs;
            elseif flg(6) % Non-DATA MAC frame found
                % Change DRx State back to Search preamble
                sr  = uint8(211);  %prm.DRxStateRxSearchPreamble
                % Reset Count Variables
                nmb{addressIndex} = uint16(0);  nrb = uint16(0);
            end
        end
        if (nrb > uint16(0))
            
            if flg(7) %if address is found, store MAC hdr bits in rms
                rms{addressIndex}((nmb{addressIndex}+uint16(1)):(nmb{addressIndex}+64)) = rbs_temp;
                % Increase total MPDU bit count by this # of recovered USRP bits
                nmb{addressIndex} = (nmb{addressIndex} + 64);
            end
            
            % Store this recovered binary sequence in rms vector
            rms{addressIndex}((nmb{addressIndex}+uint16(1)):(nmb{addressIndex}+nrb)) = rbs(uint16(1):nrb);
            % Increase total MPDU bit count by this # of recovered USRP bits
            nmb{addressIndex} = (nmb{addressIndex} + nrb);
            if (flg(5) || nmb{addressIndex}>=neb) % Full payload found
                % Check FCS in MAC Header
                [~,ff] = step(hfd, rms{addressIndex});
                if (ff)
                    % When MAC FCS check fails, record flag in event log
                    cev = cev+uint16(1);
                    evl(cev,1) = cti;
                    evl(cev,2) = uint16(64); % 6th evl bit for FCS fail
                    evl(cev,3) = uint16(nsq);
                end
                % Append this 802.11b frame's Payload Bits to Recovered
                % Image Bitstream vector
                npb = (nmb{addressIndex}-uint16(numMacHdrBits+numFcsBits+numSuperBits));
                rib{addressIndex}((nib{addressIndex}+uint64(1)):(nib{addressIndex}+uint64(npb))) = ...
                    rms{addressIndex}(uint16(numMacHdrBits+1):(nmb{addressIndex}-(uint16(numFcsBits)+numSuperBits)));
                % On first fully rx'd MSDU (payload), get image dimensions
                if (c8f<uint16(1)) && (nib{addressIndex}<uint64(1)) && (npb>uint16(23))
                    [~,~,ri3,ril{addressIndex}] = getImageDims(rib{addressIndex}(1:24));
                end
                % Update count of the total number of image bits recovered
                nib{addressIndex} = (nib{addressIndex} + uint64(npb));
                % Increment total number of 802.11b frames found by 1
                c8f = (c8f + uint16(1));
                % Change DRx State to Transmit ACK
                sr  = uint8(220); %prm.DRxStateTxACKSendACK;
                % Reset Count Variables
                nmb{addressIndex} = uint16(0);
            end % IF FLG(5): FPF
        end % IF NRB>0
    elseif (sm==uint8(22)) %prm.DRxStateTxACK
        [d2s,fat,sr] = drx_2TransmitACK(ft,nsq,sr);
        if (sr==211)
            if (vm),
                fprintf('ACK Packet Transmitted for DATA Packet %d\n\n',nsq);
                %fprintf(datestr(now, 'HH:MM:SS:FFF\n'));
            end
        end
        trx(d2s,ft,txGain, rxGain, centerFreqTx, centerFreqRx, intFactor, decFactor);
        if (fat)
            % On ACK fully tx'd, reset no-action counter and flag
            cni = uint16(0);
            
            %displaying image for each packet received
            showData(choice, nib, rib);
            
        end
    elseif (sm==uint8(23)) %prm.DRxStateDIFS
        sr = drx_3WaitDIFS(sr);
    end % END IF SM==#
    cni = (cni+uint16(1));
    cti = (cti+uint16(1));
    if (cni >= nti)
        % Record an Event to denote timeout from no action in nti frames
        cev = cev+uint16(1);
        evl(cev,1) = cti;
        evl(cev,2) = uint16(256); % 8th bit denotes timeout
        evl(cev,3) = uint16(cni);
        % Set exit flag
        fe = logical(true(1));
        % Change DRx State to Terminal State: no more Tx/Rx performed
        sr = uint8(240); %prm.DRxStateEOT
    end
    
end % End While ~EOTFLAG
% Clear persistent data within all helper functions
ft = logical(true(1));
trx(db,ft,txGain, rxGain, centerFreqTx, centerFreqRx, intFactor, decFactor);
drx_1ReceiveDATA(df,ft,sr);
drx_2TransmitACK(ft,nsq,sr);
clear('ddd','drx_1ReceiveDATA','drx_2TransmitACK','preambleDet','rffe','sms');
clear(sprintf('transceive%3d_mex',aip));

return;
end % END FUNCTION DRX_V35

function [dfl,flg,nrb,rbs,sr] = drx_1ReceiveDATA(df,ft,sr)
% DRX_1RECEIVEDATA: Gets 802.11b DATA frame in 256 consecutive USRP frames
% Function Arguments:
% df:  This Data Frame, Raw USRP frame data in usrpFrameLength samples
% dfl: Data Flagged: uint16 to accompany data, set when status flag is true
% flg: Status Flags: a 1x5 logical array, carrying the following flags:
% (1): fdf: Flag Detected Preamble: Set true if PLCP Preamble (SYNC) found
% (2): fph: Flag PLCP Header Found: Init false, set true if PHY Header rx'd
% (3): fec: Flag Error CRC: Init false, set true if PHY Header CRC in error
% (4): fmh: Flag MAC Header Found: Init false, set true if MAC Header rx'd
% (5): fpf: Flag All Payload Found: Init false, set true if all payload rxd
% (6): ffc: Flag Frame Control: Set true if FrameCtrl~=DATA (e.g. if ACK)
% ft:  Flag Terminal: If true, specifies to release System objects
% nrb: Number of Recovered (MAC) Bits: Zero if not returning any MAC bits
% rbs: Recovered Binary Sequence: Taken from MAC Hdr/Payload/FCS (64 bits)
% sr:  State of Designated Receiver (DRx), a 3-digit enumeration

% Setting global variables
global halfUsrpFrameLength numUsrpBits doubleUsrpFrameLength ...
    numMpduBits numMacHdrBits numSuperBits ...
    addressTx aip vm addressIndex

% Persistent Data: Maintained between function calls to drx_1ReceiveData
% chf: Header Frame Count: Counts #USRP frames that have header info (0-2)
persistent chf;
% cp:  Payload Frame Count: Counts #USRP frames w/only payload data (0-251)
persistent cpf;
% dld: Data Last Decoded: Holds bits from last decoded USRP frame (len 64)
persistent dld;
% hcd: Handle to PHY PLCP CRC Detector
persistent hcd;
% i1b: Index of 1st bit in decoded USRP frame; found by SFD Detection
persistent i1b;
% i1s: Index of 1st sample in USRP frame (SYNC Delay+1): the sample# in Rx
%      buffer (rb) that marks start of frame; found by Preamble Detection
persistent i1s;
% n8f: Number in Sequence of MPDU 802.11b frame
persistent n8f_temp;
persistent n8f;
% nmb: Number of MPDU Bits (from LENGTH in PLCP Header, def. numMpduBits bits)
persistent nmb;
% npf: Number of Payload & FCS Frames =ceil((nmb-numUsrpBits)/numUsrpBits)
persistent npf;
% rb: Receive Buffer: Twice Length of USRP frame for Preamble Det (doubleUsrpFrameLength samples)
persistent rb;


% CONSTANTS: For Construction of System objects
cas = double(0.5);
cau = double(halfUsrpFrameLength);
cef = double(100.0);
% Initialize Persistent Data: Only on first call to drx_1ReceiveData
if isempty(chf),    chf = uint8(0);                 end
if isempty(cpf),    cpf = uint8(0);                 end
if isempty(dld),    dld = real(zeros(64,1));        end
if isempty(n8f_temp),    n8f_temp = uint16(0);    end
if isempty(n8f),    n8f = {uint16(0),uint16(0)};    end
if isempty(hcd)
    hcd = comm.CRCDetector('ChecksumsPerFrame',1,'FinalXOR',1, ...
        'InitialConditions',1,'Polynomial',[16,12,5,0]);
end % END IF ISEMPTY(HCD)

if isempty(i1b),    i1b = uint8(1);                 end
if isempty(i1s),    i1s = uint16(1);                end
if isempty(nmb),    nmb = uint16(numMpduBits+numSuperBits);      end
if isempty(npf),    npf = uint8(ceil((nmb-(numMacHdrBits))/numUsrpBits));               end
if isempty(rb),     rb  = complex(zeros(doubleUsrpFrameLength,1));   end
% Local Function Data: Overwritten on every call to drx_1ReceiveData
cra = zeros(41,1);
crm = zeros(2,2);
% dfb: This Frame + Last Frame Bits
dfb = zeros(numUsrpBits*2,1);
% dfd: This Frame Decoded: 1/11 the Length of this recovered USRP frame (64)
dfd = zeros(numUsrpBits,1);
dfl = uint16(0);
% dfr: This Frame Recovered: Half the Length of this USRP frame tf (halfUsrpFrameLength)
dfr = complex(zeros(halfUsrpFrameLength,1));
flg = logical(false(1,6));
flg = logical(false(1,7));
flt = logical(false(1,1)); %#ok<NASGU>
ips = uint16(0); %#ok<NASGU>
nrb = uint16(0);
rbs = zeros(numUsrpBits,1);
if (ft)
    release(hcd);
    %clear('hcd'); % Not supported for code generation
    rffe(df,ft,cas,cau,cef);
    ddd(dfr,ft);
    % Clear persistent data within RFFE() and DDD() functions
    % clear('rffe','preambleDet','ddd'); % Not supported for code generation
else
    % RF Front End: AGC, Freq Offset Correction, and RCRF
    dfr(1:halfUsrpFrameLength) = rffe(df,ft,cas,cau,cef);
    % Shift left receive buffer data by one recovered frame length (halfUsrpFrameLength)
    rb(1:2112) = rb((halfUsrpFrameLength+1):doubleUsrpFrameLength);
    % Add this recovered frame to end (last halfUsrpFrameLength samples) of receive buffer
    rb(2113:doubleUsrpFrameLength) = dfr(1:halfUsrpFrameLength);
    if (sr==uint8(211))     %prm.DRxStateRxSearchPreamble
        % Detect Preamble: Updates Synchronization Delay to Location of Max
        % Correlation with Expected Preamble; when correlation is above a
        % threshold, it updates DRx State to "DecodeHeader"
        [flt,ips] = preambleDet(rb);
        if (flt)
            % If detected PLCP Preamble, set flag #1: fdp
            flg(1,1) = logical(true(1));
            % Pass back this Synch Delay value in Flagged Data, dfl
            dfl = uint16(ips);
            % Add 1 USRP frame size to ips to get i1s: idx of 1st sample in frame
            i1s = ips + uint16(halfUsrpFrameLength);
            % Decode SYNC Data (for persistent vars in ddd function)
            dfr(1:halfUsrpFrameLength)  = rb(ips:(ips+uint16((halfUsrpFrameLength-1))));
            ddd(dfr,ft);
            dfr(1:halfUsrpFrameLength)  = rb(i1s:(i1s+uint16((halfUsrpFrameLength-1))));
            dld(1:64)   = ddd(dfr,ft);
            sr  = uint8(212); %prm.DRxStateRxDecodeHeader;
        end
    else
        % Prepare only the 1st halfUsrpFrameLength frame bits starting at the synch delay
        dfr(1:halfUsrpFrameLength)  = rb(i1s:(i1s+uint16((halfUsrpFrameLength-1))));
        % Despread, Demodulate, and Descramble Samples to make bitstream
        dfd(1:numUsrpBits)   = ddd(dfr,ft);
        % Combine decoded 64 bits with 64 bits from last decoded frame
        dfb(1:numUsrpBits)   = dld(1:numUsrpBits);
        dfb(numUsrpBits+1:numUsrpBits*2) = dfd(1:numUsrpBits);
        if (sr==uint8(212)) %prm.DRxStateRxDecodeHeader
            chf = chf+uint8(1);
            if (chf==uint8(1))
                i1b = uint8(numUsrpBits+1);
                % Lvl 3 Fine SFD Correlation: Find exact PLCP SFD start
                if ~isequal(dfb(i1b:(i1b+15)),[0;0;0;0;0;1;0;1;1;1;0;0;1;1;1;1])
                    % If demodulated sequence is not the same as scrambled Sync,
                    % perform a fine-tuned Correlation to find the index at
                    % which data is closest to start of sequence & readjust sd
                    iab(1:41) = (i1b-20):(i1b+20);
                    for ib = 1:41
                        crm(1:2,1:2) = abs(corrcoef(dfb(iab(ib):(iab(ib)+15)), ...
                            [0;0;0;0;0;1;0;1;1;1;0;0;1;1;1;1]));
                        cra(ib) = crm(2,1);
                    end % FOR SDI=1:WINLEN
                    [~,imb] = max(cra);
                    i1b = iab(imb);
                end
                
                if (i1b<=uint8(numUsrpBits+1))
                    flg(1,2) = logical(true(1));
                    % Get MPDU (MAC Hdr+Payload+FCS) Length from PLCP Header
                    nmb = uint16(bi2de(dfb((i1b+32):(i1b+47)).'));
                    % Pass back this Payload length value in dfl
                    dfl = uint16(nmb);
                    % Check CRC in PLCP Header
                    [~,flt] = step(hcd, dfb((i1b+16):(i1b+63)));
                    if (flt)
                        % If CRC check fails, set flag #3: fec to true
                        flg(1,3) = logical(true(1));
                        % Use default MPDU length: numMpduBits
                        nmb = uint16(numMpduBits+numSuperBits); dfl = nmb;
                    end
                else
                    % If index of 1st bit>65, wait until next USRP frame is
                    % decoded, then take
                    chf = chf-uint8(1);
                end
                % Calculate number of Payload Frames from MPDU length
                npf = ceil((nmb-(numMacHdrBits))/numUsrpBits);
            elseif (chf==uint8(2)) %prm.NumHeaderFrames
                % Process frame control in MAC Header
                if isequal(dfb(i1b:(i1b+15),1),[0;0;1;0;0;0;0;0;0;0;0;0;0;0;0;0])
                    if (vm),
                        fprintf(1,'DATA Packet Received!');
                        fprintf(1,'\n');
                        fprintf(1,'DATA Packet''s Frame Control Readout:');%%%%************Checking frame control at DRx
                        fprintf(1,'%d',dfb(i1b:(i1b+15),1));
                        fprintf(1,'\n');
                    end
                    % Pass back all MAC bits, Header+Payload+FCS
                    rbs(1:numUsrpBits) = dfb(i1b:(i1b+numUsrpBits-1));
                    %nrb = uint16(numUsrpBits);
                    nrb = uint16(0);
                    % Get Number in Duration of 802.11b Frame from MAC Header
                    n8f_temp = uint16(bi2de(dfb((i1b+16):(i1b+31)).'));
                    % Set flag #4: fmh true when MAC Header is found
                    flg(1,4) = logical(true(1));
                    % Pass back Sequence Number in Flagged Data, dfl
                    dfl = uint16(n8f_temp);
                    
                else
                    % Set flag #6: ffc true when MAC Frame Control ~DATA
                    flg(1,6) = logical(true(1));
                    % Send back the Frame Control Received in dfl
                    dfl = uint16(bi2de(dfb(i1b:(i1b+15),1).'));
                    % Return to Search for Preamble
                    sr  = uint8(211); %prm.DRxStateRxSearchPreamble
                    % Reset all count variables internal to function
                    chf = uint8(0);
                    cpf = uint8(0);
                    rb(1:doubleUsrpFrameLength) = complex(zeros(doubleUsrpFrameLength,1));
                end
                
            elseif (chf==uint8(3)) %prm.NumHeaderFrames
                %CHECK ADDRESS BEFORE PROCEEDING
                %extract addresses
                addressRx = str2double(strcat(num2str(bi2de(dfb(i1b:(i1b+7)).')),num2str(bi2de(dfb(i1b+8:(i1b+15)).'))));
                addressTx = str2double(strcat(num2str(bi2de(dfb(i1b+48:(i1b+55)).')),num2str(bi2de(dfb(i1b+56:(i1b+63)).'))));
                addressRxString = strcat(num2str(bi2de(dfb(i1b:(i1b+7)).')),'.',num2str(bi2de(dfb(i1b+8:(i1b+15)).')));
                addressTxString = strcat(num2str(bi2de(dfb(i1b+48:(i1b+55)).')),'.',num2str(bi2de(dfb(i1b+56:(i1b+63)).')));
                
                if (addressTx == 102)
                    addressIndex=1;
                elseif (addressTx == 103)
                    addressIndex=2;
                end
                
                %check if packet is a duplicate
                if (n8f{addressIndex} == n8f_temp)
                    % Send back the Frame Control Received in dfl
                    % Return to Search for Preamble
                    sr = uint8(220); %prm.DRxStateTxACKSendACK
                    % Reset all count variables internal to function
                    chf = uint8(0);
                    cpf = uint8(0);
                    rb(1:doubleUsrpFrameLength) = complex(zeros(doubleUsrpFrameLength,1));
                else
                    %save n8f in correct addressTx to check for duplicates
                    n8f{addressIndex} = n8f_temp;
                end
                
                %print addresses
                if (vm),
                    fprintf(1,'To Address read out from DATA: 192.168.%s \n',addressRxString);
                    fprintf(1,'From Address read out from DATA: 192.168.%s \n',addressTxString);
                end
                %if packet is addressed to this receiver
                if addressRx == aip
                    %                     sr  = uint8(213); %prm.DRxStateRxGetPayload
                    rbs(1:numUsrpBits) = dfb(i1b:(i1b+numUsrpBits-1));
                    nrb = uint16(numUsrpBits);
                    flg(1,7) = logical(true(1)); % address found
                else
                    if (vm), fprintf('Wrong MAC Address, Resetting to Detect Preamble..\n'); end
                    % Set flag #6: ffc true when MAC Frame Control ~DATA
                    flg(1,6) = logical(true(1));
                    % Change Major State from Rx DATA to Tx ACK
                    sr = uint8(220); %prm.DRxStateTxACKSendACK
                    if (vm),
                        %fprintf(datestr(now, 'HH:MM:SS:FFF\n'));
                    end
                    % Reset all count variables internal to function
                    chf = uint8(0);
                    cpf = uint8(0);
                    rb(1:doubleUsrpFrameLength) = complex(zeros(doubleUsrpFrameLength,1));
                end
                
                %pass back Address3 frame
            elseif (chf==uint8(4))
                rbs(1:numUsrpBits) = dfb(i1b:(i1b+numUsrpBits-1));
                nrb = uint16(numUsrpBits);
                %pass back Sequence Control + Address4 + beginning of Payload
            elseif (chf==uint8(5))
                rbs(1:numUsrpBits) = dfb(i1b:(i1b+numUsrpBits-1));
                nrb = uint16(numUsrpBits);
                %move to GetPayload state
                sr  = uint8(213); %prm.DRxStateRxGetPayload
                
            end % END IF CH==#
            
        elseif (sr==uint8(213)) %prm.DRxStateRxGetPayload
            % Update Payload Frame Count
            cpf = cpf+uint8(1);
            if (cpf<npf) %prm.NumPayloadFrames
                % Store All Payload Bits in rbs and update bit count nrb
                nrb = uint16(numUsrpBits);
                rbs(1:numUsrpBits) = dfb(i1b:(i1b+numUsrpBits-1));
            else  % On last payload frame for this 802.11b frame,
                % Calculate #bits to return from remainder after division
                % of #MPDU bits by 64 bits/USRPframe
                nrb = uint16(rem(nmb,uint16(numUsrpBits)));
                if (nrb==uint16(0)), nrb=uint16(numUsrpBits); end
                % Pass back all bits, even FCS used to verify no error
                rbs(uint8(1):uint8(nrb)) = dfb(i1b:(i1b+uint8(nrb)-uint8(1)));
                % Set flag #5 true to signify all payload data recovered
                flg(1,5) = logical(true(1));
                % Pass back total #payload frames in flagged data, dfl
                dfl = uint16(npf);
                % Change Major State from Rx DATA to Tx ACK
                sr = uint8(220); %prm.DRxStateTxACKSendACK
                if (vm),
                    %fprintf(datestr(now, 'HH:MM:SS:FFF\n'));
                end
                % Reset all count variables internal to function
                chf = uint8(0);
                cpf = uint8(0);
                rb(1:doubleUsrpFrameLength) = complex(zeros(doubleUsrpFrameLength,1));
            end
            
        end % END IF SR==#
        % Store bits from this frame for use in next frame's processing
        dld(1:numUsrpBits) = dfd(1:numUsrpBits);
    end % END IF SR==211U
end % END IF FT
end % END FUNCTION DRX_1RECEIVEDATA

function [d2s,fat,sr] = drx_2TransmitACK(ft,n8f,sr)
% DRX_2TRANSMITACK: Transmits 802.11 ACK frame in 4 consecutive USRP frames
% Function Arguments:
% d2s: Data To Send, frame data in usrpFrameLength samples to put on USRP Tx buffer
% fat: Flag ACK Transmitted: Set to true when last ACK USRP frame prepared
% ft:  Flag Terminal: If true, specifies to release System objects
% n8f: 802.11b Frame Number, for ACK header info
% sr:  State of Designated Receiver (DRx), a 3-digit enumeration

% Setting global variables
global usrpFrameLength halfUsrpFrameLength halfSamples80211b ...
    numSuperBits numPhyHdrBits numAckBits addressTx

%determine addressTx for RA in ACK frame
addressTxStr = num2str(addressTx);
addressTx1 = str2double(addressTxStr(1:2));
addressTx2 = str2double(addressTxStr(3));


% Persistent Data: Maintained between function calls to drx_1ReceiveData
% ca:  Count ACK Header Frame: Tracks #USRP frames w/ ACK header info (0-4)
persistent ca;
% dfs: Data Frame Samples: Scrambled, Modulated, Spread 802.11 ACK Frame
persistent dfs;
% hcg: Handle to PHY PLCP CRC Generator
persistent hcg;
% hfg: Handle to MAC FCS CRC Generator
persistent hfg;
% hrt: Handle to Raised Cosine Transmit Filter (RCTF) System object
persistent hrt;


% Initialize Persistent Data: Only on first call to drx_2TransmitACK
if isempty(ca),     ca  = uint8(0);                 end
if isempty(dfs),    dfs = complex(zeros(3520,1));   end
if isempty(hcg)
    hcg = comm.CRCGenerator('ChecksumsPerFrame',1,'FinalXOR',1, ...
        'InitialConditions',1,'Polynomial',[16,12,5,0]);
end % END IF ISEMPTY(HCG)
if isempty(hfg)
    hfg = comm.CRCGenerator('ChecksumsPerFrame',1,'FinalXOR',1, ...
        'InitialConditions',1,'Polynomial', ...
        [32,26,23,22,16,12,11,10,8,7,5,4,2,1,0]);
end % END IF ISEMPTY(HFG)
if isempty(hrt)
    hrt = comm.RaisedCosineTransmitFilter('FilterSpanInSymbols',8, ...
        'Gain',1,'OutputSamplesPerSymbol',2,'RolloffFactor',0.3, ...
        'Shape','Square root');
end % END IF ISEMPTY(HRT)
% Local data preallocation
d2s = complex(zeros(usrpFrameLength,1));
% dfb: Data Frame Bits: Binary 802.11 ACK Frame Bit Sequence
dfb = real(zeros(320,1));
dfe = complex(zeros(halfUsrpFrameLength,1));
dfi = complex(zeros(numPhyHdrBits+numAckBits+numSuperBits,1));
dfo = complex(zeros(halfSamples80211b,1)); %#ok<NASGU>
fat = logical(false(1));
if (ft)
    release(hcg);
    release(hfg);
    release(hrt);
    % Release System objects created by SMSRC() function
    sms(dfb,ft,320);
    % clear('hcg','hfg','hrt'); % Not supported for code generation
    % Clear persistent data within SMS() function
    % clear('sms'); % Not supported for code generation
else
    if (ca==uint8(0))
        % Prepare ACK 802.11b frame, starting with PLCP Preamble SYNC
        dfb(001:128) = ones(128,1);
        % PHY SFD & Start of PLCP Header
        dfb(129:144) = [0;0;0;0;0;1;0;1;1;1;0;0;1;1;1;1];
        dfb(145:152) = [0;1;0;1;0;0;0;0];
        dfb(153:160) = zeros(8,1);
        % LENGTH=MACHeader (64)+MAC Frame Body(0)+MAC FCS (32)
        dfb(161:176) = de2bi(128,16)';
        % Append 16-bit CRC to 32-bit PLCP Header: result is 48 bits
        dfb(145:192) = step(hcg, dfb(145:176));
        % Start of MAC Header: ACK Frame Control (16 bits):
        % Ver 00, Type 01, Subtype 1101
        ProtocolVer = [0;0];
        TypeBits = [0;1];
        SubType = [1;1;0;1];
        % Rest of Frame Control 8 bits, set to 1's
        ToDS = [1];
        FromDS = [1];
        MoreFlag = [1];
        RetryBit = [1];
        PwrMgmt = [1];
        MoreData = [1];
        WepBit = [1];
        OrderBit = [1];
        dfb(193:208) = [ProtocolVer;TypeBits;SubType;ToDS;FromDS;MoreFlag;...
            RetryBit;PwrMgmt;MoreData;WepBit;OrderBit];
        % ACK Duration/ID Slot holds Frame number in sequence
        dfb(209:224,1) = de2bi(double(n8f),16).';
        % ACK RA is same as Address 2 field of previous directed DATA frame
        dfb(225:272,1) = [de2bi(0,32),de2bi(addressTx1,8),de2bi(addressTx2,8)]';
        % Append 32-bit FCS to 32-bit MAC Header: result is 64 bits
        dfb(193:304) = step(hfg, dfb(193:272));
        % Append SuperBits to end of FCS
        dfb(305:320) = ones(numSuperBits,1);
        
        % Scramble, Modulate, and Spread Bits (output len is 11x input)
        dfi(1:320) = dfb(1:320);
        dfo = sms(dfi,ft,320);
        dfs(1:3520) = dfo(1:3520);
    end % IF CA==0
    dfe(1:halfUsrpFrameLength,1)  = dfs((double(ca)*halfUsrpFrameLength+1):((double(ca)+1)*halfUsrpFrameLength),1);
    d2s(1:usrpFrameLength,1) = step(hrt,dfe(1:halfUsrpFrameLength,1));
    ca = ca + uint8(1);
    if (ca==uint8(5))
        fat = logical(true(1));
        % Update DRx Major state to resume search for PLCP preamble
        sr = uint8(211);    %prm.DRxStateRxSearchPreamble;
        % Reset count variables internal to function
        ca = uint8(0);
    end
end
end % End Function DRX_2TRANSMITACK

function sr = drx_3WaitDIFS(sr)


end % End Function DRX_3WAITDIFS
