function F = FirregWaveNB(t,x,wave,wave2F,sys)
   % --- Irregular wave -----------------
   % 2Do: attach wave2F to bodies
   %      check if dimensions correct for all wave periods and directions
    XYpos_init = zeros(sys.nDoF,2);
    XYpos_temp = zeros(sys.nDoF,2);
    
    for ibod=1:sys.nbod
       XYpos_init(sys.calDoF(ibod,1):sys.calDoF(ibod,2),1) = sys.bodPos_init(1,ibod);
       XYpos_init(sys.calDoF(ibod,1):sys.calDoF(ibod,2),2) = sys.bodPos_init(2,ibod);
    end

    for ibod = 1:sys.nbod
        XYpos_temp(sys.calDoF(ibod,1):sys.calDoF(ibod,2),1:2) = ones(6,1)*x(sys.calDoF(ibod,1):sys.calDoF(ibod,1)+1,:)'+...
        XYpos_init(sys.calDoF(ibod,1):sys.calDoF(ibod,2),2) ;
    end


   kXx_plus_kYy = XYpos_temp*[wave.kX,wave.kY]';
   
   F = sum(wave2F.Xamp.* (wave.ZaCal'.*sin(wave.omegaCal'*t -  kXx_plus_kYy +...
                           wave.phaseCal' + wave2F.phase)), 2); 
   
   % -------------------------------------



end