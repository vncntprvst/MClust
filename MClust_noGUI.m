
%% code to use MClust without the GUI

global MClustInstance

% -- initialize -- 
MClustInstance = MClust0();
MClustInstance.Initialize(false);

disp(MClust.GetSettings().VERSION)

% change settings in the MClustInstance
    % bypass SelectLoadingEngine
    % add features / pass data to the MClustInstance directly

MCD = MClust.GetData();

% save clusters
MCD.SaveClusters(MCD.DefaultClusterFileName);
OK = MCD.WriteTfiles();

if OK
    disp('T files written.');
    MCD.FilesWrittenYN = true;
end