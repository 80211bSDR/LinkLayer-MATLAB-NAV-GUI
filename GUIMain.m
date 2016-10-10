function varargout = GUIMain(varargin)
% GUIMAIN MATLAB code for GUIMain.fig
%      GUIMAIN, by itself, creates a new GUIMAIN or raises the existing
%      singleton*.
%
%      H = GUIMAIN returns the handle to a new GUIMAIN or the handle to
%      the existing singleton*.
%
%      GUIMAIN('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUIMAIN.M with the given input arguments.
%
%      GUIMAIN('Property','Value',...) creates a new GUIMAIN or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUIMain_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUIMain_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help GUIMain

% Last Modified by GUIDE v2.5 05-Aug-2016 13:50:32

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUIMain_OpeningFcn, ...
    'gui_OutputFcn',  @GUIMain_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before GUIMain is made visible.
function GUIMain_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to GUIMain (see VARARGIN)


% % handles.output = hObject;
% UIWAIT makes GUIMain wait for user response (see UIRESUME)
% uiwait(handles.figure1);

%Testing out developing the panel
% panels=[handles.uipanel1 handles.uipanel2];
% handles.currPanel=1;
% set(panels(1),'Visible','on','Position',[2.5 5.375 30 1.5]);
% set(panels(2),'visible','off','Position',[5 5.375 30 1.5]);
% % Update handles structure
% handles.panels=panels;
% guidata(hObject, handles);
% Panel = position ,(2.5,5.375,30,1.5);
%Heading = Position, (6.7,7.5,25,1)
% Choose default command line output for GUIMain
% handles.output = hObject;
set(handles.phybut,'Units','normalized')
set(handles.macbut,'Units','normalized')
set(handles.uipanel4,'Units','normalized')
set(handles.uipanel6,'Units','normalized')
set(handles.uipanel4, 'Visible', 'on');
set(handles.uipanel6, 'Visible', 'off');

% overwrite=zeros(1,14);
I1 = imread('genesysLogo.png');
% I2 = imread('mathworksLogo2.jpg');
axes(handles.axes1);
imshow(I1);
% axes(handles.axes3);
% imshow(I2);

% set(handles.edit5,'String','');
% % set(handles.edit6,'String','');
% set(handles.edit7,'String','');
% set(handles.edit8,'String','');
% set(handles.edit9,'String','');
% set(handles.edit10,'String','');
% set(handles.edit11,'String','');
% set(handles.edit12,'String','');
% set(handles.edit13,'String','');
% % set(handles.edit14,'String','');
% set(handles.edit15,'String','');
% set(handles.edit16,'String','');
% set(handles.edit18,'String','');

set(handles.macbut, 'BackgroundColor', [0.83 0.83 0.83]);

% --- Outputs from this function are returned to the command line.
function varargout = GUIMain_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% setting global variables
global spreadFactor numPayloadBits numMpduBits numUsrpBits numMacHdrBits usrpFrameLength ...
    halfUsrpFrameLength doubleUsrpFrameLength numBits80211b ...
    halfSamples80211b samplingRate crosscorr_thresh dataChoice l numSuperFrameBits ...
    numSuperBits numFcsBits numPhyHdrBits upFactor numSuperSamples80211b ...
    halfSuperSamples80211b numAckBits BEB_Slots DIFS_Slots cMin energyThreshold intFactor ...
    txGain rxGain centerFreqTx centerFreqRx decFactor numPackets vm ...
    numPayloadOctets vcsChoice BEB_Choice numMaxRetransmit to toa currentFolder pop

%Defining variables in the Initparameters file in GUI
%% 802.11b PHY Initialization

% dataChoice: 1 for random binary data of length l, 2 for image selection
dataChoice = 1;
%Pick the State Machine false: DATA-ACK OR true: RTS-CTS-DATA-ACK
%set flag for virtual carrier sensing
vcsChoice = logical(true(1));

% numPackets: number of desired packets, if choice 1
numPackets = 20;


% adcRate: ADC Rate
adcRate = 100e6;
% intFactor: USRP Interpolation Rate
intFactor = 500;
% % decFactor: Decimation Factor
decFactor = 500;
% txGain: Tranmitter Gain used in transceive()
txGain = 30;
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

% numPayloadOctets: number of octets for payload per frame
numPayloadOctets = 2004;
% numPayloadBits: number of payload bits
numPayloadBits = 8*numPayloadOctets;
% numPhyHdrBits: number of bits in PHY Header
numPhyHdrBits = 192;
% numSyncBits: number of SYNC bits
numSyncBits = 128;
% numSfdHeaderBits: number of SFD+header bits (64PHY + 64 MAC)
numSfdHeaderBits = 128;


% numFcsBits: number of FCS bits
numFcsBits = 32;
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
numAckBits = 112;

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
%DIFS = 2.5 Slots as per the 802.11b standard
DIFS_Slots = 3;
%Perform Binary Exponential Backoff (BEB) Or Binary Linear Backoff (BLB)?
BEB_Choice = 1; % 1: BEB; 0: BLB
%cmin: minimum contention window size
if BEB_Choice == 1
    cMin = 31; % as per the 802.11b standard
else
    cMin = 50;
end
% Truncate k at numMaxRetransmit => #retransmits < numMaxRetransmit
numMaxRetransmit = 3;
%Energy Threshold
energyThreshold = 10;
% energyThreshold = energyThresholdEstimate(usrpFrameLength, txGain, rxGain, centerFreqTx, centerFreqRx, intFactor, decFactor);

%% Derived System Parameters
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
crosscorr_thresh = 0.3;

%Time Out
% to:  Timeout: The #iterations of the main loop to wait before exiting.
to  = uint32(8000);
% toa: Timeout ACK: #iterations to wait for an ACK before resending DATA
toa = uint32(4000);


%Radio Button for Mode - DTx/DRx
radio1 = get(handles.radiobutton1,'Value');

%Radio Button for printing screen log
radio3 = get(handles.radiobutton3,'Value');

%Radio Button for choice to perform Virtual Carrier Sense
radio5 = get(handles.radiobutton5,'Value');

%%Radio Button for what to do - process type
radio7 = get(handles.radiobutton7,'Value');

if radio3==1
    vm = 1;
end

if radio5==0
    vcsChoice = logical(true(1));
else
    vcsChoice = logical(false(1));
end

%Defining numPayloadOctets before dataChoice fro Default value
if ~isempty(get(handles.edit6,'String'))
    %     if isinteger(str2num(get(handles.edit6,'String')))
    numPayloadOctets = str2num(get(handles.edit6,'String'));
    %     else
    %         error('Enter a valid integer value for Payload octets');
    %     end
end

if radio7==1
    dataChoice = 1;
else
    dataChoice = 2;
    vm=0;
end


% vm:  Verbose Mode: Displays additional text on screen describing DTx actions
if dataChoice == 2
    %     vm  = logical(true(1));
    % else
    %     vm  = logical(false(1));
    % numPayloadOctets: number of payload octets; for choice 2
    numPayloadOctets = 2012;
end

if ~isempty(get(handles.edit5,'String'))
    numPackets = str2num(get(handles.edit5,'String'));
end

% length of binary data, leave blank or 0 for choice 2
l = numPayloadBits*numPackets;

if ~isempty(get(handles.edit7,'String'))
    crosscorr_thresh = str2num(get(handles.edit7,'String'));
end

if ~isempty(get(handles.edit8,'String'))
    centerFreqTx = str2num(get(handles.edit8,'String'));
end

if ~isempty(get(handles.edit9,'String'))
    centerFreqRx = str2num(get(handles.edit9,'String'));
end

if ~isempty(get(handles.edit10,'String'))
    txGain = str2num(get(handles.edit10,'String'));
end

if ~isempty(get(handles.edit11,'String'))
    rxGain = str2num(get(handles.edit11,'String'));
end

if ~isempty(get(handles.edit12,'String'))
    toa = str2num(get(handles.edit12,'String'));
end

if ~isempty(get(handles.edit13,'String'))
    to = str2num(get(handles.edit13,'String'));
end

% if ~isempty(get(handles.edit14,'String'))
%     BEB_Choice = get(handles.edit14,'String');
% end

if strcmp(pop,'Linear')
    BEB_Choice = 0;
else BEB_Choice = 1;
end

if ~isempty(get(handles.edit15,'String'))
    DIFS_Slots = str2num(get(handles.edit15,'String'));
end

if ~isempty(get(handles.edit16,'String'))
    BEB_Slots = str2num(get(handles.edit16,'String'));
end

if ~isempty(get(handles.edit6,'String'))
    numMaxRetransmit = str2num(get(handles.edit18,'String'));
end

%Taking the address of the current directory
currentFolder = pwd;

if radio1==1
    direct=strcat(currentFolder,'/DTx');
    cd(direct);
    %    direct='/home/.../80211bSDR-LinkLayer-MATLAB-1e1c15a/DTx';
    if dataChoice==1
        dtxTestsuite
    else
        dtxPHYLayerVisual
    end
else
    direct=strcat(currentFolder,'/DRx');
    cd(direct);
    %     direct='/home/.../80211bSDR-LinkLayer-MATLAB-1e1c15a/DRx';
    if dataChoice==1
        drxTestsuite
    else
        drxPHYLayerVisual
    end
    % drxPHYLayer
end
% disp(direct);

cd ..;


function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double
global edit1Val
edit1Val = str2num(get(handles.edit1,'String'));

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double
global edit2Val
edit2Val = str2num(get(handles.edit2,'String'));

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function radiobutton1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global radio1
radio1 = get(hObject,'Value');

% --- Executes during object creation, after setting all properties.
function radiobutton2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global radio2
radio2 = get(hObject,'Value');

% --- Executes during object creation, after setting all properties.
function radiobutton3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global radio3
radio3 = get(hObject,'Value');

% --- Executes during object creation, after setting all properties.
function radiobutton4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global radio4
radio4 = get(hObject,'Value');

% --- Executes during object creation, after setting all properties.
function radiobutton8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global radio8
radio8 = get(hObject,'Value');

% --- Executes during object creation, after setting all properties.
function radiobutton7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global radio7
radio7 = get(hObject,'Value');

% --- Executes during object creation, after setting all properties.
function radiobutton6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
global radio6
radio6 = get(hObject,'Value');


% --- Executes during object creation, after setting all properties.
function radiobutton5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to radiobutton5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLABg
% handles    empty - handles not created until after all CreateFcns called
global radio5
radio5 = get(hObject,'Value');



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit10_Callback(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit10 as text
%        str2double(get(hObject,'String')) returns contents of edit10 as a double


% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit11_Callback(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit11 as text
%        str2double(get(hObject,'String')) returns contents of edit11 as a double


% --- Executes during object creation, after setting all properties.
function edit11_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit11 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit12_Callback(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit12 as text
%        str2double(get(hObject,'String')) returns contents of edit12 as a double


% --- Executes during object creation, after setting all properties.
function edit12_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit13_Callback(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit13 as text
%        str2double(get(hObject,'String')) returns contents of edit13 as a double


% --- Executes during object creation, after setting all properties.
function edit13_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit13 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in phybut.
function phybut_Callback(hObject, eventdata, handles)
% hObject    handle to phybut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pan1pos=get(handles.uipanel4,'Position');
set(handles.uipanel4,'Position',pan1pos);
set(handles.uipanel4, 'Visible', 'on');
set(handles.uipanel6, 'Visible', 'off');
set(handles.macbut, 'BackgroundColor', [0.83 0.83 0.83]);
set(handles.phybut, 'BackgroundColor', [1 1 1]);

% --- Executes on button press in macbut.
function macbut_Callback(hObject, eventdata, handles)
% hObject    handle to macbut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
pan1pos=get(handles.uipanel4,'Position');
set(handles.uipanel6,'Position',pan1pos);
set(handles.uipanel4, 'Visible', 'off');
set(handles.uipanel6, 'Visible', 'on');
set(handles.phybut, 'BackgroundColor', [0.83 0.83 0.83]);
set(handles.macbut, 'BackgroundColor', [1 1 1]);

function edit22_Callback(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit22 as text
%        str2double(get(hObject,'String')) returns contents of edit22 as a double


% --- Executes during object creation, after setting all properties.
function edit22_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit22 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit21_Callback(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit21 as text
%        str2double(get(hObject,'String')) returns contents of edit21 as a double


% --- Executes during object creation, after setting all properties.
function edit21_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit21 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit20_Callback(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit20 as text
%        str2double(get(hObject,'String')) returns contents of edit20 as a double


% --- Executes during object creation, after setting all properties.
function edit20_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit20 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit19_Callback(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit19 as text
%        str2double(get(hObject,'String')) returns contents of edit19 as a double


% --- Executes during object creation, after setting all properties.
function edit19_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit19 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit18_Callback(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit18 as text
%        str2double(get(hObject,'String')) returns contents of edit18 as a double


% --- Executes during object creation, after setting all properties.
function edit18_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit18 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit16_Callback(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit16 as text
%        str2double(get(hObject,'String')) returns contents of edit16 as a double

% --- Executes during object creation, after setting all properties.
function edit16_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit16 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit15_Callback(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit15 as text
%        str2double(get(hObject,'String')) returns contents of edit15 as a double


% --- Executes during object creation, after setting all properties.
function edit15_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit15 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
open HelpGUI.pdf;


% --- Executes on selection change in popupmenu3.
function popupmenu3_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu3 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu3
global pop
items = get(hObject,'String');
index_selected = get(hObject,'Value');
pop = items{index_selected};

% --- Executes during object creation, after setting all properties.
function popupmenu3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes when figure1 is resized.
function figure1_SizeChangedFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
