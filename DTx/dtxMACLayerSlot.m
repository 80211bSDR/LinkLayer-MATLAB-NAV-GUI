function st = dtxMACLayerSlot(st,frt)
% dtxMACLayerSlot: Wait DIFS and Random Backoff Time while performing Energy Detection

% This code is licensed under the LGPLv3 license. Please feel free to use the code in your research and development works.
% We would appreciate a citation to the paper below when this code is helpful in obtaining results in your future publications.

% Publication for citation:
% Ramanathan Subramanian, Benjamin Drozdenko, Eric Doyle, Rameez Ahmed, Miriam Leeser, and Kaushik Chowdhury,
% "High-Level System Design of IEEE 802.11b Standard-Compliant Link Layer for MATLAB-based SDR", accepted on March 3rd, 2016
% for publication in IEEE Access Journal.

% st:  State for Designated Transmitter (DTx): 3 Digits, 1st Dig=1 for DTx
%      2nd Digit is 1 for Det Energy, 2 for Transmit DATA, or 3 for Rx ACK
% frt: Flag Retransmit: On ACK timeout, retransmit last 802.11b frame again
% k: Random Backoff Duration Exponent
% trx: Function Handle to transceive() function for this IP Address
% BEB_Choice: Perform Binary Exponential Backoff (BEB) Or Binary Linear Backoff (BLB)?
%             1: BEB; 0: BLB
% cMin: minimum contention window size
% BEB_Slots: Random Back-off Window Size
% vcsFlag: Flag set to indicate whether channel is reserved using RTS/CTS
% vcs_Slots: # Slot-times the channel is reserved using RTS/CTS
% vcsChoice: User picks either DATA/ACK exchanges or RTS/CTS/DATA/ACK exchanges

global usrpFrameLength DIFS_Slots BEB_Slots cMin energyThreshold txGain rxGain aip ...
    centerFreqTx centerFreqRx intFactor decFactor vm energySamples vcsChoice ...
    BEB_Choice vcs_Slots vcsFlag numMaxRetransmit

persistent k; if isempty(k), k = uint8(1); end

if (frt == 1) & (vcsFlag == 1)
    % Truncate k at numMaxRetransmit => #retransmits <= numMaxRetransmit
    k=uint8(min(k+1,numMaxRetransmit));
else
    k=uint8(1);
end


if BEB_Choice == 1
    BEB_Slots = randi((2^(k))-1)*cMin;
else
    BEB_Slots = randi((2*(k))-1)*cMin;
end

% Calls to trx() defines the slot time
trx = eval(sprintf('@transceive%3d_mex',aip));
if (vcsFlag == 0)
    % state at 111 implies system transitioned to DIFS state
    if (st == uint8(111))
        % Frame Ready; Start Timer for DIFS
        % if (vm), fprintf('Entering DIFS state..\n'); end
        SlotCount = 1;
        EnrFlg  = logical(false(1));
        % Wait for DIFS Duration in slot-times
        while SlotCount < DIFS_Slots
            % ft:  Terminal Flag to release System objects
            ft  = logical(false(1));
            % db:  Blank Data: For putting on Transmit Buffer while in a Rx Major State
            db  = complex(zeros(usrpFrameLength,1));
            % Fetch a USRP frame; 1 Slot worth of samples
            df = trx(db,ft,txGain,rxGain,centerFreqTx,centerFreqRx,intFactor,decFactor,1);
            if (sum(abs(df).^2)> energyThreshold)
                if (vm), fprintf('Energy detected in DIFS state, Backing off!!\n'); end
                SlotCount=1;
                EnrFlg=logical(true(1));
            end
            SlotCount=SlotCount+1;
        end
        % if (vm), fprintf('...DIFS ends.\n'); end
    end
    
    if (vm), fprintf('Entering Random Backoff state..\n'); end
    SlotCount = 1;
    % Random Backoff
    ft=logical(false(1));
    BEB_FreezeSlot = 0; % Backoff Freeze Count
    while SlotCount < BEB_Slots
        % db:  Blank Data: For putting on Transmit Buffer while in a Rx Major State
        db  = complex(zeros(usrpFrameLength,1));
        % Fetch a USRP frame; 1 Slot worth of samples
        df = trx(db,ft,txGain,rxGain,centerFreqTx,centerFreqRx,intFactor,decFactor,1);
        % energySamples = [energySamples sum(abs(df).^2)];
        if (sum(abs(df).^2)> energyThreshold)
            if (vm), fprintf('Energy detected in Random Backoff state, Backing off!!\n'); end
            BEB_FreezeSlot=SlotCount;
            SlotCount=1;
            BEB_Slots=BEB_Slots-BEB_FreezeSlot;
        end
        SlotCount=SlotCount+1;
    end
    % if (vm), fprintf('...Random Backoff ends.\n'); end
else
    %Virtual Carrier Sensing
    SlotCount = 1;
    if (vcsFlag == 1)
        while SlotCount < vcs_Slots
            % ft:  Terminal Flag to release System objects
            ft  = logical(false(1));
            % db:  Blank Data: For putting on Transmit Buffer while in a Rx Major State
            db  = complex(zeros(usrpFrameLength,1));
            df = trx(db,ft,txGain,rxGain,centerFreqTx,centerFreqRx,intFactor,decFactor,1);
            SlotCount=SlotCount+1;
        end
        if (vm), fprintf('Defered Medium Access for NAV Duration - Exiting VCS!!\n'); end
        vcsFlag = logical(false(1));
    end
end

if (vcsChoice == 1)
    st = uint8(151); % Virtual Carrier Sensing;  %prm.DTxStateTransmitRTS
else
    st=uint8(121); % No Virtual Carrier Sensing; prm.DTxStateTransmitPHYHeader
end

end