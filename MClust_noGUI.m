
%% code to use MClust without the GUI
% requires data passed as snippets 
% snippets=struct('T',[],'WV',[]) - for testing purposes

global MClustInstance

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
[FeatureTimestamps, Features] = MClust.CalculateFeatures(featuresToCalc);

%% Cluster with KKwik / SPC / Manual cutting
% RunKKwikCutter

% RunSpcCutter 
%     Creates the SPC clustering window
%     Calls SpcCutter > LoadClusters(self)
        
%         Export clusters
%         SpcCutter > exportClusters(self)
        
% RunManualCutter
%       Or Manual Cutting > drop down menu RunKKwik on Cluster - works well 

%         then export clusters from manual cutting window
%                 function exportClusters(self)
% 			        self.exportClusters@MClust.Cutter(self.Clusters(2:end));
% 		  end
           

%% Write .t files / save .clusters
MCD = MClust.GetData();

MCD.SaveClusters(MCD.DefaultClusterFileName);
OK = MCD.WriteTfiles();

if OK
    disp('T files written.');
    MCD.FilesWrittenYN = true;
end
 