function MCD = MClust_noGUI(snippets)
%% Code to use MClust without the GUI

% Requires data passed as snippets, containing timestamps and waveforms
% snippets=struct('T',[],'WV',[]) - for testing purposes

% Example
% snippets = load('snippets-8tetrodesCf_BRDNSS-tet006.mat')
% struct with fields:
%     WV: [410×4×32 double]
%      T: [410×1 double]
% MCD = MClust_noGUI(snippets)

global MClustInstance %from original software

% -- initialize --
MClustInstance = MClust0();
MClustInstance.Initialize(false);

disp(MClust.GetSettings().VERSION)

% change settings in the MClustInstance
% pass data to the MClustInstance directly

%% bypass SelectLoadingEngine

%     Change loading function for SI snippets with
%     % 'ChannelValidity'
%     % 'ExpectedExtension'
%     % 'UseFileDialog'
%     % 'AverageWaveform_ylim'
%
%     Pass Loader to LoadingEngines / LoadingEnginePulldown

% Or just allocate (may not be needed):
MClustInstance.Settings.NeuralLoadingFunction='Load_snippets'; %snippet extractor from SpikeInterface
MClustInstance.Settings.ChannelValidity=[1 1 1 1]; %default
% MClustInstance.Settings.ExpectedExtension=''; %none
MClustInstance.Settings.UseFileDialog=false;
MClustInstance.Settings.AverageWaveform_ylim=[-1000 1000]; %not sure
MClustInstance.Data.Snippets=snippets;

%% bypass LoadTetrodeData (create / load FD files)

MClustInstance.Data.TTdn=cd;
MClustInstance.Data.TTfn='snippet';
MClustInstance.Data.TText='';

% Calculate features and save them
MCS = MClust.GetSettings();

% Which features need to be calculated
featuresToCalc = MCS.FeaturesToUse; % default featuresToCalc =    {'feature_Peak'}    {'feature_Time'}
% Call function
[MClustInstance.Data.FeatureTimestamps, MClustInstance.Data.Features] = MClust.CalculateFeatures(featuresToCalc);
% to alleviate need for a mock-up loader, CalculateFeatures could be coded here

%% Cluster with KKwik / SPC / Manual cutting
%----------- RunKKwikCutter ----------------

%----------- RunSpcCutter ------------------
%     Creates the SPC clustering window
%     Calls SpcCutter < MClust.Cutter
%       > LoadClusters

MClustInstance.Data.Clusters = LoadClusters;

%         Export clusters
%         SpcCutter > exportClusters(self)

%----------- RunManualCutter ----------------
%       Or Manual Cutting > drop down menu RunKKwik on Cluster - works well
%         MCC = MClust.ManualCutter();
%
%         ClusterFunc_RunKKwikOnCluster > CallClusterFunction > RunKKwik
%         >
%         [KKoutput] = KlustaKwik.RunOneKKwik(KKfn, FILEno,...
%             nKKFeatures, minClusters, maxClusters, ...
%             'otherParms', otherParms);

%         then export clusters from manual cutting window
%                 function exportClusters(self)
% 			        exportClusters@MClust.Cutter(Clusters(2:end));
% 		  end


%% Write .t files / save .clusters
MCD = MClust.GetData();

MCD.SaveClusters(MCD.DefaultClusterFileName);
OK = MCD.WriteTfiles();

if OK
    disp('T files written.');
    MCD.FilesWrittenYN = true;
end

% exportClusters(self)
% 			exportClusters@MClust.Cutter(Clusters(2:end));

end

function Clusters = LoadClusters
MCD = MClust.GetData();

disp('Running SPC...')

% Get the features of each spike from MClust
Np = length(MCD.Features{1}.GetData); %number of points
Nf = length(MCD.Features); %number of features
F = zeros(Np, Nf);
for i = 1:Nf
    F(:,i) = MCD.Features{i}.GetData;
end

% Set min cluster size
MIN_CS = round(Np/100); %default is Npoints/100

% Run SPC
tic;
[C, P] = spc_mex(F', MIN_CS);
toc

% Add clusters from SPC to cutter clusters to look at
nClu = length(C);
disp([' Found ' num2str(nClu) ' clusters'])
Clusters = cell(1,nClu+1);
for iC = 1:nClu %for each cluster
    Clusters{iC+1} = MClust.ClusterTypes.SpikelistCluster; %create new cluster
    Clusters{iC+1}.SetSpikes(C{iC}+1); %set it to contain spikes in C
    Clusters{iC+1}.setAssociatedCutter(@GetCutter);
    Clusters{iC+1}.hide = true;
end

% And make the cluster of all points
Clusters{1} = MClust.ClusterTypes.SpikelistCluster; %create new cluster
Clusters{1}.SetSpikes(1:size(F,1)); %set it to contain all spikes
Clusters{1}.setAssociatedCutter(@GetCutter);
Clusters{1}.hide = true;

end 
