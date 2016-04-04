mypath = '/Volumes/EquatorFlexA/FCTD/';
TimerStop = false;
myTimer = timer();
myTimer.StartFcn = 'figure(1); set(gcf,''Position'',get(0,''MonitorPositions''));';
myTimer.TimerFcn = 'if TimerStop, stop(myTimer); delete(timerfindall); else, mydir = dir(mypath); FCTD = FastCTD_ReadASCII([mypath mydir(end).name]); PlotDiffTimeToFindGap(FCTD); end';
myTimer.Period = 1;
myTimer.BusyMode = 'drop';
myTimer.ErrorFcn = '%%%%%%%%%%%%% Error %%%%%%%%%%%%%';
myTimer.TasksToExecute = Inf;
myTimer.StopFcn = 'disp(''%%%%%%%%%% ALL STOP %%%%%%%%%%'')';
myTimer.Tag = 'FastCTD_Timer';
myTimer.ExecutionMode = 'fixedSpacing';

start(myTimer);