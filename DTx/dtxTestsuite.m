% Test Suite to measure performance of the system

% This code is licensed under the LGPLv3 license. Please feel free to use the code in your research and development works. 
% We would appreciate a citation to the paper below when this code is helpful in obtaining results in your future publications.

%Code Release
% 

% Publication for citation:
% Ramanathan Subramanian, Benjamin Drozdenko, Eric Doyle, Rameez Ahmed, Miriam Leeser, and Kaushik Chowdhury, 
% "High-Level System Design of IEEE 802.11b Standard-Compliant Link Layer for MATLAB-based SDR", accepted on March 3rd, 2016 
% for publication in IEEE Access Journal.

fix(clock)

% Select which experiment you wish to run.
% Experiment 1: Vary Tx Gain at DTx %
% Experiment 2: Vary Payload Size in the DATA packet %
% Experiment 3: Fix the Payload Size and the Tx Gain %

experimentNumber = 3;
%Reject first rejPkts packets
rejPkts = 3;

switch(experimentNumber)
    
    case 1
        % Experiment 1: Vary Tx Gain at DTx %
        txGain_all = [10,15,20,25,30];
        numPayload_all = 2004;
        numRuns = size(txGain_all,2);
    case 2
        % Experiment 2: Vary Payload Size in the DATA packet %
        txGain_all = 30;
        numPayload_all = [500,1004,1500,2004];
        numRuns = size(numPayload_all,2);
    case 3
        % Experiment 3: Fix the Payload Size and the Tx Gain %
        txGain_all = 25;
        numPayload_all = 2004;
        numRuns=1;
end

%initialize arrays of data
packetArray_all = cell(1,numRuns);
packet_number_all = zeros(1,numRuns);
packets_sent_all = zeros(1,numRuns);
packetError_all = zeros(1,numRuns);
latency_all = zeros(1,numRuns);
numRetransmits_all = zeros(1,numRuns);
i = 1;
save exp_output.mat i packetArray_all packet_number_all packets_sent_all...
    packetError_all latency_all numPayload_all txGain_all rejPkts ...
    experimentNumber

for k=1:numRuns
    
    %clear all; close all; clear classes; clc; clear mex; findsdru
    load exp_output.mat;
    
    disp(i)
%     disp('Press any key! Set numPackets >> rejPkts')
%     pause;
    
    global l retransmit_counter packets_sent packet_number packet_array ...
        txGain rxGain centerFreqTx centerFreqRx numPayloadOctets 
    
    %diary('dtxDiary.m')
    %packet counters
    retransmit_counter= 0;
    packets_sent = 0;
    packet_number = 0;
    switch (experimentNumber)
        case 1
            txGain = txGain_all(1,i);
            numPayloadOctets = numPayload_all;
        case 2
            txGain = txGain_all;
            numPayloadOctets = numPayload_all(1,i);
        case 3
            txGain = txGain_all;
            numPayloadOctets = numPayload_all;
    end
    rxGain = 15;
    centerFreqTx = 1.284e9;
    centerFreqRx = 1.284e9;
    %begin experiment
    start=clock;
    %MAC layer code gets called from within the PHY layer code
    dtxPHYLayer
    stop=clock;
    %calculations
    %Ignore the first 10 packets to account possibly for 'uhd: U' errors
    b=packet_array(rejPkts:end)-1;
    p=sum(b);
    perror=p/packets_sent;
    totaltime=etime(stop,start);
    throughput=l/totaltime;
    latency=totaltime/(packets_sent-sum(packet_array(1:rejPkts)));
    numRetransmits=retransmit_counter;
    %packetError=numRetransmits/packets_sent;
    packetError = perror;
    %saving to arrays
    packetArray_all{1,i} = packet_array;
    packet_number_all(1,i) = packet_number;
    packets_sent_all(1,i) = packets_sent;
    packetError_all(1,i) = packetError;
    numPayload_all(1,i) = numPayloadOctets;
    latency_all(1,i) = latency;
    numRetransmits_all(1,i) = numRetransmits;
    
    %save and exit
    timestamp=clock;
    i = i+1;
    save exp_output.mat i packetArray_all packet_number_all...
        packets_sent_all packetError_all latency_all numPayload_all txGain_all ...
        rejPkts experimentNumber
    
    diary off
end
