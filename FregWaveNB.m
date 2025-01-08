function F = FregWaveNB(t,x,wave,wave2F,sys)
% --- Regular wave -------------------------
% not updated with [x(1:2,:)]
% 2Do: attach wave2F to bodies; 
%      add updation of position
% F = wave2F.Xamp.*(wave.Za*cos(-wave.omega*t +...
%                  [wave.kX,wave.kY]*[0;0] +...
%                   wave.phase + wave2F.phase));
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

kXx_plus_kYy = XYpos_temp*[wave.kX;wave.kY];
F = wave2F.Xamp.*(wave.Za*sin(wave.omega*t -...
                 kXx_plus_kYy +...
                 wave.phase + wave2F.phase));
% --------------------------------------------
end

