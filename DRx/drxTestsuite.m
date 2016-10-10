% runs drxTestsuite repeatedly

% This code is licensed under the LGPLv3 license. Please feel free to use the code in your research and development works. 
% We would appreciate a citation to the paper below when this code is helpful in obtaining results in your future publications.

% Publication for citation:
% Ramanathan Subramanian, Benjamin Drozdenko, Eric Doyle, Rameez Ahmed, Miriam Leeser, and Kaushik Chowdhury, 
% "High-Level System Design of IEEE 802.11b Standard-Compliant Link Layer for MATLAB-based SDR", accepted on March 3rd, 2016 
% for publication in IEEE Access Journal.

% PER and link latency are measured at the DTx for several hundereds of DATA-ACK exchanges
% DRx sends out an ACK upon reception of DATA packet.
% In this context, it is convenient to have the DRx run continuously. 
% Also helps deal with time-outs resulting possibly from underflow errors.

diary('drxDiary.m')
fix(clock)

while 1
    drxPHYLayer
end
