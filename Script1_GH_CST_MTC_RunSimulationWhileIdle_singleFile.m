clear;
close all;
clc;

%%%%!!!!!!!!!!!!!!!!! Remember to set the right directirity on "Current
%%%%Folder" window inside MATLAB

RTD = 180/pi;

%%%%--- control center command/ configuration setting 

addpath(genpath('K:\Desktop\To Matlab Path root folder'))

fprintf('[%s] Initializeing... \n', datestr(now,'HH:MM:SS'));
fprintf('[%s] opening CST... \n', datestr(now,'HH:MM:SS'));

%%%-------------------file path control pannel------------------%%
 Filename = 'D:\DELL\2020Patch antenna from Paper.cst';%Example CSTfile


%%%%%%%%%%---------Read the phase from plane wave-----%%%%%%%%%%
    pause(3);
    CST = TCSTInterface();          % Creates the interface between CST and Matlab
    CSTRead = Filename;%TT(3:length(TT)); %please active this file in advance or set it in path
    pause(3);
    CST.OpenProject(CSTRead,2020);% the year of CST that you used    % Open the project on CST %% it has to be open first on CST before running this MATLAB code of else it will pop up error
    
    parameterPath ='C:\Users\' ;
    parameterfileName = 'steering_lookupTableforPhi90.csv';
    parameterloading = readlines([parameterPath parameterfileName]);
    SS2 = char(parameterloading);
    NN2 = str2num(SS2(2:end,:));

    positionn =  find(NN2(:,1)==[-45:5:45]');%mod(find(NN2(:,1)==[-45:5:45]'),length(NN2));
    ThetaSteering = NN2(positionn,1);
    PCphaseNoPO = NN2(positionn,2);
    PCAmpNoPO = NN2(positionn,3);
    P1AmpPO = NN2(positionn,5);
    P2AmpPO = NN2(positionn,6);

 for ii = 1:length(ThetaSteering)     
    pause(3);
    
    
    CST.Project.invoke('Save');
    %fprintf('[%s] Updating parameter... \n', datestr(now,'HH:MM:SS'));
    fprintf('[%s] Reading port result... \n', datestr(now,'HH:MM:SS'));
    fprintf('[%s] Changing setting... \n', datestr(now,'HH:MM:SS'));
    
    SimulationName(ii) = string(['AR_Phi_90_theta_' num2str(ThetaSteering(ii)) '_WithPowerOpemise']);

     CST.Project.invoke('AddToHistory', ['DefineSet_' char(ii)],[
                sprintf(' With Solver \n')...
                sprintf('  .ResetExcitationModes \n')...
                sprintf('  .SParameterPortExcitation "False"  \n')...
                sprintf('  .SimultaneousExcitation "True"  \n')...
                sprintf('  .SetSimultaneousExcitAutoLabel "False"   \n')...
                sprintf('  .SetSimultaneousExcitationLabel "%s"   \n',SimulationName)...
                sprintf('  .SetSimultaneousExcitationOffset "Phaseshift"    \n')...
                sprintf('  .PhaseRefFrequency "2.38"     \n')...
                sprintf('  .ExcitationSelectionShowAdditionalSettings "False"     \n')...
                sprintf('  .ExcitationPortMode "1", "1", "%0.2f", "%0.2f", "default", "True"      \n',P1AmpPO(ii),PCphaseNoPO(ii))...
                sprintf('  .ExcitationPortMode "2", "1", "%0.2f", "%0.2f", "default", "True"  \n',P2AmpPO(ii),-90)...
                sprintf('End With \n')]);
    % CST.Project.invoke('RebuildOnParametricChange',1, 0);% update all parameter
     pause(1);
     CST.Solve();
     pause(1);
     CST.Project.invoke('Save');
 end
   

    CST.Project.invoke('Save');
    pause(3);
%   CST.Project.invoke('quit');

 for ii = 1:length(ThetaSteering) 
    foldername = string(['Farfields\farfield (f=2.38) [' char(SimulationName(ii)) ']\Axial Ratio'])
    CST.Project.invoke('SelectTreeItem',foldername)
    CST.Project.invoke('StoreCurvesInClipboard')
    CST.Project.invoke('PasteCurvesFromClipboard',"1D Results\New Folder")
 end

fprintf('[%s] Program complete... \n', datestr(now,'HH:MM:SS'));

