function F = irregWaveF(t,x,wave,wave2F)
   % --- Irregular wave -----------------
   % 2Do: attach wave2F to bodies
   %      check if dimensions correct for all wave periods and directions
   F = sum(wave2F.Xamp'.* (wave.ZaCal.*sin(wave.omegaCal*t - [wave.kXCal,wave.kYCal]*...
                      x(1:2) + wave.phaseCal + wave2F.phase')), 1); 
   F = F';

   % -------------------------------------
end