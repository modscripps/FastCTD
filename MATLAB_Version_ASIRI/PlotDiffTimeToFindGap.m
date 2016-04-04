function PlotDiffTimeToFindGap(FCTD)
figure(1);
clf;
plot(FCTD.time(1:end-1)-min(FCTD.time(1:end-1)),diff(FCTD.time)*3600*24,'-*','markersize',6);
datetick('x','HH:MM:SS','keeplimits')