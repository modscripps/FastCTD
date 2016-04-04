% plot YEI data using MATLAB files instead of RAW
set(0,'DefaultAxesFontSize',            20,...
      'DefaultTextFontName',            'Times',...
      'DefaultTextFontSize',            20);
      
mypath = 	'/Volumes/RR1513_ASIRI_1/FCTD/MAT/';
TimerStop = false;
myTimer = timer();
myTimer.StartFcn = 'figure(1000); clf; set(gcf,''Position'',get(0,''MonitorPositions''));';
myTimer.TimerFcn = 'if TimerStop, stop(myTimer); delete(timerfindall); else, mydir = dir([mypath ''*.mat'']); try, load([mypath mydir(end-1).name]);if ~isempty(FCTD), PlotYEIonFCTD2(FCTD); end; catch err, disp(err); end; end';
myTimer.Period = 0.5;
myTimer.BusyMode = 'drop';
myTimer.ErrorFcn = '%%%%%%%%%%%%% Error %%%%%%%%%%%%%';
myTimer.TasksToExecute = Inf;
myTimer.StopFcn = 'disp(''%%%%%%%%%% ALL STOP %%%%%%%%%%'')';
myTimer.Tag = 'FastCTD_Timer';
myTimer.ExecutionMode = 'fixedSpacing';

start(myTimer);