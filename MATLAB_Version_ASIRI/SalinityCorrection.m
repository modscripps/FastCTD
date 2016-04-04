FCTD = FastCTD_ReadASCII('/Volumes/Users/Shared/FCTD/FCTD12_10_07_184210.ascii');
shift = 4;
salinity_corr = sw_salt(FCTD.conductivity(1:end-shift)*10/sw_c3515,FCTD.temperature(1+shift:end),FCTD.pressure(1+shift:end));
salinity_ucor = sw_salt(FCTD.conductivity(1:end-shift)*10/sw_c3515,FCTD.temperature(1:end-shift),FCTD.pressure(1:end-shift));

figure(shift+1); 
cla;
plot(salinity_ucor(4120:11335),FCTD.pressure(4120:11335),'b',salinity_corr(4120:11335)+0.5,FCTD.pressure(4120:11335),'r','linewidth',1);
hold on;
plot(salinity_ucor(11335:20120),FCTD.pressure(11335:20120),'m',salinity_corr(11335:20120)+0.5,FCTD.pressure(11335:20120),'g','linewidth',1);
axis ij;
grid on;
title(sprintf('Shift %d',shift));